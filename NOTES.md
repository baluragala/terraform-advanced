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

### variables & data types

- primitive types => string, number, bool
- complex types => list ( ["80","8080"] ), set (["dev","prod"]), map
- list => ordered collection of values

```

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}


```

- set => unique values, unordered

```

variable "tags" {
  type    = set(string)
  default = ["dev", "prod"]
}


```

- map => key - value pairs

```

variable "instance_amis" {
  type = map(string)
  default = {
    us-east-1 = "ami-123456"
    us-west-1 = "ami-789012"
  }
}



```

- object => structured data with name attributes

```

variable "db_config" {
  type = object({
    engine   = string
    version  = number
    storage  = number
  })
  default = {
    engine  = "mysql"
    version = 8
    storage = 20
  }
}


```

### Variables file

- you can store variales in a file with .tfvars extension
- you can use this variables file on `terraform apply -var-file="terrafrom.tfvars"`

### Modules

- Reusability
- Abstraction
- Consistency
- Organization ( managing code well )

### Types Of Modules

- Root
- Child
- Published Modules

### data sources

```

data "google_compute_image" "debian" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_compute_instance" "default" {
  name         = "vm-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
    }
  }
}


```

```

# Fetch existing VPC
data "google_compute_network" "default" {
  name = "default"
}

# Create a new VM inside this VPC
resource "google_compute_instance" "app" {
  name         = "app-vm"
  machine_type = "e2-small"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = data.google_compute_network.default.self_link
    access_config {} # enables external IP
  }
}


```

### Workspaces

- is an isolated instance of TF state
- by default every TF project has one workspace => default
- you can create new workspaces to manage multiple environments
