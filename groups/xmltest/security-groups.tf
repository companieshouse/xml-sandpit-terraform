resource "aws_security_group" "alb_external" {
  count = var.alb_enable_external_access ? 1 : 0

  name_prefix = "sgr-${var.application}-alb-ext-"
  description = "Security group for the external ALB"
  vpc_id      = local.vpc_id

  tags = merge(
    local.default_tags,
    {
      ServiceTeam = "${upper(var.application)}-FE-Support"
    }
  )
}

resource "aws_security_group_rule" "alb_external_ingress" {
  for_each = var.alb_enable_external_access ? local.alb_frontend_ingress_rules : {}

  type              = "ingress"
  from_port         = each.value["from_port"]
  to_port           = each.value["to_port"]
  protocol          = each.value["protocol"]
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_external[0].id
}

resource "aws_security_group" "alb_internal" {
  name_prefix = "sgr-${var.application}-alb-int-"
  description = "Security group for the internal ALB"
  vpc_id      = local.vpc_id

  tags = merge(
    local.default_tags,
    {
      ServiceTeam = "${upper(var.application)}-FE-Support"
    }
  )
}

resource "aws_security_group_rule" "alb_internal_ingress" {
  for_each = local.alb_frontend_ingress_rules

  type              = "ingress"
  from_port         = each.value["from_port"]
  to_port           = each.value["to_port"]
  protocol          = each.value["protocol"]
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.admin.id]
  security_group_id = aws_security_group.alb_internal.id
}

resource "aws_security_group" "backend" {
  name_prefix = "sgr-${var.application}-ec2-bep-"
  description = "Security group for the backend EC2 instances"
  vpc_id      = local.vpc_id

  tags = merge(
    local.default_tags,
    {
      ServiceTeam = "${upper(var.application)}-FE-Support"
    }
  )
}

resource "aws_security_group" "frontend" {
  name_prefix = "sgr-${var.application}-ec2-fe-"
  description = "Security group for the frontend EC2 instances"
  vpc_id      = local.vpc_id

  tags = merge(
    local.default_tags,
    {
      ServiceTeam = "${upper(var.application)}-FE-Support"
    }
  )
}
