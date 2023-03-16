variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "Prefix used to create the name of the resources"
  type        = string
  default     = "sd"
}

variable "vpc_addr_prefix" {
  description = "16 first bits of the VPC prefix, like 10.0"
  type        = string
  default     = "10.0"
}

variable "app_instance_type" {
  description = "Instance type for the compute layer."
  type        = string
  default     = "g4dn.xlarge"
}

variable "owner" {
  description = "The owner of the infrastructure."
  type        = string
}