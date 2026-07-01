locals {
  sg_name = "CustomSG"
  db_name = "terraform"
}

module "network" {
  source      = "../../modules/network"
  environment = var.environment
}

module "security" {
  source    = "../../modules/security"
  vpc_id    = module.network.vpc_id
  cidr_ipv4 = module.network.cidr_ipv4
  name      = local.sg_name
}

module "compute" {
  source = "../../modules/compute"
  region = var.region
}

module "database" {
  source = "../../modules/database"
  name   = local.db_name
}
