#-------------------------------------------------------------------------------
# Shared Variables
#-------------------------------------------------------------------------------
variable "aws_account" {
  description = "The name of the AWS account we're operating in"
  type        = string
}

variable "aws_account_short" {
  description = "The shorthand name of the AWS account we're operating in"
  type        = string
}

variable "aws_region" {
  default     = "eu-west-2"
  description = "The AWS region to deploy in to"
  type        = string
}

variable "application" {
  default     = "xml-sandpit"
  description = "The name of the application being deployed"
  type        = string
}

variable "environment" {
  description = "The name of the environment for the deployment"
  type        = string
}

#-------------------------------------------------------------------------------
# Frontend & Backend Variables
#-------------------------------------------------------------------------------
variable "cloudwatch_backend_logs" {
  default     = {}
  description = "Map of log file information; used as a basis to create log groups, IAM permissions and to configure remote logging"
  type        = map(
    object({
      file_path           = string
      log_group_retention = number
    })
  )
}

variable "cloudwatch_frontend_logs" {
  default     = {}
  description = "Map of log file information; used as a basis to create log groups, IAM permissions and to configure remote logging"
  type        = map(
    object({
      file_path           = string
      log_group_retention = number
    })
  )
}

variable "backend_ami_id" {
  default     = ""
  description = "The specific AMI ID to use when deploying backend EC2 instances. This will take precedence if provided"
  type        = string
}

variable "backend_ami_version_pattern" {
  default     = "\\d.\\d.\\d"
  description = "The pattern with which to match xml-sandpit AMIs. Used when no AMI ID is provided"
  type        = string
}

variable "backend_instance_type" {
  default     = "t2.small"
  description = "Non-ENA instance size to use for the backend instances"
  type        = string
}

variable "frontend_ami_id" {
  default     = ""
  description = "The specific AMI ID to use when deploying frontend EC2 instances. This will take precedence if provided"
  type        = string
}

variable "frontend_ami_version_pattern" {
  default     = "\\d.\\d.\\d"
  description = "The pattern with which to match xml-sandpit AMIs. Used when no AMI ID is provided"
  type        = string
}

variable "frontend_instance_type" {
  default     = "t2.small"
  description = "Non-ENA instance size to use for the frontend instances"
  type        = string
}

variable "alb_enable_external_access" {
  default     = false
  description = "Controls whether public access is enabled (true) or not (false) via the external ALB"
  type        = bool
}

variable "alb_frontend_health_check_path" {
  default     = "/"
  description = "The service path used during health-checks"
  type        = string
}

variable "alb_frontend_service_port" {
  default     = 80
  description = "The service port used to forward traffic from the ALB to the instance"
  type        = number
}

variable "asg_backend_desired_capacity" {
  description = "The desired capaity of the backend ASG"
  type        = number
}

variable "asg_backend_max_size" {
  description = "The maximum size of the backend ASG"
  type        = number
}

variable "asg_backend_min_size" {
  description = "The minimum size of the backend ASG"
  type        = number
}

variable "asg_backend_enable_shutdown_schedule" {
  default     = false
  description = "Whether the backend shutdown and startup schedule should be enabled (true) or not (false)"
  type        = bool
}

variable "asg_backend_scheduled_stop_cron" {
  default     = "00 20 * * 1-5"
  description = "The UTC cron schedule that defines when the backend should be shutdown, when backend_enable_shutdown_schedule is true"
  type        = string
}

variable "asg_backend_scheduled_start_cron" {
  default     = "00 06 * * 1-5"
  description = "The UTC cron schedule that defines when the backend should be started, when backend_enable_shutdown_schedule is true"
}

variable "asg_frontend_desired_capacity" {
  description = "The desired capaity of the frontend ASG"
  type        = number
}

variable "asg_frontend_max_size" {
  description = "The maximum size of the frontend ASG"
  type        = number
}

variable "asg_frontend_min_size" {
  description = "The minimum size of the frontend ASG"
  type        = number
}

variable "asg_frontend_enable_external_ingress" {
  default     = false
  description = "Controls whether external access is required (true) or not (false) to the frontend"
  type        = bool
}

variable "asg_frontend_enable_shutdown_schedule" {
  default     = false
  description = "Whether the frontend shutdown and startup schedule should be enabled (true) or not (false)"
  type        = bool
}

variable "asg_frontend_scheduled_stop_cron" {
  default     = "00 20 * * 1-5"
  description = "The UTC cron schedule that defines when the frontend should be shutdown, when frontend_enable_shutdown_schedule is true"
  type        = string
}

variable "asg_frontend_scheduled_start_cron" {
  default     = "00 06 * * 1-5"
  description = "The UTC cron schedule that defines when the frontend should be started, when frontend_enable_shutdown_schedule is true"
}

variable "backend_app_version" {
  description = "The release version of the backend application, used to download the artefact when passed to Ansible"
  type        = string
}

variable "frontend_app_version" {
  description = "The release version of the frontend application, used to download the artefact when passed to Ansible"
  type        = string
}

variable "nfs_mount_destination_parent_dir" {
  default     = "/mnt"
  description = "The parent folder that all NFS shares should be mounted inside on the EC2 instance"
  type        = string
}

variable "nfs_mounts" {
  default     = {}
  description = "A map of objects which contains mount details for each mount path required."
  type        = map(
    object({                           # The name of the NFS share as presented from the NFS server
      local_mount_point = string       # The local mount directory if different from the share name
      mount_options     = list(string) # fstab-style NFS mount options
    })
  )
}

variable "nfs_server_address" {
  default     = null
  description = "The name or IP of the environment specific NFS server"
  type        = string
}

#-------------------------------------------------------------------------------
# RDS Variables
#-------------------------------------------------------------------------------
variable "rds_allocated_storage" {
  description = "The amount of storage allocated for the RDS instance in GiB"
  type        = number
}

variable "rds_auto_minor_version_upgrade" {
  default     = false
  description = "Defines whether minor version upgrades are automatically applied during maintenance windows"
  type        = bool
}

variable "rds_backup_retention_period" {
  default     = 7
  description = "The number of days backups are retained before being rotated"
  type        = number
}

variable "rds_backup_window" {
  description = "The UTC time range during which automated backups are created. Cannot overlap with rds_maintenance_window"
  type        = string
}

variable "rds_engine_version" {
  description = "The Oracle engine version to install. When set to the same value as rds_major_engine_version will disable engine version pinning."
  type        = string
}

variable "rds_instance_class" {
  description = "The instance type to use for the RDS deployment"
  type        = string
}

variable "rds_license_model" {
  default     = "license-included"
  description = "The Oracle licensing model to use"
  type        = string
}

variable "rds_log_exports" {
  default     = [
    "alert",
    "audit",
    "listener",
    "trace"
  ]
  description = "The RDS logs to be exported to CloudWatch"
  type        = list(string)
}

variable "rds_maintenance_window" {
  description = "The UTC time range during which a maintenance window is established. Cannot overlap with rds_backup_window"
  type        = string
}

variable "rds_major_engine_version" {
  description = "The Oracle engine major version to install"
  type        = string
}

variable "rds_multi_az" {
  default     = false
  description = "Defines whether the RDS instance is configured for Multi-AZ"
  type        = bool
}

variable "rds_option_group_settings" {
  description = "A list of options that will be set in the RDS instance option group"
  type        = any
}

variable "rds_parameter_group_settings" {
  description = "A list of parameters that will be set in the RDS Parameter Group"
  type        = any
}

variable "rds_performance_insights_enabled" {
  default     = false
  description = "Defines whether Performance Insights are enabled"
  type        = bool
}

variable "rds_schedule_enable" {
  default     = false
  description = "Defines whether the startup and shutdown schedule is enabled"
  type        = bool
}

variable "rds_start_schedule" {
  default     = ""
  description = "Defines the UTC schedule used to start the RDS instance, when rds_schedule_enable is `true`"
  type        = string
}

variable "rds_stop_schedule" {
  default     = ""
  description = "Defines the UTC schedule used to stop the RDS instance, when rds_schedule_enable is `true`"
  type        = string
}

variable "rds_storage_type" {
  default     = "gp3"
  description = "The type of storage used for the RDS instance"
  type        = string
}

