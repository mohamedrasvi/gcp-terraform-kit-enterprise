org_id          = "123456789012"
billing_account = "01A2B3-CD4E5F-6G7H8I"
domain          = "example.com"
vpc_mode        = "shared"
default_region  = "us-central1"

environments = {
  "non-prod" = { folder_display_name = "Non-Production" }
  "prod"     = { folder_display_name = "Production" }
}

shared_vpc_config = {
  "non-prod" = {
    common_project_name = "org-nonprod-common"
    common_project_id   = "myorg-nonprod-common"
    resource_projects = [
      { project_name = "org-nonprod-dev", project_id = "myorg-nonprod-dev" },
    ]
    public_subnets = [
      {
        name          = "public-subnet-1"
        region        = "us-central1"
        ip_cidr_range = "10.0.1.0/24"
        secondary_ranges = [
          { range_name = "pods", ip_cidr_range = "10.100.0.0/16" },
          { range_name = "services", ip_cidr_range = "10.101.0.0/20" },
        ]
      }
    ]
    private_subnets = [
      { name = "private-subnet-1", region = "us-central1", ip_cidr_range = "10.0.2.0/24" }
    ]
  }
  "prod" = {
    common_project_name = "org-prod-common"
    common_project_id   = "myorg-prod-common"
    resource_projects = [
      { project_name = "org-prod-app", project_id = "myorg-prod-app" },
    ]
    public_subnets = [
      {
        name          = "public-subnet-1"
        region        = "us-central1"
        ip_cidr_range = "10.10.1.0/24"
        secondary_ranges = [
          { range_name = "pods", ip_cidr_range = "10.110.0.0/16" },
          { range_name = "services", ip_cidr_range = "10.111.0.0/20" },
        ]
      }
    ]
    private_subnets = [
      { name = "private-subnet-1", region = "us-central1", ip_cidr_range = "10.10.2.0/24" }
    ]
  }
}

enable_monitoring              = true
enable_logging                 = true
resource_state_bucket_location = "US"

labels = {
  managed-by  = "terraform"
  environment = "standard"
}
