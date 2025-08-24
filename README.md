# PrismMart Global E-commerce Infrastructure

This Terraform configuration deploys a highly available, multi-region infrastructure for PrismMart's global e-commerce platform on Google Cloud Platform.

## Architecture Overview

The infrastructure includes:

- **VPC Networks**: Dedicated VPC with public and private subnets in each region
- **Compute Engine**: Auto-scaling web servers with load balancing
- **Cloud NAT**: Internet access for private subnet resources
- **Cloud Storage**: Regional buckets for application assets
- **Firewall Rules**: Security controls for HTTP/HTTPS traffic
- **Health Checks**: Automated instance health monitoring

## Advanced Terraform Features Used

- **Modules**: Reusable regional infrastructure module
- **For_each**: Deploy infrastructure across multiple regions
- **Data Sources**: Dynamic retrieval of latest OS images and availability zones
- **Workspaces**: Environment separation (staging/production)
- **Variables**: Fully parameterized configuration
- **Providers**: Multi-region deployment support

## Directory Structure

```
terraform-advanced/
├── main.tf                           # Main configuration
├── variables.tf                      # Input variables
├── outputs.tf                        # Output values
├── terraform.tf                      # Provider and backend configuration
├── terraform.tfvars.example          # Example variables file
├── README.md                         # This file
└── modules/
    └── regional-infrastructure/
        ├── main.tf                   # Regional infrastructure resources
        ├── variables.tf              # Module input variables
        └── outputs.tf                # Module output values
```

## Prerequisites

1. **Google Cloud SDK**: Install and configure the gcloud CLI
2. **Terraform**: Version >= 1.0
3. **GCP Project**: With billing enabled and necessary APIs activated

### Required GCP APIs

Enable the following APIs in your GCP project:

```bash
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```

## Quick Start

### 1. Clone and Configure

```bash
# Clone the repository
git clone <repository-url>
cd terraform-advanced

# Copy and customize the variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project ID and preferences
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Create Workspaces (Optional)

```bash
# Create staging workspace
terraform workspace new staging
terraform workspace select staging

# Create production workspace
terraform workspace new production
terraform workspace select production
```

### 4. Plan and Apply

```bash
# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

## Configuration

### Variables

Key variables to customize in `terraform.tfvars`:

| Variable         | Description                           | Default          |
| ---------------- | ------------------------------------- | ---------------- |
| `project_id`     | GCP Project ID                        | Required         |
| `regions`        | Map of regions and their CIDR blocks  | us-central1 only |
| `environment`    | Environment name (staging/production) | staging          |
| `instance_type`  | Compute Engine instance type          | e2-medium        |
| `instance_count` | Number of instances per region        | 2                |

### Multi-Region Deployment

To deploy to multiple regions, update the `regions` variable:

```hcl
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
}
```

## Workspace Management

This configuration supports Terraform workspaces for environment separation:

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new <environment>

# Switch workspace
terraform workspace select <environment>

# Show current workspace
terraform workspace show
```

## Outputs

After deployment, the configuration provides:

- **VPC Information**: Network IDs and subnet details
- **Instance Details**: IP addresses and zones
- **Load Balancer IPs**: External access points
- **Storage Buckets**: Asset storage locations

View outputs:

```bash
terraform output
```

## Security Considerations

- **Firewall Rules**: Only HTTP/HTTPS traffic allowed from internet
- **Private Subnets**: Backend resources isolated from direct internet access
- **Cloud NAT**: Secure outbound internet access for private resources
- **Health Checks**: Automated monitoring and healing

## Scaling and High Availability

- **Auto Scaling**: Automatic scaling based on CPU utilization
- **Multi-Zone**: Instances distributed across availability zones
- **Load Balancing**: Traffic distributed across healthy instances
- **Health Checks**: Automatic replacement of unhealthy instances

## Cost Optimization

- **Right-sizing**: Use appropriate instance types for workload
- **Auto Scaling**: Scale down during low traffic periods
- **Regional Resources**: Minimize cross-region data transfer costs
- **Storage Classes**: Use appropriate storage classes for different data types

## Troubleshooting

### Common Issues

1. **API Not Enabled**: Ensure required GCP APIs are enabled
2. **Permissions**: Verify service account has necessary IAM roles
3. **Quotas**: Check GCP quotas for compute resources
4. **CIDR Conflicts**: Ensure subnet CIDRs don't overlap

### Useful Commands

```bash
# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Show current state
terraform show

# Refresh state
terraform refresh

# Destroy infrastructure
terraform destroy
```

## Contributing

1. Follow Terraform best practices
2. Update documentation for any changes
3. Test in staging environment first
4. Use meaningful commit messages

## Support

For issues and questions:

- Check the troubleshooting section
- Review Terraform and GCP documentation
- Contact the DevOps team
