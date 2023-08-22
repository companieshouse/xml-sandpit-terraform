resource "aws_lb" "alb_internal" {
  name                       = "alb-${var.application}-internal-001"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_internal.id]
  subnets                    = data.aws_subnets.web.ids

  enable_deletion_protection = true

  access_logs {
    bucket  = local.alb_logs_bucket_name
    prefix  = local.alb_logs_prefix
    enabled = true
  }
}

resource "aws_lb_listener" "alb_internal_http" {
  load_balancer_arn = aws_lb.alb_internal.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb_internal_https" {
  load_balancer_arn = aws_lb.alb_internal.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_frontend_internal.arn
  }
}

resource "aws_lb_target_group" "asg_frontend_internal" {
  name        = "tg-${var.application}-fe-int"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = local.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = var.alb_frontend_health_check_path
    port                = var.alb_frontend_service_port
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    protocol            = "HTTP"
    matcher             = "200-399"
  }
}
