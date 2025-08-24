#!/bin/bash

# Terraform Configuration Validation Script
# This script validates the Terraform configuration and checks for common issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Starting Terraform configuration validation..."

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed or not in PATH"
    exit 1
fi

print_success "Terraform is installed"

# Check Terraform version
TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
print_status "Terraform version: $TERRAFORM_VERSION"

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    print_status "Initializing Terraform..."
    terraform init -backend=false
fi

# Format check
print_status "Checking Terraform formatting..."
if terraform fmt -check -recursive; then
    print_success "Terraform files are properly formatted"
else
    print_warning "Some Terraform files need formatting. Run 'terraform fmt -recursive'"
fi

# Validate configuration
print_status "Validating Terraform configuration..."
if terraform validate; then
    print_success "Terraform configuration is valid"
else
    print_error "Terraform configuration validation failed"
    exit 1
fi

# Check for required files
print_status "Checking for required files..."

REQUIRED_FILES=(
    "main.tf"
    "variables.tf"
    "outputs.tf"
    "terraform.tf"
    "staging.tfvars"
    "production.tfvars"
    "modules/regional-infrastructure/main.tf"
    "modules/regional-infrastructure/variables.tf"
    "modules/regional-infrastructure/outputs.tf"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_success "Found: $file"
    else
        print_error "Missing: $file"
        exit 1
    fi
done

# Check for sensitive files that shouldn't be committed
print_status "Checking for sensitive files..."

SENSITIVE_FILES=(
    "terraform.tfvars"
    "*.tfstate"
    "*.tfstate.backup"
)

for pattern in "${SENSITIVE_FILES[@]}"; do
    if ls $pattern 1> /dev/null 2>&1; then
        print_warning "Found sensitive file(s) matching: $pattern"
        print_warning "Make sure these are in .gitignore"
    fi
done

# Check .gitignore
if [ -f ".gitignore" ]; then
    print_success "Found .gitignore file"
    
    # Check if important patterns are in .gitignore
    GITIGNORE_PATTERNS=(
        "*.tfstate"
        "*.tfvars"
        ".terraform/"
    )
    
    for pattern in "${GITIGNORE_PATTERNS[@]}"; do
        if grep -q "$pattern" .gitignore; then
            print_success ".gitignore contains: $pattern"
        else
            print_warning ".gitignore missing pattern: $pattern"
        fi
    done
else
    print_warning "No .gitignore file found"
fi

# Check module structure
print_status "Checking module structure..."

MODULE_DIR="modules/regional-infrastructure"
if [ -d "$MODULE_DIR" ]; then
    print_success "Module directory exists: $MODULE_DIR"
    
    # Check module files
    MODULE_FILES=("main.tf" "variables.tf" "outputs.tf")
    for file in "${MODULE_FILES[@]}"; do
        if [ -f "$MODULE_DIR/$file" ]; then
            print_success "Module file exists: $MODULE_DIR/$file"
        else
            print_error "Module file missing: $MODULE_DIR/$file"
            exit 1
        fi
    done
else
    print_error "Module directory missing: $MODULE_DIR"
    exit 1
fi

# Check for common Terraform best practices
print_status "Checking Terraform best practices..."

# Check if variables have descriptions
if grep -q 'description.*=' variables.tf; then
    print_success "Variables have descriptions"
else
    print_warning "Some variables may be missing descriptions"
fi

# Check if outputs have descriptions
if grep -q 'description.*=' outputs.tf; then
    print_success "Outputs have descriptions"
else
    print_warning "Some outputs may be missing descriptions"
fi

# Check for provider version constraints
if grep -q 'version.*=' terraform.tf; then
    print_success "Provider versions are constrained"
else
    print_warning "Provider versions should be constrained"
fi

# Security checks
print_status "Running security checks..."

# Check for hardcoded secrets (basic check)
if grep -r -i "password\|secret\|key" --include="*.tf" --exclude-dir=".terraform" . | grep -v "description\|variable\|output"; then
    print_warning "Potential hardcoded secrets found. Please review."
else
    print_success "No obvious hardcoded secrets found"
fi

# Check for overly permissive firewall rules
if grep -q "0.0.0.0/0" modules/regional-infrastructure/main.tf; then
    print_warning "Found firewall rules allowing traffic from 0.0.0.0/0. Ensure this is intentional."
fi

print_success "Validation completed successfully!"
print_status "Configuration appears to be ready for deployment"

echo ""
echo "Next steps:"
echo "1. Copy terraform.tfvars.example to terraform.tfvars and customize"
echo "2. Set your GCP project ID: gcloud config set project YOUR_PROJECT_ID"
echo "3. Run: terraform init"
echo "4. Run: terraform plan -var-file=staging.tfvars"
echo "5. Run: terraform apply -var-file=staging.tfvars"
