module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  name   = var.name
  vpc_id = var.vpc_id

  ingress_rules = {
    https = {
      from_port   = 443
      ip_protocol = "tcp"
      cidr_ipv4   = var.cidr_ipv4
    }
  }
}
