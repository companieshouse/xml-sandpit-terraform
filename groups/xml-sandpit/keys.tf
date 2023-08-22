resource "aws_key_pair" "ec2" {
  key_name   = var.application
  public_key = local.public_key
}
