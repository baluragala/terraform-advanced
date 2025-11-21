# PrismMart Global E-commerce Infrastructure

This Terraform configuration deploys a highly available, multi-region infrastructure for PrismMart's global e-commerce platform on Google Cloud Platform.

## 🏗️ Architecture Overview

The infrastructure includes:
- **VPC Networks**: Dedicated VPC with public and private subnets in each region
- **Compute Engine**: Auto-scaling web servers with regional load balancing
- **Cloud NAT**: Internet access for private subnet resources
- **Cloud Storage**: Regional buckets for application assets
- **Firewall Rules**: Security controls for HTTP/HTTPS traffic
- **Health Checks**: Automated instance health monitoring

## 📁 Project Structure

```
terraform-advanced/
├── main.tf                           # Main configuration with for_each
├── variables.tf                      # Input variables
├── outputs.tf                        # Output values
├── terraform.tf                      # Provider and backend configuration
├── terraform.tfvars.example          # Example variables file
├── staging.tfvars                    # Staging environment config
├── production.tfvars                 # Production environment config
├── deploy.sh                         # Deployment automation script
├── validate.sh                       # Configuration validation script
├── Makefile                          # Build automation
├── FIXES.md                          # Documentation of recent fixes
└── modules/
    └── regional-infrastructure/
        ├── main.tf                   # Regional infrastructure resources
        ├── variables.tf              # Module input variables
        ├── outputs.tf                # Module output values
        └── terraform.tf              # Module provider requirements
```

## 🚀 Prerequisites

### 1. Install Required Tools

```bash
# Install Google Cloud SDK
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Install Terraform (version >= 1.0)
# On macOS with Homebrew:
brew install terraform

# On Linux:
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### 2. Configure Google Cloud

```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project ID (replace with your actual project ID)
export PROJECT_ID="your-gcp-project-id"
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Verify authentication and project
gcloud auth list
gcloud config get-value project
```

### 3. Clone and Setup Repository

```bash
# Clone the repository
git clone https://github.com/baluragala/terraform-advanced.git
cd terraform-advanced

# Make scripts executable
chmod +x deploy.sh validate.sh

# Copy and customize variables
cp terraform.tfvars.example terraform.tfvars
```

### 4. Configure Variables

Edit `terraform.tfvars` with your project details:

```hcl
# Required: Your GCP Project ID
project_id = "your-gcp-project-id"

# Optional: Customize other settings
default_region = "us-central1"
environment    = "staging"
instance_type  = "e2-medium"
instance_count = 2

# Multi-region configuration (add more regions as needed)
regions = {
  us_central1 = {
    name                = "us-central1"
    vpc_cidr           = "10.0.0.0/16"
    public_subnet_cidr = "10.0.1.0/24"
    private_subnet_cidr = "10.0.2.0/24"
  }
}
```

## 🎯 Deployment Commands

### Method 1: Using the Deployment Script (Recommended)

The `deploy.sh` script provides a simple interface for all deployment operations.

#### Create/Deploy Infrastructure

```bash
# Deploy to staging environment
./deploy.sh staging apply

# Deploy to production environment
./deploy.sh production apply
```

#### Plan Deployment (Review Changes)

```bash
# Plan staging deployment
./deploy.sh staging plan

# Plan production deployment
./deploy.sh production plan
```

#### View Outputs

```bash
# View staging outputs
./deploy.sh staging output

# View production outputs
./deploy.sh production output
```

#### Delete Infrastructure

```bash
# Destroy staging infrastructure
./deploy.sh staging destroy

# Destroy production infrastructure
./deploy.sh production destroy
```

### Method 2: Using Makefile

The Makefile provides convenient shortcuts for common operations.

#### Setup and Validation

```bash
# Check prerequisites and setup
make setup

# Validate configuration
make validate

# Format Terraform files
make format
```

#### Deploy Infrastructure

```bash
# Deploy to staging
make staging

# Deploy to production (with confirmation prompt)
make production
```

#### Plan Deployments

```bash
# Plan staging deployment
make plan-staging

# Plan production deployment
make plan-production
```

#### Destroy Infrastructure

```bash
# Destroy staging (with confirmation)
make destroy-staging

# Destroy production (with confirmation)
make destroy-production
```

#### View Outputs

```bash
# Show current workspace outputs
make output
```

### Method 3: Direct Terraform Commands

For advanced users who prefer direct Terraform commands.

#### Initialize and Setup

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format files
terraform fmt -recursive
```

#### Create Workspaces

```bash
# Create and select staging workspace
terraform workspace new staging
terraform workspace select staging

# Create and select production workspace
terraform workspace new production
terraform workspace select production

# List all workspaces
terraform workspace list

# Show current workspace
terraform workspace show
```

#### Deploy Infrastructure

```bash
# Select workspace
terraform workspace select staging

# Plan deployment
terraform plan -var-file=staging.tfvars -var project_id=$PROJECT_ID

# Apply deployment
terraform apply -var-file=staging.tfvars -var project_id=$PROJECT_ID

# Auto-approve (for automation)
terraform apply -var-file=staging.tfvars -var project_id=$PROJECT_ID -auto-approve
```

#### Update Infrastructure

```bash
# Select workspace
terraform workspace select staging

# Plan changes
terraform plan -var-file=staging.tfvars -var project_id=$PROJECT_ID

# Apply changes
terraform apply -var-file=staging.tfvars -var project_id=$PROJECT_ID
```

#### Delete Infrastructure

```bash
# Select workspace
terraform workspace select staging

# Plan destruction
terraform plan -destroy -var-file=staging.tfvars -var project_id=$PROJECT_ID

# Destroy infrastructure
terraform destroy -var-file=staging.tfvars -var project_id=$PROJECT_ID

# Auto-approve destruction (use with caution)
terraform destroy -var-file=staging.tfvars -var project_id=$PROJECT_ID -auto-approve
```

## 📊 Environment-Specific Configurations

### Staging Environment

```bash
# Configuration file: staging.tfvars
environment    = "staging"
instance_type  = "e2-small"      # Smaller instances for cost savings
instance_count = 1               # Minimal instances
regions = {
  us_central1 = {
    name                = "us-central1"
    vpc_cidr           = "10.0.0.0/16"
    public_subnet_cidr = "10.0.1.0/24"
    private_subnet_cidr = "10.0.2.0/24"
  }
}
```

### Production Environment

```bash
# Configuration file: production.tfvars
environment    = "production"
instance_type  = "e2-medium"     # Production-grade instances
instance_count = 3               # Higher availability
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
```

## 🔍 Monitoring and Validation

### Validate Configuration

```bash
# Run validation script
./validate.sh

# Or use Terraform directly
terraform validate
terraform fmt -check -recursive
```

### Check Deployment Status

```bash
# View current state
terraform show

# List all resources
terraform state list

# Get specific resource details
terraform state show 'module.regional_infrastructure["us_central1"].google_compute_instance_template.web_server'

# View outputs
terraform output
terraform output -json
```

### Health Checks

```bash
# Check if instances are running
gcloud compute instances list --filter="name~prismmart"

# Check load balancer status
gcloud compute forwarding-rules list --filter="name~prismmart"

# Check storage buckets
gcloud storage buckets list --filter="name~prismmart"
```

## 🛠️ Troubleshooting

### Common Issues and Solutions

#### 1. Authentication Issues

```bash
# Re-authenticate
gcloud auth login
gcloud auth application-default login

# Verify authentication
gcloud auth list
```

#### 2. API Not Enabled

```bash
# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# List enabled APIs
gcloud services list --enabled
```

#### 3. Quota Exceeded

```bash
# Check quotas
gcloud compute project-info describe --project=$PROJECT_ID

# Request quota increase through GCP Console
```

#### 4. State Lock Issues

```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID

# Or delete the lock manually from GCS bucket
```

#### 5. Resource Already Exists

```bash
# Import existing resource
terraform import 'module.regional_infrastructure["us_central1"].google_compute_network.vpc' projects/$PROJECT_ID/global/networks/existing-network-name

# Or remove from state
terraform state rm 'module.regional_infrastructure["us_central1"].google_compute_network.vpc'
```

### Useful Debug Commands

```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform plan

# Show detailed plan
terraform plan -detailed-exitcode

# Refresh state
terraform refresh -var-file=staging.tfvars -var project_id=$PROJECT_ID

# Show state
terraform show -json | jq '.'
```

## 🔒 Security Best Practices

### State Management

```bash
# The configuration uses GCS backend for state storage
# Ensure the bucket has proper access controls:
gsutil iam get gs://tf-state-manager-xxj2
gsutil iam ch user:your-email@domain.com:objectAdmin gs://tf-state-manager-xxj2
```

### Secrets Management

```bash
# Never commit terraform.tfvars with sensitive data
# Use environment variables for sensitive values:
export TF_VAR_project_id="your-project-id"
terraform plan  # Will use the environment variable
```

### Access Control

```bash
# Use least privilege IAM roles
# Create a service account for Terraform:
gcloud iam service-accounts create terraform-sa
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"
```

## 📈 Scaling and Optimization

### Adding New Regions

1. Update `terraform.tfvars` or environment-specific `.tfvars` file:

```hcl
regions = {
  us_central1 = {
    name                = "us-central1"
    vpc_cidr           = "10.0.0.0/16"
    public_subnet_cidr = "10.0.1.0/24"
    private_subnet_cidr = "10.0.2.0/24"
  }
  asia_southeast1 = {
    name                = "asia-southeast1"
    vpc_cidr           = "10.3.0.0/16"
    public_subnet_cidr = "10.3.1.0/24"
    private_subnet_cidr = "10.3.2.0/24"
  }
}
```

2. Plan and apply the changes:

```bash
terraform plan -var-file=production.tfvars -var project_id=$PROJECT_ID
terraform apply -var-file=production.tfvars -var project_id=$PROJECT_ID
```

### Updating Instance Configuration

1. Modify variables in `.tfvars` file:

```hcl
instance_type  = "e2-standard-2"  # Upgrade instance type
instance_count = 5                # Increase instance count
```

2. Apply changes:

```bash
terraform apply -var-file=production.tfvars -var project_id=$PROJECT_ID
```

## 🎯 Quick Reference

### Essential Commands Summary

| Operation | Command |
|-----------|---------|
| **Setup** | `make setup` |
| **Validate** | `./validate.sh` |
| **Deploy Staging** | `./deploy.sh staging apply` |
| **Deploy Production** | `./deploy.sh production apply` |
| **Plan Changes** | `./deploy.sh staging plan` |
| **View Outputs** | `./deploy.sh staging output` |
| **Destroy Staging** | `./deploy.sh staging destroy` |
| **Destroy Production** | `./deploy.sh production destroy` |

### File Locations

| File | Purpose |
|------|---------|
| `terraform.tfvars` | Your custom configuration |
| `staging.tfvars` | Staging environment settings |
| `production.tfvars` | Production environment settings |
| `FIXES.md` | Recent configuration fixes |
| `deploy.sh` | Deployment automation script |
| `Makefile` | Build automation |

## 📞 Support

For issues and questions:
- Check the troubleshooting section above
- Review `FIXES.md` for recent configuration fixes
- Consult Terraform and GCP documentation
- Contact the DevOps team

---

**🎉 Your PrismMart infrastructure is ready for deployment!**

Start with: `make setup` then `./deploy.sh staging plan` to begin.