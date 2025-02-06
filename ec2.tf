/*provider "aws" {
  region = "us-east-1"
}*/

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Subnets
resource "aws_subnet" "subnets" {
  count = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)
}

# Security Group
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch EC2 Instances in each Subnet
resource "aws_instance" "instances" {
  count         = 9
  ami           = "ami-0c55b159cbfafe1f0"  # Update with your region-specific AMI
  instance_type = "t2.micro"
  subnet_id     = element(aws_subnet.subnets[*].id, count.index % 3)
  security_groups = [aws_security_group.instance_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > /home/ec2-user/hello.txt
              EOF

  tags = {
    Name = "Instance-${count.index}"
  }
}

output "instance_public_ips" {
  value = aws_instance.instances[*].public_ip
}
