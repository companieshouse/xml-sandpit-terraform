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

resource "aws_security_group_rule" "alb_external_egress" {
  count = var.alb_enable_external_access ? 1 : 0

  description       = "Allow egress traffic to all"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_external[0].id
}

resource "aws_security_group_rule" "alb_external_ingress" {
  for_each = var.alb_enable_external_access ? local.alb_frontend_ingress_rules : {}

  description       = "External ${each.key} access"
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

resource "aws_security_group_rule" "alb_internal_egress" {
  description       = "Allow egress traffic to all"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_internal.id
}

resource "aws_security_group_rule" "alb_internal_ingress" {
  for_each = local.alb_frontend_ingress_rules

  description       = "Internal ${each.key} access"
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

resource "aws_security_group_rule" "backend_egress" {
  description       = "Allow egress traffic to all"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend.id
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

resource "aws_security_group_rule" "frontend_egress" {
  description       = "Allow egress traffic to all"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend.id
}

resource "aws_security_group_rule" "frontend_alb_ingress" {
  for_each = local.frontend_alb_sg_ids

  description              = "Allow traffic from ${each.key} ALB"
  type                     = "ingress"
  from_port                = var.alb_frontend_service_port
  to_port                  = var.alb_frontend_service_port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.frontend.id
}

resource "aws_security_group" "rds" {
  name_prefix = "sgr-${var.application}-rds-"
  description = "Security group for the RDS instance"
  vpc_id      = local.vpc_id

  tags = merge(
    local.default_tags,
    {
      ServiceTeam = "${upper(var.application)}-DBA-Support"
    }
  )
}

resource "aws_security_group_rule" "rds_egress" {
  description       = "Allow egress traffic to all"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds_ingress_admin_oracle" {
  description       = "Oracle DB administrative access"
  type              = "ingress"
  from_port         = 1521
  to_port           = 1521
  protocol          = "tcp"
  security_group_id = aws_security_group.rds.id
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.admin.id]
}

resource "aws_security_group_rule" "rds_ingress_admin_oem" {
  description       = "Oracle Enterprise Manager administrative access"
  type              = "ingress"
  from_port         = 5500
  to_port           = 5500
  protocol          = "tcp"
  security_group_id = aws_security_group.rds.id
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.admin.id]
}

resource "aws_security_group_rule" "rds_ingress_instances" {
  for_each = local.rds_ingress_instance_sg_map

  description              = "Allow traffic from ${each.key} instances"
  type                     = "ingress"
  from_port                = 1521
  to_port                  = 1521
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = each.value
}

resource "aws_security_group_rule" "rds_ingress_services" {
  for_each = local.rds_ingress_services_sg_map

  description              = "Allow traffic from ${each.value["name"]}"
  type                     = "ingress"
  from_port                = 1521
  to_port                  = 1521
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = each.key
}
