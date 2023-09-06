resource "aws_route53_record" "frontend_internal" {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = "xmlgw-sandpit"
  type    = "A"

  alias {
    name                   = aws_lb.alb_internal.dns_name
    zone_id                = aws_lb.alb_internal.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "rds" {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = "${lower(var.rds_db_name)}db"
  type    = "CNAME"
  ttl     = "300"
  records = [module.rds.db_instance_address]
}
