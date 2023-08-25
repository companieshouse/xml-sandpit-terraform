output "frontend_external_alb_name" {
  value = var.alb_enable_external_access ? aws_lb.alb_external[0].dns_name : "N/A"
}

output "frontend_internal_alb_name" {
  value = aws_lb.alb_internal.dns_name
}

output "frontend_internal_fqdn" {
  value = aws_route53_record.frontend_internal.fqdn
}

output "rds_fqdn" {
  value = aws_route53_record.rds.fqdn
}
