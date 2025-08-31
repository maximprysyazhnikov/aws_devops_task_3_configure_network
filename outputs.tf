output "subnet_id" {
  description = "ID of grafana subnet"
  value       = aws_subnet.grafana.id
}

output "security_group_id" {
  description = "ID of the grafana security group"
  value       = aws_security_group.grafana_sg.id
}
