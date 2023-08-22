module "frontend_profile" {
#  source = "git@github.com:companieshouse/terraform-modules//aws/instance_profile?ref=tags/1.0.59"
  source = "git@github.com:companieshouse/terraform-modules//aws/instance_profile?ref=feature/update-instance-profile"

  name       = "xmltest-frontend-profile"
  enable_ssm = true
  cw_log_group_arns = length(local.cloudwatch_frontend_log_groups) > 0 ? flatten([
    formatlist(
      "arn:aws:logs:%s:%s:log-group:%s:*:*",
      var.aws_region,
      data.aws_caller_identity.current.account_id,
      local.cloudwatch_frontend_log_groups
    ),
    formatlist("arn:aws:logs:%s:%s:log-group:%s:*",
      var.aws_region,
      data.aws_caller_identity.current.account_id,
      local.cloudwatch_frontend_log_groups
    ),
  ]) : null
  s3_buckets_write  = [local.ssm_s3_bucket_name]
  instance_asg_arns = [module.asg_frontend.this_autoscaling_group_arn]
  kms_key_refs = [
    "alias/${var.aws_account_short}/euw2/ebs",
    local.ssm_kms_key_arn
  ]
  custom_statements = [
    {
      sid    = "AllowAccessToReleaseBucket",
      effect = "Allow",
      resources = [
        "arn:aws:s3:::${local.release_bucket_name}/*",
        "arn:aws:s3:::${local.release_bucket_name}",
        "arn:aws:s3:::${local.config_bucket_name}/*",
        "arn:aws:s3:::${local.config_bucket_name}"
      ],
      actions = [
        "s3:Get*",
        "s3:List*",
      ]
    }
  ]
}

module "backend_profile" {
#  source = "git@github.com:companieshouse/terraform-modules//aws/instance_profile?ref=tags/1.0.59"
  source = "git@github.com:companieshouse/terraform-modules//aws/instance_profile?ref=feature/update-instance-profile"

  name       = "xmltest-backend-profile"
  enable_ssm = true
  cw_log_group_arns = length(local.cloudwatch_backend_log_groups) > 0 ? flatten([
    formatlist(
      "arn:aws:logs:%s:%s:log-group:%s:*:*",
      var.aws_region,
      data.aws_caller_identity.current.account_id,
      local.cloudwatch_backend_log_groups
    ),
    formatlist("arn:aws:logs:%s:%s:log-group:%s:*",
      var.aws_region,
      data.aws_caller_identity.current.account_id,
      local.cloudwatch_backend_log_groups
    ),
  ]) : null
  s3_buckets_write  = [local.ssm_s3_bucket_name]
  instance_asg_arns = [module.asg_backend.this_autoscaling_group_arn]
  kms_key_refs = [
    "alias/${var.aws_account_short}/euw2/ebs",
    local.ssm_kms_key_arn
  ]
  custom_statements = [
    {
      sid    = "AllowAccessToReleaseBucket",
      effect = "Allow",
      resources = [
        "arn:aws:s3:::${local.release_bucket_name}/*",
        "arn:aws:s3:::${local.release_bucket_name}",
        "arn:aws:s3:::${local.config_bucket_name}/*",
        "arn:aws:s3:::${local.config_bucket_name}"
      ],
      actions = [
        "s3:Get*",
        "s3:List*",
      ]
    }
  ]
}
