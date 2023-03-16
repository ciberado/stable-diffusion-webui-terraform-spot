output "ec2_spot_instance_id" {
  description = "The ID of the instance"
  value       = module.app.id
}

output "ec2_spot_instance_arn" {
  description = "The ARN of the instance"
  value       = module.app.arn
}

output "ec2_spot_instance_public_dns" {
  description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = module.app.public_dns
}

output "ec2_spot_instance_public_ip" {
  description = "The public IP address assigned to the instance, if applicable. NOTE: If you are using an aws_eip with your instance, you should refer to the EIP's address directly and not use `public_ip` as this field will change after the EIP is attached"
  value       = module.app.public_ip
}

output "spot_request_state" {
  description = "The current request state of the Spot Instance Request"
  value       = module.app.spot_request_state
}

output "spot_instance_id" {
  description = "The Instance ID (if any) that is currently fulfilling the Spot Instance request"
  value       = module.app.spot_instance_id
}