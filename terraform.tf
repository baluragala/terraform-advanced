terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Backend configuration for state management
  # Uncomment and configure for remote state storage
  backend "gcs" {
    bucket = "tf-state-manager-xxj2"
    prefix = "prismmart/terraform.tfstate"
  }
}

# Default provider configuration
provider "google" {
  project = var.project_id
  region  = var.default_region
}

# Additional provider configurations for multi-region deployment
provider "google" {
  alias   = "us_central1"
  project = var.project_id
  region  = "us-central1"
}
