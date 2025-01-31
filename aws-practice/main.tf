module "vpc" {
  source     = "../modules/vpc"
  vpc_name   = var.vpc_name
  aws_region = var.aws_region
}

/*
module "ec2" {
  source    = "../modules/ec2"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id
}

module "rds" {
  source       = "../modules/rds"
  vpc_id       = module.vpc.vpc_id
  subnet_group = module.vpc.subnet_group
}

module "aurora" {
  source       = "../modules/aurora"
  vpc_id       = module.vpc.vpc_id
  subnet_group = module.vpc.subnet_group
}
*/
