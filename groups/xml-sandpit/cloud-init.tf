data "template_file" "frontend_userdata" {
  template = file("${path.module}/cloud-init/templates/frontend_user_data.tpl")

  vars = {
    REGION               = var.aws_region
    HERITAGE_ENVIRONMENT = title(var.environment)
    FRONTEND_INPUTS      = local.frontend_userdata_inputs
    ANSIBLE_INPUTS       = jsonencode(local.frontend_ansible_inputs)
  }
}

data "template_cloudinit_config" "frontend" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.frontend_userdata.rendered
  }
}

data "template_file" "backend_userdata" {
  template = file("${path.module}/cloud-init/templates/backend_user_data.tpl")

  vars = {
    REGION               = var.aws_region
    HERITAGE_ENVIRONMENT = title(var.environment)
    BACKEND_INPUTS       = local.backend_userdata_inputs
    FESS_TOKEN           = local.fess_token
    ANSIBLE_INPUTS       = jsonencode(local.backend_ansible_inputs)
    BACKEND_CRON_ENTRIES = file("${path.module}/cloud-init/templates/${var.aws_account}-${var.aws_region}/backend_cron.tpl")
  }
}

data "template_cloudinit_config" "backend" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.backend_userdata.rendered
  }
}
