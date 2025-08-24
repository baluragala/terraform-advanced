#!/bin/bash

# PrismMart Infrastructure Deployment Script
# This script helps deploy the infrastructure to different environments

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

# Function to show usage
show_usage() {
    echo "Usage: $0 [ENVIRONMENT] [ACTION]"
    echo ""
    echo "ENVIRONMENT:"
    echo "  staging     Deploy to staging environment"
    echo "  production  Deploy to production environment"
    echo ""
    echo "ACTION:"
    echo "  plan        Show execution plan"
    echo "  apply       Apply the configuration"
    echo "  destroy     Destroy the infrastructure"
    echo "  output      Show outputs"
    echo ""
    echo "Examples:"
    echo "  $0 staging plan"
    echo "  $0 production apply"
    echo "  $0 staging destroy"
}

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    print_error "Missing required arguments"
    show_usage
    exit 1
fi

ENVIRONMENT=$1
ACTION=$2

# Validate environment
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    print_error "Invalid environment. Must be 'staging' or 'production'"
    show_usage
    exit 1
fi

# Validate action
if [[ "$ACTION" != "plan" && "$ACTION" != "apply" && "$ACTION" != "destroy" && "$ACTION" != "output" ]]; then
    print_error "Invalid action. Must be 'plan', 'apply', 'destroy', or 'output'"
    show_usage
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed or not in PATH"
    exit 1
fi

# Check if gcloud is installed and authenticated
if ! command -v gcloud &> /dev/null; then
    print_error "Google Cloud SDK is not installed or not in PATH"
    exit 1
fi

# Check if user is authenticated with gcloud
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    print_error "Not authenticated with Google Cloud. Run 'gcloud auth login'"
    exit 1
fi

# Check if project ID is set
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    print_error "No GCP project set. Run 'gcloud config set project PROJECT_ID'"
    exit 1
fi

print_status "Using GCP Project: $PROJECT_ID"
print_status "Environment: $ENVIRONMENT"
print_status "Action: $ACTION"

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    print_status "Initializing Terraform..."
    terraform init
fi

# Create or select workspace
print_status "Managing Terraform workspace..."
if terraform workspace list | grep -q "$ENVIRONMENT"; then
    terraform workspace select "$ENVIRONMENT"
    print_status "Selected existing workspace: $ENVIRONMENT"
else
    terraform workspace new "$ENVIRONMENT"
    print_status "Created new workspace: $ENVIRONMENT"
fi

# Set variables file
VAR_FILE="${ENVIRONMENT}.tfvars"
if [ ! -f "$VAR_FILE" ]; then
    print_error "Variables file $VAR_FILE not found"
    exit 1
fi

# Add project_id to the command
TF_VARS="-var project_id=$PROJECT_ID -var-file=$VAR_FILE"

# Execute the requested action
case $ACTION in
    "plan")
        print_status "Running Terraform plan..."
        terraform plan $TF_VARS
        ;;
    "apply")
        print_status "Running Terraform apply..."
        if [ "$ENVIRONMENT" == "production" ]; then
            print_warning "You are about to deploy to PRODUCTION environment!"
            read -p "Are you sure you want to continue? (yes/no): " confirm
            if [ "$confirm" != "yes" ]; then
                print_status "Deployment cancelled"
                exit 0
            fi
        fi
        terraform apply $TF_VARS
        print_success "Infrastructure deployed successfully!"
        print_status "Getting outputs..."
        terraform output
        ;;
    "destroy")
        print_warning "You are about to DESTROY infrastructure in $ENVIRONMENT environment!"
        read -p "Are you sure you want to continue? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            print_status "Destruction cancelled"
            exit 0
        fi
        print_status "Running Terraform destroy..."
        terraform destroy $TF_VARS
        print_success "Infrastructure destroyed successfully!"
        ;;
    "output")
        print_status "Getting Terraform outputs..."
        terraform output
        ;;
esac

print_success "Operation completed successfully!"
