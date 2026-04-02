org_id          = "123456789012"
billing_account = "01A2B3-CD4E5F-6G7H8I"
domain          = "example.com"
vpc_mode        = "non-shared"
default_region  = "us-central1"

environments = {
  "non-prod" = { folder_display_name = "Non-Production" }
  "prod"     = { folder_display_name = "Production" }
}

non_shared_vpc_config = {
  "non-prod" = {
    projects = [
      {
        project_name = "org-dev"
        project_id   = "myorg-dev"
        public_subnets = [
          { name = "public-subnet-1", region = "us-central1", ip_cidr_range = "10.0.1.0/24" }
        ]
        private_subnets = [
          { name = "private-subnet-1", region = "us-central1", ip_cidr_range = "10.0.2.0/24" }
        ]
      }
    ]
  }
  "prod" = {
    projects = [
      {
        project_name = "org-production"
        project_id   = "myorg-production"
        public_subnets = [
          { name = "public-subnet-1", region = "us-central1", ip_cidr_range = "10.10.1.0/24" }
        ]
        private_subnets = [
          { name = "private-subnet-1", region = "us-central1", ip_cidr_range = "10.10.2.0/24" }
        ]
      }
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
