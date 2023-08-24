data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "cert" {
  domain      = local.acm_cert_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_ami" "backend_ami" {
  count = var.backend_ami_id == "" ? 1 : 0

  most_recent = true
  name_regex  = "^xml-sandpit-ami-${var.backend_ami_version_pattern}$"
  owners      = [local.backend_ami_owner_id]
}

data "aws_ami" "frontend_ami" {
  count = var.frontend_ami_id == "" ? 1 : 0

  most_recent = true
  name_regex  = "^xml-sandpit-ami-${var.frontend_ami_version_pattern}$"
  owners      = [local.frontend_ami_owner_id]
}

data "aws_ec2_managed_prefix_list" "admin" {
  name = "administration-cidr-ranges"
}

data "aws_iam_role" "rds_enhanced_monitoring" {
  name = "irol-rds-enhanced-monitoring"
}

data "aws_security_group" "rds_shared" {
  filter {
    name   = "group-name"
    values = ["sgr-rds-shared-001*"]
  }
}

data "aws_security_group" "rds_ingress_groups" {
  count = length(var.rds_ingress_groups)

  filter {
    name   = "group-name"
    values = [var.rds_ingress_groups[count.index]]
  }
}

data "aws_subnets" "app" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = [local.app_subnet_pattern]
  }
}

data "aws_subnets" "web" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = [local.web_subnet_pattern]
  }
}

data "aws_subnets" "rds" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = [local.rds_subnet_pattern]
  }
}

data "vault_generic_secret" "account_ids" {
  path = "aws-accounts/account-ids"
}

data "vault_generic_secret" "account_kms" {
  path = "aws-accounts/${var.aws_account}/kms"
}

data "vault_generic_secret" "account_vpc" {
  path = "aws-accounts/${var.aws_account}/vpc"
}

data "vault_generic_secret" "backend" {
  path = "applications/${var.aws_account}-${var.aws_region}/${var.application}/backend"
}

data "vault_generic_secret" "ec2" {
  path = "applications/${var.aws_account}-${var.aws_region}/${var.application}/ec2"
}

data "vault_generic_secret" "fess" {
  path = "applications/${var.aws_account}-${var.aws_region}/${var.application}/fess"
}

data "vault_generic_secret" "frontend" {
  path = "applications/${var.aws_account}-${var.aws_region}/${var.application}/frontend"
}

data "vault_generic_secret" "rds" {
  path = "applications/${var.aws_account}-${var.aws_region}/${var.application}/rds"
}

data "vault_generic_secret" "security_kms" {
  path = "aws-accounts/security/kms"
}

data "vault_generic_secret" "security_s3" {
  path = "aws-accounts/security/s3"
}

data "vault_generic_secret" "shared_s3" {
  path = "aws-accounts/shared-services/s3"
}
