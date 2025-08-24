# Terraform Advanced

### Benefits

- Consistency:
- Version Control:
- Efficiency

### Workflow

- terraform init
- terraform plan
- terraform apply

### Core Blocks

- provider:
- resource:
- variable:

### Backend

- where TF store its state file ( terraform.state )
- by default TF store state locally
- Choose remote backend => GCS

### Why - Remote Backend

- Team collaboration
- Reliability
- Security
- Locking & Consistency

## Steps to configure backend

- clone the repo
- in GCP account create bucket
- open terraform.tf file, uncomment backed configuration

```
    backend "gcs" {
        bucket = "tf-state-manager-xxj2"
        prefix = "prismmart/terraform.tfstate"
    }
```

- run `terraform init`
