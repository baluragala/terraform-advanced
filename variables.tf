variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "default_region" {
  description = "Default GCP region"
  type        = string
  default     = "us-central1"
}

variable "regions" {
  description = "List of GCP regions to deploy infrastructure"
  type = map(object({
    name        = string
    vpc_cidr    = string
    public_subnet_cidr = string
    private_subnet_cidr = string
  }))
  default = {
    us_central1 = {
      name        = "us-central1"
      vpc_cidr    = "10.0.0.0/16"
      public_subnet_cidr = "10.0.1.0/24"
      private_subnet_cidr = "10.0.2.0/24"
    }
  }
}

variable "environment" {
  description = "Environment name (staging, production)"
  type        = string
  default     = "staging"
}

variable "instance_type" {
  description = "Compute Engine instance type"
  type        = string
  default     = "e2-medium"
}

variable "instance_count" {
  description = "Number of instances per region"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "allowed_ports" {
  description = "List of allowed ports for firewall rules"
  type        = list(string)
  default     = ["80", "443"]
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "PrismMart"
    ManagedBy   = "Terraform"
  }
}
