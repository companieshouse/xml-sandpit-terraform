locals {
  default_tags = {
    Terraform   = "true"
    Application = upper(var.application)
    Region      = var.aws_region
    Account     = var.aws_account
  }

  account_kms_secrets  = jsondecode(data.vault_generic_secret.account_kms.data_json)
  logs_kms_key_arn     = local.account_kms_secrets["logs"]
  rds_kms_key_arn      = local.account_kms_secrets["rds"]
  sns_kms_key_arn      = local.account_kms_secrets["sns"]

  account_vpc_secrets  = jsondecode(data.vault_generic_secret.account_vpc.data_json)
  vpc_id               = local.account_vpc_secrets["vpc-id"]

  backend_secrets      = jsondecode(data.vault_generic_secret.backend.data_json)
  app_subnet_pattern   = local.backend_secrets["subnet_pattern"]

  frontend_secrets     = jsondecode(data.vault_generic_secret.frontend.data_json)
  acm_cert_domain      = "*.${local.frontend_secrets["domain_name"]}"
  web_subnet_pattern   = local.frontend_secrets["subnet_pattern"]

  ec2_secrets          = jsondecode(data.vault_generic_secret.ec2.data_json)
  public_key           = local.ec2_secrets["public_key"]

  fess_secrets         = jsondecode(data.vault_generic_secret.fess.data_json)
  fess_token           = local.fess_secrets["fess_token"]

  security_kms_secrets = jsondecode(data.vault_generic_secret.security_kms.data_json)
  ssm_kms_key_arn      = local.security_kms_secrets["session-manager-kms-key-arn"]

  security_s3_secrets  = jsondecode(data.vault_generic_secret.security_s3.data_json)
  alb_logs_bucket_name = local.security_s3_secrets["elb-access-logs-bucket-arn"]
  alb_logs_prefix      = "elb-access-logs"
  ssm_s3_bucket_arn    = local.security_s3_secrets["session-manager-bucket-arn"]
  ssm_s3_bucket_name   = local.security_s3_secrets["session-manager-bucket-name"]

  shared_s3_secrets    = jsondecode(data.vault_generic_secret.shared_s3.data_json)
  config_bucket_name   = local.shared_s3_secrets["config_bucket_name"]
  release_bucket_name  = local.shared_s3_secrets["release_bucket_name"]

  ec2_ami_id           = var.ec2_ami_id == "" ? data.aws_ami.ami[0].id : var.ec2_ami_id

  alb_frontend_ingress_rules    = {
    http = {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
    },
    https = {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
    }
  }

  asg_frontend_target_group_arns = var.alb_enable_external_access ? [
    aws_lb_target_group.asg_frontend_external[0].arn,
    aws_lb_target_group.asg_frontend_internal.arn
  ] : [
    aws_lb_target_group.asg_frontend_internal.arn
  ]

  cloudwatch_backend_logs = {
    for log, map in var.cloudwatch_backend_logs : log => merge(
      map,
      {
        "log_group_name" = "${var.application}-bep-${log}"
      }
    )
  }
  cloudwatch_backend_log_groups = compact([
    for log, map in local.cloudwatch_backend_logs : lookup(map, "log_group_name", "")
  ])

  cloudwatch_frontend_logs = {
    for log, map in var.cloudwatch_frontend_logs : log => merge(
      map,
      {
        "log_group_name" = "${var.application}-fe-${log}"
      }
    )
  }
  cloudwatch_frontend_log_groups = compact([
    for log, map in local.cloudwatch_frontend_logs : lookup(map, "log_group_name", "")
  ])

  backend_ansible_inputs   = {
    s3_bucket_releases         = local.release_bucket_name
    s3_bucket_configs          = local.config_bucket_name
    heritage_environment       = var.environment
    version                    = var.backend_app_version
    default_nfs_server_address = var.nfs_server_address
    mounts_parent_dir          = var.nfs_mount_destination_parent_dir
    mounts                     = var.nfs_mounts
    region                     = var.aws_region
    cw_log_files               = local.cloudwatch_backend_logs
    cw_agent_user              = "root"
  }
  backend_userdata_inputs  = data.vault_generic_secret.backend.data_json

  frontend_ansible_inputs  = {
    s3_bucket_releases         = local.release_bucket_name
    s3_bucket_configs          = local.config_bucket_name
    heritage_environment       = var.environment
    version                    = var.frontend_app_version
    default_nfs_server_address = var.nfs_server_address
    mounts_parent_dir          = var.nfs_mount_destination_parent_dir
    mounts                     = var.nfs_mounts
    region                     = var.aws_region
    cw_log_files               = local.cloudwatch_frontend_logs
    cw_agent_user              = "root"
  }
  frontend_userdata_inputs = data.vault_generic_secret.frontend.data_json
}
