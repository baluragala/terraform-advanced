output "vpc_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = google_compute_subnetwork.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = google_compute_subnetwork.private.id
}

output "instance_names" {
  description = "Names of the compute instances"
  value       = google_compute_region_instance_group_manager.web_server.base_instance_name
}

output "instance_external_ips" {
  description = "External IP addresses of the instances"
  value       = google_compute_address.lb_ip.address
}

output "instance_zones" {
  description = "Zones where instances are deployed"
  value       = var.available_zones
}

output "storage_bucket_name" {
  description = "Name of the Cloud Storage bucket"
  value       = google_storage_bucket.assets.name
}

output "storage_bucket_url" {
  description = "URL of the Cloud Storage bucket"
  value       = google_storage_bucket.assets.url
}

output "load_balancer_ip" {
  description = "IP address of the load balancer"
  value       = google_compute_address.lb_ip.address
}

output "nat_gateway_ips" {
  description = "IP addresses of the NAT gateway"
  value       = google_compute_router_nat.nat.name
}

output "health_check_id" {
  description = "ID of the health check"
  value       = google_compute_health_check.web_server.id
}

output "backend_service_id" {
  description = "ID of the backend service"
  value       = google_compute_region_backend_service.web_server.id
}

output "url_map_id" {
  description = "ID of the URL map"
  value       = google_compute_region_url_map.web_server.id
}

output "managed_instance_group_id" {
  description = "ID of the managed instance group"
  value       = google_compute_region_instance_group_manager.web_server.id
}

output "autoscaler_id" {
  description = "ID of the autoscaler"
  value       = google_compute_region_autoscaler.web_server.id
}
