resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_bastion" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_bastion_subnet_cidr
  availability_zone       = var.public_bastion_az
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Bastion Subnet"
  }
}

resource "aws_subnet" "public_web" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_web_subnet_cidr
  availability_zone       = var.public_web_az
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Web Subnet"
  }
}

resource "aws_subnet" "private_app" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidr
  availability_zone = var.private_app_az
  tags = {
    Name = "Private App Subnet"
  }
}

resource "aws_subnet" "private_db" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidr
  availability_zone = var.private_db_az
  tags = {
    Name = "Private DB Subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.internet_gateway
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # Default route for internet access
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Route"
  }
}

resource "aws_route_table_association" "public_bastion" {
  subnet_id      = aws_subnet.public_bastion.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "public_web" {
  subnet_id      = aws_subnet.public_web.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "NAT Gateway Elastic IP"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_bastion.id

  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "NAT Gateway"
  }
}
