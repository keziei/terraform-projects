data "aws_ami" "amazon-linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Amazon Linux 2023 AMI * x86_64 HVM kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_web.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_name

  tags = {
    Name = "EC2 Web"
  }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_db.id
  vpc_security_group_ids = [aws_security_group.db.id]
  key_name               = var.key_name

  tags = {
    Name = "EC2 DB"
  }
}

resource "aws_instance" "bastiion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_bastion.id
  vpc_security_group_ids = [aws_security_group.bastiion.id]
  key_name               = var.key_name

  tags = {
    Name = "EC2 Public Bastion"
  }
}
