output "vpc_networks" {
  description = "VPC networks created in each region"
  value = {
    for region, module in module.regional_infrastructure : region => {
      vpc_id         = module.vpc_id
      vpc_name       = module.vpc_name
      public_subnet  = module.public_subnet_id
      private_subnet = module.private_subnet_id
    }
  }
}

output "compute_instances" {
  description = "Compute instances created in each region"
  value = {
    for region, module in module.regional_infrastructure : region => {
      instance_names    = module.instance_names
      instance_ips      = module.instance_external_ips
      instance_zones    = module.instance_zones
    }
  }
}

output "storage_buckets" {
  description = "Cloud Storage buckets created in each region"
  value = {
    for region, module in module.regional_infrastructure : region => {
      bucket_name = module.storage_bucket_name
      bucket_url  = module.storage_bucket_url
    }
  }
}

output "load_balancer_ips" {
  description = "Load balancer IP addresses for each region"
  value = {
    for region, module in module.regional_infrastructure : region => {
      ip_address = module.load_balancer_ip
    }
  }
}

output "nat_gateway_ips" {
  description = "NAT Gateway IP addresses for each region"
  value = {
    for region, module in module.regional_infrastructure : region => {
      nat_ips = module.nat_gateway_ips
    }
  }
}
