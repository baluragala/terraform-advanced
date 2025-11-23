# Staging environment configuration
environment    = "staging"
instance_type  = "e2-micro"
instance_count = 1

regions = {
  us_central1 = {
    name                = "us-central1"
    vpc_cidr            = "10.0.0.0/16"
    public_subnet_cidr  = "10.0.1.0/24"
    private_subnet_cidr = "10.0.2.0/24"
  }
}

tags = {
  Project     = "PrismMart"
  Environment = "Staging"
  ManagedBy   = "Terraform"
  CostCenter  = "Development"
}
