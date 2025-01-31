output "vpc_details" {
  description = "Details of the created VPC, including subnets and route tables"
  value = {
    vpc_id   = aws_vpc.main.id
    vpc_cidr = aws_vpc.main.cidr_block
    vpc_igw  = var.internet_gateway
    subnets = {
      public_bastion = {
        id         = aws_subnet.public_bastion.id
        cidr_block = aws_subnet.public_bastion.cidr_block
      }
      public_web = {
        id         = aws_subnet.public_web.id
        cidr_block = aws_subnet.public_web.cidr_block
      }
      private_app = {
        id         = aws_subnet.private_app.id
        cidr_block = aws_subnet.private_app.cidr_block
      }
      private_db = {
        id         = aws_subnet.private_db.id
        cidr_block = aws_subnet.private_db.cidr_block
      }
    }
  }
}

output "vpc_igw" {
  description = "ID of the created Internet Gateway"
  value       = aws_internet_gateway.gw.id
}

