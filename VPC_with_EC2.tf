provider "aws" {
  region = "us-east-1"
}
// Create VPC
resource "aws_vpc" "my_VPC" {
  cidr_block = "10.10.0.0/16"
}
// Create Subnet

resource "aws_subnet" "my_Publicsubnet" {
  vpc_id     = aws_vpc.my_VPC.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "my_Publicsubnet"
  }
}
// Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_VPC.id

  tags = {
    Name = "my_igw"
  }
}
// Create Route Table
resource "aws_route_table" "my_routetable" {
  vpc_id = aws_vpc.my_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my_routetable"
  }
}
//associate subnet with route table
resource "aws_route_table_association" "my-rt-association" {
  subnet_id      = aws_subnet.my_Publicsubnet.id
  route_table_id = aws_route_table.my_routetable.id
}

// Create Security Group
resource "aws_security_group" "my_SG" {
  name        = "my_SG"
  vpc_id      = aws_vpc.my_VPC.id

  ingress {
    from_port        = 20
    to_port          = 20
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my_SG"
  }
}
// Create EC2 Instance

resource "aws_instance" "my_EC2_Instance" {
  ami           = "ami-03c7d01cf4dedc891" # us-east-1
  instance_type = "t2.micro"
  key_name   = "devops"
  subnet_id = aws_subnet.my_Publicsubnet.id
  vpc_security_group_ids = [aws_security_group.my_SG.id]

}
