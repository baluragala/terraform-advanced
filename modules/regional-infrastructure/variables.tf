variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for this infrastructure"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "instance_type" {
  description = "Compute Engine instance type"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
}

variable "allowed_ports" {
  description = "List of allowed ports for firewall rules"
  type        = list(string)
}

variable "boot_image" {
  description = "Boot image for compute instances"
  type        = string
}

variable "available_zones" {
  description = "List of available zones in the region"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
