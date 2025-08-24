# PrismMart Infrastructure Makefile
# Provides convenient commands for managing the Terraform infrastructure

.PHONY: help init plan apply destroy output clean format validate staging production

# Default target
help:
	@echo "PrismMart Infrastructure Management"
	@echo "=================================="
	@echo ""
	@echo "Available commands:"
	@echo "  init        Initialize Terraform"
	@echo "  validate    Validate Terraform configuration"
	@echo "  format      Format Terraform files"
	@echo "  staging     Deploy to staging environment"
	@echo "  production  Deploy to production environment"
	@echo "  plan-staging    Plan staging deployment"
	@echo "  plan-production Plan production deployment"
	@echo "  destroy-staging    Destroy staging infrastructure"
	@echo "  destroy-production Destroy production infrastructure"
	@echo "  output      Show Terraform outputs"
	@echo "  clean       Clean Terraform files"
	@echo ""
	@echo "Examples:"
	@echo "  make init"
	@echo "  make plan-staging"
	@echo "  make staging"
	@echo "  make production"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Validate configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate

# Format Terraform files
format:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

# Plan staging deployment
plan-staging:
	@echo "Planning staging deployment..."
	@if ! terraform workspace list | grep -q staging; then \
		terraform workspace new staging; \
	else \
		terraform workspace select staging; \
	fi
	terraform plan -var-file=staging.tfvars

# Plan production deployment
plan-production:
	@echo "Planning production deployment..."
	@if ! terraform workspace list | grep -q production; then \
		terraform workspace new production; \
	else \
		terraform workspace select production; \
	fi
	terraform plan -var-file=production.tfvars

# Deploy to staging
staging:
	@echo "Deploying to staging environment..."
	@if ! terraform workspace list | grep -q staging; then \
		terraform workspace new staging; \
	else \
		terraform workspace select staging; \
	fi
	terraform apply -var-file=staging.tfvars -auto-approve

# Deploy to production
production:
	@echo "Deploying to production environment..."
	@echo "WARNING: This will deploy to PRODUCTION!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ]
	@if ! terraform workspace list | grep -q production; then \
		terraform workspace new production; \
	else \
		terraform workspace select production; \
	fi
	terraform apply -var-file=production.tfvars

# Destroy staging infrastructure
destroy-staging:
	@echo "Destroying staging infrastructure..."
	@echo "WARNING: This will destroy ALL staging resources!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ]
	terraform workspace select staging
	terraform destroy -var-file=staging.tfvars -auto-approve

# Destroy production infrastructure
destroy-production:
	@echo "Destroying production infrastructure..."
	@echo "WARNING: This will destroy ALL production resources!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ]
	terraform workspace select production
	terraform destroy -var-file=production.tfvars

# Show outputs
output:
	@echo "Terraform outputs:"
	terraform output

# Clean Terraform files
clean:
	@echo "Cleaning Terraform files..."
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	rm -f *.tfplan

# Check prerequisites
check-prereqs:
	@echo "Checking prerequisites..."
	@command -v terraform >/dev/null 2>&1 || { echo "Terraform is required but not installed."; exit 1; }
	@command -v gcloud >/dev/null 2>&1 || { echo "Google Cloud SDK is required but not installed."; exit 1; }
	@gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q . || { echo "Not authenticated with Google Cloud."; exit 1; }
	@echo "Prerequisites check passed!"

# Setup development environment
setup: check-prereqs
	@echo "Setting up development environment..."
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		echo "Created terraform.tfvars from example. Please edit it with your values."; \
	fi
	make init
	make validate
	@echo "Setup complete!"
