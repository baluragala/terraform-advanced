# Production environment configuration
environment    = "production"
instance_type  = "e2-medium"
instance_count = 3

regions = {
  us_central1 = {
    name                = "us-central1"
    vpc_cidr           = "10.0.0.0/16"
    public_subnet_cidr = "10.0.1.0/24"
    private_subnet_cidr = "10.0.2.0/24"
  }
  us_east1 = {
    name                = "us-east1"
    vpc_cidr           = "10.1.0.0/16"
    public_subnet_cidr = "10.1.1.0/24"
    private_subnet_cidr = "10.1.2.0/24"
  }
  europe_west1 = {
    name                = "europe-west1"
    vpc_cidr           = "10.2.0.0/16"
    public_subnet_cidr = "10.2.1.0/24"
    private_subnet_cidr = "10.2.2.0/24"
  }
}

tags = {
  Project     = "PrismMart"
  Environment = "Production"
  ManagedBy   = "Terraform"
  CostCenter  = "Operations"
}
