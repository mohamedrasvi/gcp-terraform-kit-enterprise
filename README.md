# GCP Terraform Kit

A production-grade Terraform kit for spinning up a complete GCP organization landing zone and deploying resources into it. Supports both standard and HIPAA-compliant landing zones with shared and non-shared VPC modes.

---

## Repository Structure

```
.
├── bootstrap/          # Step 0 — creates the Terraform state GCS bucket (local state, run once)
├── foundation/
│   ├── standard/       # Step 1 — standard landing zone (folders, projects, VPCs, org policies)
│   └── hipaa/          # Step 1 — HIPAA landing zone (Assured Workloads + stricter org policies)
├── modules/            # Reusable Terraform modules (called by foundation + resources)
└── resources/          # Step 2 — deploy resources (GKE, SQL, VMs, etc.) into projects
```

---

## How It Works

```
bootstrap  ──creates──►  GCS state bucket
    │
    └── foundation  ──creates──►  Org folders + Projects + VPCs + Monitoring + Logging
                                  + GCS state buckets per project (for resources layer)
            │
            └── resources  ──deploys──►  GKE / SQL / VMs / BigQuery / etc. into projects
                             (workspace = dev | prod, var-file = env/dev.tfvars | env/prod.tfvars)
```

Each layer has its **own independent state file** stored in GCS.

---

## Prerequisites

Before running any Terraform you need:

### 1. GCP Organization
- A GCP Organization (not just a standalone project)
- Billing Account linked to the organization

### 2. Seed / Admin Project
A GCP project where the Terraform state bucket lives and where your service account runs.
Create this manually in the GCP console before running bootstrap.

### 3. Terraform Service Account
Create a service account in your seed project and assign these roles:

#### For `bootstrap/` (run once manually)
| Role | Level | Why |
|------|-------|-----|
| `roles/storage.admin` | Seed project | Create the Terraform state bucket |

#### For `foundation/` (landing zone deployment)
| Role | Level | Why |
|------|-------|-----|
| `roles/resourcemanager.organizationAdmin` | Organization | Create folders, set org policies |
| `roles/resourcemanager.folderCreator` | Organization | Create environment folders |
| `roles/resourcemanager.projectCreator` | Organization | Create projects inside folders |
| `roles/billing.user` | Billing Account | Link billing to new projects |
| `roles/compute.networkAdmin` | Organization | Create VPCs, subnets, Cloud NAT |
| `roles/compute.xpnAdmin` | Organization | Enable Shared VPC (shared mode only) |
| `roles/orgpolicy.policyAdmin` | Organization | Set org policies |
| `roles/storage.admin` | Organization | Create per-project state buckets |
| `roles/monitoring.admin` | Organization | Create monitoring dashboards + alerts |
| `roles/logging.admin` | Organization | Create log sinks and buckets |
| `roles/assuredworkloads.admin` | Organization | Create Assured Workloads (HIPAA only) |

#### For `resources/` (resource deployment — per project)
| Role | Level | Why |
|------|-------|-----|
| `roles/container.admin` | Project | Create GKE clusters |
| `roles/cloudsql.admin` | Project | Create Cloud SQL instances |
| `roles/compute.instanceAdmin.v1` | Project | Create VMs |
| `roles/storage.admin` | Project | Create GCS buckets |
| `roles/artifactregistry.admin` | Project | Create Artifact Registry repos |
| `roles/dns.admin` | Project | Create Cloud DNS zones |
| `roles/bigquery.dataOwner` | Project | Create BigQuery datasets |
| `roles/monitoring.admin` | Project | Create monitoring resources |
| `roles/iam.serviceAccountUser` | Project | Attach service accounts to resources |

> **Tip:** For CI/CD, grant `roles/owner` on the target project or use a dedicated SA per project with only the scoped roles above.

### 4. Required Tools
```bash
terraform >= 1.5.0
gcloud CLI (authenticated)
```

### 5. Authenticate Terraform
```bash
# Option A: User credentials (local dev)
gcloud auth application-default login

# Option B: Service account key
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/sa-key.json"

# Option C: Workload Identity (recommended for CI/CD)
# Configure impersonation in your pipeline
```

---

## Step-by-Step: First-Time Setup

### Step 0 — Bootstrap (run once)

Creates the GCS bucket that stores all future Terraform state.

```bash
cd bootstrap/

cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars:
#   project_id         = "my-seed-project"
#   bucket_name        = "my-org-tf-state"
#   terraform_sa_email = "terraform@my-seed-project.iam.gserviceaccount.com"

terraform init
terraform plan
terraform apply
```

Note the `state_bucket_name` output — you will use this in all subsequent steps.

> Bootstrap uses **local state** intentionally — this is the only layer that does. The bucket it creates stores all other state remotely.

---

### Step 1 — Foundation (Landing Zone)

Choose `standard/` or `hipaa/` based on your compliance requirements.
Choose networking mode by picking the matching tfvars file.

#### Standard Landing Zone

```bash
cd foundation/standard/

terraform init \
  -backend-config="bucket=<YOUR_STATE_BUCKET>" \
  -backend-config="prefix=foundation/standard"

# Copy and edit the right tfvars for your networking mode:
cp environments/shared-vpc.tfvars terraform.tfvars
# OR
cp environments/non-shared-vpc.tfvars terraform.tfvars

# Fill in: org_id, billing_account, domain, project IDs, CIDR ranges
vim terraform.tfvars

terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

#### HIPAA Landing Zone

```bash
cd foundation/hipaa/

terraform init \
  -backend-config="bucket=<YOUR_STATE_BUCKET>" \
  -backend-config="prefix=foundation/hipaa"

cp environments/shared-vpc.tfvars terraform.tfvars
vim terraform.tfvars

terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

#### What Foundation Creates

**Shared VPC mode:**
```
Organization
├── non-prod/                             ← GCP folder
│   ├── org-nonprod-common                ← Host project (VPC lives here)
│   │   ├── VPC
│   │   ├── Public subnets  (Cloud NAT attached — outbound internet via NAT)
│   │   ├── Private subnets (no Cloud NAT — fully private, Private Google Access only)
│   │   ├── Cloud NAT + Cloud Router
│   │   ├── Folder-wide monitoring dashboard + alert policies
│   │   └── Log sinks for all non-prod projects → GCS / BigQuery
│   └── org-nonprod-dev                   ← Service project (uses host VPC subnets)
│       └── Basic project-level metrics
└── prod/                                 ← GCP folder
    ├── org-prod-common                   ← Host project
    │   ├── VPC + subnets + Cloud NAT
    │   └── Folder-wide monitoring + logging
    └── org-prod-app                      ← Service project
        └── Basic project-level metrics
```

**Non-Shared VPC mode:**
```
Organization
├── non-prod/
│   └── org-dev          ← Project with its own VPC + subnets + Cloud NAT
└── prod/
    └── org-production   ← Project with its own VPC + subnets + Cloud NAT
```

**Subnet types:**
- **Public subnet** — attached to Cloud NAT gateway; workloads can reach the internet outbound
- **Private subnet** — no Cloud NAT; fully private; Private Google Access enabled for GCP APIs

**Org Policies applied (standard):**
- Disable serial port access on VMs
- Disable service account key creation
- Require Shielded VMs
- Enforce uniform bucket-level access on GCS
- Restrict IAM allowed domains
- Deny VM external IP addresses

**Additional policies in HIPAA mode:**
- Require CMEK for Cloud Storage, BigQuery, and Compute
- Enable Access Transparency
- Restrict resource creation to US regions only

Foundation also creates a `<project-id>-tfstate` GCS bucket inside each project it provisions — the resources layer uses these as state backends.

---

### Step 2 — Resources

Deploy GKE, Cloud SQL, VMs, BigQuery, and more into a target project.
All resource types live in one flat root and are toggled on/off with boolean flags in your tfvars.

```bash
cd resources/

terraform init \
  -backend-config="bucket=<YOUR_STATE_BUCKET>" \
  -backend-config="prefix=resources"

# Create workspaces (first time only)
terraform workspace new dev
terraform workspace new prod

# Deploy to dev
terraform workspace select dev
terraform plan  -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars

# Deploy to prod
terraform workspace select prod
terraform plan  -var-file=env/prod.tfvars
terraform apply -var-file=env/prod.tfvars
```

State is stored per workspace:
- `gs://<bucket>/resources/env:dev/terraform.tfstate`
- `gs://<bucket>/resources/env:prod/terraform.tfstate`

#### Configuring env/dev.tfvars

```hcl
project_id        = "myorg-nonprod-dev"      # target project from foundation outputs
environment       = "dev"
default_region    = "us-central1"
network_self_link = "projects/myorg-nonprod-common/global/networks/nonprod-vpc"

# Toggle resources on/off — only enabled ones are created
enable_gke_autopilot      = true
enable_cloud_sql_postgres = true
enable_gcs_buckets        = true
enable_artifact_registry  = false
enable_gke_self_managed   = false
enable_cloud_sql_mysql    = false
enable_vm_instances       = false
enable_cloud_dns          = false
enable_bigquery           = false
```

#### Available Resources

| File | Resource | Enable flag |
|------|----------|-------------|
| `gke.tf` | GKE Autopilot — private nodes, workload identity | `enable_gke_autopilot` |
| `gke.tf` | GKE Standard — private nodes, custom node pools | `enable_gke_self_managed` |
| `sql.tf` | Cloud SQL PostgreSQL — private IP, HA, backups | `enable_cloud_sql_postgres` |
| `sql.tf` | Cloud SQL MySQL — private IP, HA, backups | `enable_cloud_sql_mysql` |
| `vm.tf` | Compute Engine VMs | `enable_vm_instances` |
| `storage.tf` | GCS Buckets — versioning, lifecycle, encryption | `enable_gcs_buckets` |
| `artifact-registry.tf` | Artifact Registry — Docker / Maven / npm | `enable_artifact_registry` |
| `dns.tf` | Cloud DNS — public or private zones | `enable_cloud_dns` |
| `bigquery.tf` | BigQuery — datasets + tables | `enable_bigquery` |

---

## State File Layout

| Layer | GCS Path | Notes |
|-------|----------|-------|
| Bootstrap | local `terraform.tfstate` | Local only — never delete this file |
| Foundation standard | `gs://<bucket>/foundation/standard/terraform.tfstate` | Single state for entire landing zone |
| Foundation HIPAA | `gs://<bucket>/foundation/hipaa/terraform.tfstate` | Single state for HIPAA landing zone |
| Resources (dev) | `gs://<bucket>/resources/env:dev/terraform.tfstate` | Workspace-isolated |
| Resources (prod) | `gs://<bucket>/resources/env:prod/terraform.tfstate` | Workspace-isolated |

---

## Modules Reference

| Module | Purpose |
|--------|---------|
| `folder-factory` | Create GCP folders under org or parent folder |
| `project-factory` | Create projects, enable APIs, link billing |
| `org-policies` | Apply security org policies at org/folder level |
| `vpc` | Standalone VPC (non-shared mode) |
| `subnets` | Create public + private subnets |
| `shared-vpc` | Enable Shared VPC, attach service projects |
| `cloud-nat` | Cloud Router + NAT gateway (public subnets only) |
| `firewall` | Firewall rules |
| `cloud-sql-postgres` | Cloud SQL PostgreSQL — private IP, HA, backups |
| `cloud-sql-mysql` | Cloud SQL MySQL — private IP, HA, backups |
| `gke-autopilot` | GKE Autopilot — private nodes, workload identity |
| `gke-self-managed` | GKE Standard — private nodes, custom node pools |
| `vm-instance` | Compute Engine VM instance |
| `gcs-bucket` | GCS bucket — versioning, lifecycle, encryption |
| `artifact-registry` | Artifact Registry repository |
| `cloud-dns` | Cloud DNS managed zone + record sets |
| `bigquery` | BigQuery dataset + tables |
| `monitoring` | Dashboards, alert policies, notification channels |
| `logging` | Log sinks, log buckets, GCS/BigQuery export |
| `assured-workloads` | Assured Workloads for HIPAA and other compliance regimes |

---

## Common Operations

### Get outputs from foundation to use in resources tfvars

```bash
cd foundation/standard/
terraform output -json vpc_self_links
terraform output -json project_ids
terraform output -json subnet_self_links
terraform output -json state_bucket_names
```

### Add a new resource project to the landing zone

1. Add an entry to `resource_projects` under the relevant env in your `terraform.tfvars`
2. Re-run `terraform plan/apply` in `foundation/standard/`

### Destroy resources (dev environment only)

```bash
cd resources/
terraform workspace select dev
terraform destroy -var-file=env/dev.tfvars
```

> Never run `terraform destroy` on `foundation/` without careful review — it would delete all folders, projects, VPCs, and everything inside them.

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `Error 403: The caller does not have permission` | Check the SA roles table — a required role is missing for that resource type |
| `Error creating Project: quota exceeded` | Request a project quota increase in GCP console under IAM → Quotas |
| `Error: Backend configuration changed` | Run `terraform init -reconfigure -backend-config=...` |
| `Error: No workspace named "dev" found` | Run `terraform workspace new dev` first |
| `Error: project is already a service project` | Import it: `terraform import module.shared_vpc... <project_id>` |
| `Error: assuredworkloads billing account not eligible` | Billing account must be associated with your organization (not standalone) |
| Shared VPC subnets not visible in service project | Verify `compute.xpnAdmin` is granted at org level and subnet-level IAM is set |
| `Error: googleapi 409 already exists` | Resource already exists outside Terraform — use `terraform import` to adopt it |
