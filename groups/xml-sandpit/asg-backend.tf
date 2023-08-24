module "asg_backend" {
  source = "git@github.com:companieshouse/terraform-modules//aws/terraform-aws-autoscaling?ref=tags/1.0.196"

  name              = "${var.application}-bep"
  lc_name           = "${var.application}-bep-launchconfig"
  image_id          = local.backend_ami_id
  instance_type     = var.backend_instance_type
  security_groups   = [aws_security_group.backend.id]
  root_block_device = [
    {
      volume_size = "40"
      volume_type = "gp2"
      encrypted   = true
    },
  ]

  asg_name                       = "${var.application}-bep-asg"
  vpc_zone_identifier            = data.aws_subnets.app.ids
  health_check_type              = "EC2"
  min_size                       = var.asg_backend_min_size
  max_size                       = var.asg_backend_max_size
  desired_capacity               = var.asg_backend_desired_capacity
  health_check_grace_period      = 300
  wait_for_capacity_timeout      = 0
  force_delete                   = true
  enable_instance_refresh        = true
  refresh_min_healthy_percentage = 50
  key_name                       = aws_key_pair.ec2.key_name
  termination_policies           = ["OldestLaunchConfiguration"]
  iam_instance_profile           = module.backend_profile.aws_iam_instance_profile.name
  user_data_base64               = data.template_cloudinit_config.backend.rendered

  tags_as_map = merge(
    local.default_tags,
    {
      ServiceTeam = "${upper(var.application)}-FE-Support"
    }
  )
}

resource "aws_autoscaling_schedule" "backend_stop" {
  count = var.asg_backend_enable_shutdown_schedule ? 1 : 0

  scheduled_action_name  = "${var.aws_account}-${var.application}-bep-scheduled-stop"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = var.asg_backend_scheduled_stop_cron
  autoscaling_group_name = module.asg_backend.this_autoscaling_group_name
}

resource "aws_autoscaling_schedule" "backend_start" {
  count = var.asg_backend_enable_shutdown_schedule ? 1 : 0

  scheduled_action_name  = "${var.aws_account}-${var.application}-bep-scheduled-start"
  min_size               = var.asg_backend_min_size
  max_size               = var.asg_backend_max_size
  desired_capacity       = var.asg_backend_desired_capacity
  recurrence             = var.asg_backend_scheduled_start_cron
  autoscaling_group_name = module.asg_backend.this_autoscaling_group_name
}

resource "aws_cloudwatch_log_group" "backend" {
  for_each = local.cloudwatch_backend_logs

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
