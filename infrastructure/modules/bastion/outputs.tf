output "instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "security_group_id" {
  description = "Security group ID of the bastion"
  value       = aws_security_group.bastion.id
}