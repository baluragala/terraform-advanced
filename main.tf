# Data source to get the latest Debian image
data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}

# Data source to get available zones in each region
data "google_compute_zones" "available" {
  for_each = var.regions
  region   = each.value.name
}

# Deploy infrastructure to multiple regions using for_each
module "regional_infrastructure" {
  source = "./modules/regional-infrastructure"

  for_each = var.regions

  # Region-specific variables
  region              = each.value.name
  vpc_cidr            = each.value.vpc_cidr
  public_subnet_cidr  = each.value.public_subnet_cidr
  private_subnet_cidr = each.value.private_subnet_cidr

  # Common variables
  project_id     = var.project_id
  environment    = var.environment
  instance_type  = var.instance_type
  instance_count = var.instance_count
  disk_size      = var.disk_size
  allowed_ports  = var.allowed_ports

  # Pass the image data
  boot_image = data.google_compute_image.debian.self_link

  # Pass available zones
  available_zones = data.google_compute_zones.available[each.key].names

  # Tags with region-specific information
  tags = merge(var.tags, {
    Region      = each.value.name
    Environment = var.environment
  })

  providers = {
    google = google
  }
}
