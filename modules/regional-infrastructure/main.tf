# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "prismmart-vpc-${var.region}-${var.environment}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  project = var.project_id
}

# Public Subnet
resource "google_compute_subnetwork" "public" {
  name          = "prismmart-public-${var.region}-${var.environment}"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  project = var.project_id
}

# Private Subnet
resource "google_compute_subnetwork" "private" {
  name          = "prismmart-private-${var.region}-${var.environment}"
  ip_cidr_range = var.private_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  # Enable private Google access for instances without external IPs
  private_ip_google_access = true

  project = var.project_id
}

# Cloud Router for NAT
resource "google_compute_router" "router" {
  name    = "prismmart-router-${var.region}-${var.environment}"
  region  = var.region
  network = google_compute_network.vpc.id

  project = var.project_id
}

# Cloud NAT for private subnet internet access
resource "google_compute_router_nat" "nat" {
  name                               = "prismmart-nat-${var.region}-${var.environment}"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  project = var.project_id

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rule for HTTP/HTTPS traffic
resource "google_compute_firewall" "allow_http_https" {
  name    = "prismmart-allow-http-https-${var.region}-${var.environment}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = var.allowed_ports
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]

  project = var.project_id
}

# Firewall rule for SSH access
resource "google_compute_firewall" "allow_ssh" {
  name    = "prismmart-allow-ssh-${var.region}-${var.environment}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]

  project = var.project_id
}

# Firewall rule for health checks
resource "google_compute_firewall" "allow_health_check" {
  name    = "prismmart-allow-health-check-${var.region}-${var.environment}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  # Google Cloud health check IP ranges
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["web-server"]

  project = var.project_id
}

# Instance template for auto-scaling
resource "google_compute_instance_template" "web_server" {
  name_prefix  = "prismmart-web-${var.region}-${var.environment}-"
  machine_type = var.instance_type
  region       = var.region

  disk {
    source_image = var.boot_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.disk_size
    disk_type    = "pd-standard"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public.id

    access_config {
      # Ephemeral external IP
    }
  }

  tags = ["web-server"]

  metadata = {
    environment = var.environment
    region      = var.region
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    
    # Create a simple HTML page
    cat > /var/www/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>PrismMart - ${var.region}</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #f4f4f4; }
            .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            h1 { color: #333; }
            .info { background: #e7f3ff; padding: 15px; border-radius: 4px; margin: 20px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🛒 PrismMart E-commerce Platform</h1>
            <div class="info">
                <h3>Server Information</h3>
                <p><strong>Region:</strong> ${var.region}</p>
                <p><strong>Environment:</strong> ${var.environment}</p>
                <p><strong>Instance:</strong> $(hostname)</p>
                <p><strong>Zone:</strong> $(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google" | cut -d/ -f4)</p>
            </div>
            <p>Welcome to PrismMart's global e-commerce platform! This server is running in the ${var.region} region.</p>
        </div>
    </body>
    </html>
HTML
    
    systemctl enable nginx
    systemctl start nginx
  EOF

  project = var.project_id

  lifecycle {
    create_before_destroy = true
  }
}



# Health check for the managed instance group
resource "google_compute_health_check" "web_server" {
  name = "prismmart-health-check-${var.region}-${var.environment}"

  timeout_sec        = 5
  check_interval_sec = 10

  http_health_check {
    port         = "80"
    request_path = "/"
    proxy_header = "NONE"
    response     = ""
  }

  project = var.project_id
}

# Auto-scaler for the managed instance group
resource "google_compute_region_autoscaler" "web_server" {
  name   = "prismmart-autoscaler-${var.region}-${var.environment}"
  region = var.region
  target = google_compute_region_instance_group_manager.web_server.id

  autoscaling_policy {
    max_replicas    = 10
    min_replicas    = var.instance_count
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }
  }

  project = var.project_id
}

# Regional Load Balancer - External IP
resource "google_compute_address" "lb_ip" {
  name   = "prismmart-lb-ip-${var.region}-${var.environment}"
  region = var.region

  project = var.project_id
}

# Target Pool for Network Load Balancer
resource "google_compute_target_pool" "web_server" {
  name   = "prismmart-target-pool-${var.region}-${var.environment}"
  region = var.region

  health_checks = [google_compute_http_health_check.web_server_pool.id]

  project = var.project_id
}

# HTTP Health Check for target pool
resource "google_compute_http_health_check" "web_server_pool" {
  name = "prismmart-pool-health-check-${var.region}-${var.environment}"

  timeout_sec        = 5
  check_interval_sec = 10

  port         = 80
  request_path = "/"

  project = var.project_id
}

# Regional Forwarding Rule for Network Load Balancer
resource "google_compute_forwarding_rule" "web_server" {
  name   = "prismmart-forwarding-rule-${var.region}-${var.environment}"
  region = var.region

  ip_address = google_compute_address.lb_ip.address
  port_range = "80"
  target     = google_compute_target_pool.web_server.id

  project = var.project_id
}

# Managed Instance Group
resource "google_compute_region_instance_group_manager" "web_server" {
  name   = "prismmart-mig-${var.region}-${var.environment}"
  region = var.region
  
  base_instance_name = "prismmart-web-${var.region}-${var.environment}"
  target_size        = var.instance_count
  
  version {
    instance_template = google_compute_instance_template.web_server.id
  }
  
  named_port {
    name = "http"
    port = 80
  }
  
  named_port {
    name = "https"
    port = 443
  }
  
  auto_healing_policies {
    health_check      = google_compute_health_check.web_server.id
    initial_delay_sec = 300
  }
  
  target_pools = [google_compute_target_pool.web_server.id]
  
  project = var.project_id
}

# Cloud Storage bucket for application assets
resource "google_storage_bucket" "assets" {
  name     = "prismmart-assets-${var.region}-${var.environment}-${random_id.bucket_suffix.hex}"
  location = var.region

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  project = var.project_id
}

# Random ID for bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
