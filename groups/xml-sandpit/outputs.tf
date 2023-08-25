output "frontend_fqdn" {
  value = aws_route53_record.frontend_internal.fqdn
}

output "rds_fqdn" {
  value = aws_route53_record.rds.fqdn
}
