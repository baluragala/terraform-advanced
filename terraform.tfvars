# Example Terraform variables file
# Copy this file to terraform.tfvars and customize the values

project_id     = "my-second-project-458705"
default_region = "us-central1"
environment    = "staging"

# Multi-region configuration
regions = {
  us_central1 = {
    name                = "us-central1"
    vpc_cidr            = "10.0.0.0/16"
    public_subnet_cidr  = "10.0.1.0/24"
    private_subnet_cidr = "10.0.2.0/24"
  }
  # Uncomment to add more regions
  # us_east1 = {
  #   name                = "us-east1"
  #   vpc_cidr           = "10.1.0.0/16"
  #   public_subnet_cidr = "10.1.1.0/24"
  #   private_subnet_cidr = "10.1.2.0/24"
  # }
  # europe_west1 = {
  #   name                = "europe-west1"
  #   vpc_cidr           = "10.2.0.0/16"
  #   public_subnet_cidr = "10.2.1.0/24"
  #   private_subnet_cidr = "10.2.2.0/24"
  # }
}

# Instance configuration
instance_type  = "e2-medium"
instance_count = 2
disk_size      = 20

# Firewall configuration
allowed_ports = ["80", "443"]

# Tags
tags = {
  Project   = "PrismMart"
  ManagedBy = "Terraform"
  Owner     = "DevOps Team"
}
