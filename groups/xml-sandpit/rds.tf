module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.1.0"

  create_db_parameter_group         = "true"
  create_db_subnet_group            = "true"

  identifier                        = join("-", ["rds", var.application, var.environment, "001"])
  engine                            = "oracle-se2"
  major_engine_version              = var.rds_major_engine_version
  engine_version                    = var.rds_engine_version
  auto_minor_version_upgrade        = var.rds_auto_minor_version_upgrade
  deletion_protection               = true
  instance_class                    = var.rds_instance_class
  multi_az                          = var.rds_multi_az
  license_model                     = var.rds_license_model

  allocated_storage                 = var.rds_allocated_storage
  storage_type                      = var.rds_storage_type
  iops                              = local.rds_storage_iops
  storage_throughput                = local.rds_storage_throughput
  storage_encrypted                 = true
  kms_key_id                        = local.rds_kms_key_arn

  db_name                           = var.rds_db_name
  username                          = local.rds_username
  password                          = local.rds_password
  manage_master_user_password       = false
  port                              = "1521"

  backup_window                     = var.rds_backup_window
  backup_retention_period           = var.rds_backup_retention_period
  maintenance_window                = var.rds_maintenance_window
  skip_final_snapshot               = "false"
  final_snapshot_identifier_prefix  = "${var.application}-final-deletion-snapshot"
  publicly_accessible               = false

  # Enhanced Monitoring
  monitoring_interval                   = "30"
  monitoring_role_arn                   = data.aws_iam_role.rds_enhanced_monitoring.arn
  enabled_cloudwatch_logs_exports       = var.rds_log_exports
  performance_insights_enabled          = var.rds_performance_insights_enabled
  performance_insights_kms_key_id       = local.rds_kms_key_arn
  performance_insights_retention_period = 7

  subnet_ids                        = data.aws_subnets.rds.ids
  vpc_security_group_ids            = [
    aws_security_group.rds.id,
    data.aws_security_group.rds_shared.id
  ]

  family                            = join("-", ["oracle-se2", var.rds_major_engine_version])
  parameters                        = var.rds_parameter_group_settings
  options                           = concat(
    [{
      option_name                    = "OEM"
      port                           = "5500"
      vpc_security_group_memberships = [aws_security_group.rds.id]
    }],
    var.rds_option_group_settings
  )

  timeouts = {
    "create" : "80m",
    "delete" : "80m",
    "update" : "80m"
  }

  tags = merge(
    local.default_tags,
    {
      ServiceTeam = "${upper(var.application)}-DBA-Support"
    }
  )
}

module "rds_start_stop_schedule" {
  source = "git@github.com:companieshouse/terraform-modules//aws/rds_start_stop_schedule?ref=tags/1.0.197"

  rds_schedule_enable = var.rds_schedule_enable
  rds_instance_id     = module.rds.db_instance_identifier
  rds_start_schedule  = var.rds_start_schedule
  rds_stop_schedule   = var.rds_stop_schedule

  depends_on = [
    module.rds
  ]
}

module "rds_cloudwatch_alarms" {
  source = "git@github.com:companieshouse/terraform-modules//aws/oracledb_cloudwatch_alarms?ref=tags/1.0.197"

  db_instance_id         = module.rds.db_instance_identifier
  db_instance_shortname  = var.rds_db_name
  alarm_actions_enabled  = var.rds_alarm_actions_enabled
  alarm_name_prefix      = "Oracle RDS"
  alarm_topic_name       = var.rds_alarm_topic_name
  alarm_topic_name_ooh   = var.rds_alarm_topic_name_ooh

  depends_on = [
    module.rds
  ]
}
