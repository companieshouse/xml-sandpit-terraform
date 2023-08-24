module "asg_frontend" {
  source = "git@github.com:companieshouse/terraform-modules//aws/terraform-aws-autoscaling?ref=tags/1.0.195"

  name              = "${var.application}-webserver"
  lc_name           = "${var.application}-fe-launchconfig"
  image_id          = local.frontend_ami_id
  instance_type     = var.frontend_instance_type
  security_groups   = [aws_security_group.frontend.id]
  root_block_device = [
    {
      volume_size = "40"
      volume_type = "gp2"
      encrypted   = true
    },
  ]

  asg_name                       = "${var.application}-fe-asg"
  vpc_zone_identifier            = data.aws_subnets.web.ids
  health_check_type              = "ELB"
  min_size                       = var.asg_frontend_min_size
  max_size                       = var.asg_frontend_max_size
  desired_capacity               = var.asg_frontend_desired_capacity
  health_check_grace_period      = 300
  wait_for_capacity_timeout      = 0
  force_delete                   = true
  enable_instance_refresh        = true
  refresh_min_healthy_percentage = 50
  refresh_triggers               = ["launch_configuration"]
  key_name                       = aws_key_pair.ec2.key_name
  termination_policies           = ["OldestLaunchConfiguration"]
  target_group_arns              = local.asg_frontend_target_group_arns
  iam_instance_profile           = module.frontend_profile.aws_iam_instance_profile.name
  user_data_base64               = data.template_cloudinit_config.frontend.rendered

  tags_as_map = merge(
    local.default_tags,
    {
      ServiceTeam = "${upper(var.application)}-FE-Support"
    }
  )
}

resource "aws_autoscaling_schedule" "frontend_stop" {
  count = var.asg_frontend_enable_shutdown_schedule ? 1 : 0

  scheduled_action_name  = "${var.aws_account}-${var.application}-fe-scheduled-stop"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = var.asg_frontend_scheduled_stop_cron
  autoscaling_group_name = module.asg_frontend.this_autoscaling_group_name
}

resource "aws_autoscaling_schedule" "frontend_start" {
  count = var.asg_frontend_enable_shutdown_schedule ? 1 : 0

  scheduled_action_name  = "${var.aws_account}-${var.application}-fe-scheduled-start"
  min_size               = var.asg_frontend_min_size
  max_size               = var.asg_frontend_max_size
  desired_capacity       = var.asg_frontend_desired_capacity
  recurrence             = var.asg_frontend_scheduled_start_cron
  autoscaling_group_name = module.asg_frontend.this_autoscaling_group_name
}

resource "aws_cloudwatch_log_group" "frontend" {
  for_each = local.cloudwatch_frontend_logs

  name              = each.value["log_group_name"]
  retention_in_days = each.value["log_group_retention"]
  kms_key_id        = local.logs_kms_key_arn

  tags = merge(
    local.default_tags,
    {
      ServiceTeam = "${upper(var.application)}-FE-Support"
    }
  )
}
