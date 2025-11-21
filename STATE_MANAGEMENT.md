# Terraform State Management

This document explains the state management configuration for the PrismMart infrastructure.

## Current Configuration: Local State

The project is currently configured to use **local state management**, which stores the Terraform state file locally in the project directory.

### Local State Configuration

```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  
  # Backend configuration for state management
  # Using local state storage (default)
  # Uncomment and configure for remote state storage
  # backend "gcs" {
  #   bucket = "tf-state-manager-xxj2"
  #   prefix = "prismmart/terraform.tfstate"
  # }
}
```

## State Management Options

### 1. Local State (Current)

**Pros:**
- Simple setup, no additional configuration required
- Fast operations (no network latency)
- Good for development and learning
- No additional costs

**Cons:**
- Not suitable for team collaboration
- No state locking (risk of concurrent modifications)
- State file can be lost if not backed up
- No state versioning or history

**Best for:**
- Individual development
- Learning and experimentation
- Single-user scenarios

### 2. Remote State (GCS Backend)

**Pros:**
- Team collaboration support
- State locking prevents concurrent modifications
- Automatic state versioning and backup
- Centralized state management
- Better security (state stored in cloud)

**Cons:**
- Requires additional setup (GCS bucket)
- Network dependency
- Additional costs for storage
- Slightly slower operations

**Best for:**
- Production environments
- Team collaboration
- CI/CD pipelines
- Multi-user scenarios

## Switching Between State Management Types

### Switch to Remote State (GCS)

1. **Create GCS bucket** (if not exists):
   ```bash
   gsutil mb gs://your-terraform-state-bucket
   gsutil versioning set on gs://your-terraform-state-bucket
   ```

2. **Update terraform.tf**:
   ```hcl
   backend "gcs" {
     bucket = "your-terraform-state-bucket"
     prefix = "prismmart/terraform.tfstate"
   }
   ```

3. **Migrate state**:
   ```bash
   terraform init -migrate-state
   ```

### Switch to Local State

1. **Comment out backend configuration** in `terraform.tf`:
   ```hcl
   # backend "gcs" {
   #   bucket = "your-terraform-state-bucket"
   #   prefix = "prismmart/terraform.tfstate"
   # }
   ```

2. **Migrate state**:
   ```bash
   terraform init -migrate-state
   ```

## State File Security

### Local State Security
- State files contain sensitive information (resource IDs, configurations)
- Ensure `.gitignore` includes `*.tfstate*` to prevent committing state files
- Consider encrypting local storage
- Regular backups recommended

### Remote State Security
- Use IAM roles to control access to state bucket
- Enable bucket versioning for state history
- Consider bucket encryption at rest
- Use state locking to prevent corruption

## Current .gitignore Configuration

The project `.gitignore` is configured to exclude state files:

```gitignore
# Terraform files
*.tfstate
*.tfstate.*
*.tfvars
!*.tfvars.example
!staging.tfvars
!production.tfvars

# Terraform directories
.terraform/
.terraform.lock.hcl
```

## Recommendations

### For Development
- ✅ **Local state** is fine for individual development and learning
- Ensure regular backups of your project directory
- Be careful not to commit state files to version control

### For Production
- 🔄 **Consider remote state** for production deployments
- Use GCS backend with proper IAM controls
- Enable state locking and versioning
- Implement proper backup and disaster recovery

### For Teams
- 🔄 **Remote state is essential** for team collaboration
- Use shared GCS bucket with appropriate permissions
- Implement CI/CD pipelines with remote state
- Document state management procedures for the team

## Migration Commands Reference

```bash
# Check current backend configuration
terraform init

# Migrate from local to remote
terraform init -migrate-state

# Migrate from remote to local
terraform init -migrate-state

# Force reconfigure backend
terraform init -reconfigure

# Copy state to new backend
terraform init -backend-config="bucket=new-bucket-name"
```

## Troubleshooting

### State Lock Issues
```bash
# List current locks
terraform force-unlock LOCK_ID

# Clear stuck locks (use with caution)
terraform force-unlock -force LOCK_ID
```

### State Corruption
```bash
# Backup current state
cp terraform.tfstate terraform.tfstate.backup

# Restore from backup
cp terraform.tfstate.backup terraform.tfstate

# Import existing resources
terraform import resource_type.name resource_id
```

### State Drift
```bash
# Check for drift
terraform plan -detailed-exitcode

# Refresh state
terraform refresh

# Show current state
terraform show
```
