resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_bastion" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_bastion_subnet_cidr
  availability_zone = var.public_bastion_az
  tags = {
    Name = "public_bastion_subnet"
  }
}

resource "aws_subnet" "public_web" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_web_subnet_cidr
  availability_zone = var.public_web_az
  tags = {
    Name = "public_web_subnet"
  }
}

resource "aws_subnet" "private_app" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidr
  availability_zone = var.private_app_az
  tags = {
    Name = "private_app_subnet"
  }
}

resource "aws_subnet" "private_db" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidr
  availability_zone = var.private_db_az
  tags = {
    Name = "private_db_subnet"
  }
}
