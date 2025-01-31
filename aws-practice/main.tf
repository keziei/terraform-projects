module "vpc" {
  source     = "../modules/vpc"
  vpc_name   = var.vpc_name
  aws_region = var.aws_region
}

module "ec2" {
  source      = "../modules/ec2"
  vpc_details = module.vpc.vpc_details
  key_name    = var.key_name
}


