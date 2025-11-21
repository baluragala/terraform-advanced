# 1. ⭐ Introduction to Terraform

Terraform is an **open-source Infrastructure as Code (IaC)** tool created by HashiCorp for **automating infrastructure provisioning**.

### **Why Terraform?**

- Multi-cloud support (AWS, Azure, GCP)
- Declarative syntax (HCL)
- Version-controlled infrastructure
- Plan → Apply workflow
- State management → predictable infra changes

### **Terraform in GCP**

Terraform uses the **Google provider** to manage GCP resources:

- Compute Engine
- VPC networks
- Cloud SQL
- IAM
- GKE
- Cloud Storage
- Load balancers
  and many more.

---

# 2. 🏗 **Terraform Workflow (Core Concepts)**

```
Write → Plan → Apply → Destroy
```

### **1. terraform init**

- Initializes Terraform directory
- Downloads provider plugins
- Sets up backend configuration

### **2. terraform plan**

- Shows the execution plan
- What will be created/updated/destroyed?

### **3. terraform apply**

- Applies the changes
- Makes actual calls to GCP APIs

### **4. terraform destroy**

- Deletes all resources in the state file

---

# 3. 📁 Terraform Configuration Structure (HCL)

### Minimal structure:

```
main.tf        → resources
variables.tf   → input variables
outputs.tf     → outputs
provider.tf    → provider configuration
terraform.tfvars → values for variables
```

---

# 4. 🌐 Provider Configuration (GCP)

**provider.tf:**

```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
```

---

# 5. 🧱 Key Terraform Components

## **a) Variables**

Used for dynamic inputs.

```hcl
variable "project_id" {}
variable "region" {
  default = "us-central1"
}
```

## **b) Outputs**

Display computed values.

```hcl
output "vm_ip" {
  value = google_compute_instance.demo.network_interface[0].access_config[0].nat_ip
}
```

## **c) Local Values**

Reusable expressions inside Terraform.

```hcl
locals {
  instance_name = "web-${var.env}"
}
```

## **d) Resource Blocks**

Define actual infrastructure.

```hcl
resource "google_storage_bucket" "logs" {
  name     = "my-logs-bucket"
  location = "US"
}
```

## **e) Data Sources**

Read existing resources.

```hcl
data "google_compute_network" "default" {
  name = "default"
}
```

---

# 6. 🧩 Terraform State Management

State stores the **current infrastructure snapshot**.

### **Local State**

`.terraform.tfstate`

### **Remote State (recommended)**

Use **GCS bucket**:

```hcl
terraform {
  backend "gcs" {
    bucket = "my-tf-state-bucket"
    prefix = "prod/"
  }
}
```

Benefits:
✔ locking
✔ versioning
✔ team collaboration
✔ prevents accidental parallel updates

---

# 7. 🔄 Terraform Plan and Apply

```
terraform plan
terraform apply
terraform destroy
```

Terraform shows:

- additions
- modifications
- deletions

---

# 8. 🔧 Working Example: Create a VM on GCP

### **main.tf**

```hcl
resource "google_compute_instance" "demo" {
  name         = "tf-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network       = "default"
    access_config {}
  }
}
```

### Commands:

```
terraform init
terraform plan
terraform apply
```

---

# 9. 🕸 Create a Custom VPC + Subnet

```hcl
resource "google_compute_network" "vpc" {
  name = "custom-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-1"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/24"
}
```

---

# 10. 🔥 Create Firewall Rule

```hcl
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}
```

---

# 11. 🎛 Modules: Reusable Terraform Components

### Why use modules?

- Repeatable patterns
- Clean code split
- Standardization
- Multi-environment support

### Example Directory:

```
modules/
  vm/
    main.tf
    variables.tf
environments/
  dev/
  prod/
```

---

# 12. 🔒 Terraform for IAM on GCP

```hcl
resource "google_project_iam_member" "viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "user:dev@example.com"
}
```

IAM use cases:

- Least privilege enforcement
- Role-based access
- Adding service accounts

---

# 13. 🗄 Terraform for Cloud Storage (Buckets)

```hcl
resource "google_storage_bucket" "data" {
  name     = "data-${var.project_id}"
  location = "US"
  versioning {
    enabled = true
  }
}
```

---

# 14. 🐬 Terraform for Cloud SQL (MySQL)

```hcl
resource "google_sql_database_instance" "mysql" {
  name             = "mydb"
  database_version = "MYSQL_8_0"

  settings {
    tier = "db-f1-micro"
  }
}
```

---

# 15. 🐳 Terraform for GKE Kubernetes Cluster

```hcl
resource "google_container_cluster" "primary" {
  name     = "tf-gke"
  location = var.region

  initial_node_count = 1
}
```

---

# 16. 🔄 Terraform Lifecycle Rules

### **Prevent accidental deletion**

```hcl
lifecycle {
  prevent_destroy = true
}
```

### **Ignore fields (e.g., auto-updated by GCP)**

```hcl
lifecycle {
  ignore_changes = [metadata]
}
```

---

# 17. 🌍 Multi-Environment Setup

### Folder Structure:

```
prod/
  terraform.tfvars
dev/
  terraform.tfvars
common/
  modules/
```

---

# 18. 🧪 Testing Terraform

Use:

- `terraform validate`
- `terraform fmt`
- `terraform plan`
- `tflint` (linting)
- `terratest` (Go-based tests)

---

# 19. 🛠 Use Cases (Solved Examples)

### **Use Case 1: Standard Web App Infra**

Provision:

- VPC
- Subnet
- VM instance
- Firewall
- External IP
- Startup script

**Solution:** Combine resources using modules.

---

### **Use Case 2: Multi-Environment Deployment**

Goal: dev/stage/prod with different size VMs.

**Solution:**

- Use variable files
- Backend buckets
- Workspace separation

---

### **Use Case 3: Secure Cloud SQL with Private IP**

Provision:

- SQL instance
- Private IP
- Service networking peering

**Solution:**
Use:

- `google_compute_global_address`
- `google_service_networking_connection`
- `google_sql_database_instance`

---

### **Use Case 4: GKE Cluster with Node Pools**

Deploy:

- regional cluster
- autoscaling node pool

Modules + variables handle cluster sizing.

---

### **Use Case 5: Push Terraform infra via CI/CD**

Implement GCP Cloud Build pipeline:

```
steps:
  - name: hashicorp/terraform
    entrypoint: "terraform"
    args: ["apply", "-auto-approve"]
```

---

# 20. ✔ Best Practices

### **State Management**

- Always use remote backend (GCS)
- Enable locking with GCS + Dynamo-like mechanism (GCS handles versioning)

### **Modular Design**

- Reusable modules
- One module = one logical component

### **Naming Conventions**

- Standard names across environments

### **Security**

- Never commit secrets
- Use Secret Manager
- Use service-account impersonation

### **Version Pinning**

```
version = "~> 5.0"
```

### **Review Plans Before Apply**

- Use `terraform plan` in PR checks

---

# 21. 🥊 Terraform vs Deployment Manager vs Ansible

| Feature            | Terraform | Deployment Manager | Ansible          |
| ------------------ | --------- | ------------------ | ---------------- |
| Multi-cloud        | ✔         | ❌                 | ❌               |
| HCL syntax         | ✔         | ❌                 | YAML             |
| State mgmt         | ✔         | internal           | none             |
| Community modules  | ✔✔✔       | ✔                  | ✔✔               |
| Drift detection    | ✔         | ❌                 | ❌               |
| Infra provisioning | ✔         | ✔                  | ❌ (config mgmt) |

---

# 22. 🎓 Summary

Terraform is the **industry-standard IaC tool** for GCP, offering:

- Declarative provisioning
- Reusable modules
- Multi-environment rollout
- Version-controlled infra
- Predictable deployments
- Powerful integration with CI/CD

Perfect for:

- Enterprise GCP workloads
- Multi-cloud infrastructure
- DevOps workflows
- Automated, secure, repeatable deployments

---

If you want, I can generate:

📌 A **full PPT** of these notes
📌 A **hands-on lab manual**
📌 A **mini-project** (VPC + VM + SQL + LB)
📌 A **20–40 MCQ quiz** for learners
📌 A **Terraform module library** tailored for your GCP training

Just tell me!
