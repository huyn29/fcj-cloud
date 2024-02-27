# AWS VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block_str
  enable_dns_hostnames = true
  tags = {
    "Name" = "${var.aws_project_str}-vpc"
  }
}
# AWS PUBLIC SUBNET
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.public_subnet_list)
  cidr_block        = var.public_subnet_list[count.index]
  availability_zone = var.availability_zone_list[count.index]
  tags = {
    "Name" = "${var.aws_project_str}-public-subnet-${count.index}"
  }
}
# AWS PRIVATE SUBNET
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.private_subnet_list)
  cidr_block        = var.private_subnet_list[count.index]
  availability_zone = var.availability_zone_list[count.index]
  tags = {
    "Name" = "${var.aws_project_str}-private-subnet-${count.index}"
  }
}
# AWS INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.aws_project_str}-igw"
  }
}
# AWS ROUTE TABLE
# Create aws route table for public subnet and access throw internet gateway(ouput - internet)
resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "Name" = "${var.aws_project_str}-public-rtb"
  }
}
# Attach route table with public subnet(input - public subnet)
# for k - key, v - value in ..... : output(map: k = > v)
resource "aws_route_table_association" "public_subnet_association" {
  for_each       = { for k, v in aws_subnet.public_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.rtb_public.id
}
# AWS ELASTIC IP
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw]
  tags = {
    "Name" = "${var.aws_project_str}-nat-gw-eip"
  }
}
# AWS NAT GATEWAY
resource "aws_nat_gateway" "nat_gw" {
  depends_on    = [aws_eip.nat_eip]
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[1].id
  tags = {
    "Name" = "${var.aws_project_str}-nat-gw"
  }
}
# AWS ROUTE TABLE 
# Create aws route table for private subnet and access internet throw nat gateway
resource "aws_route_table" "rtb_private" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  # route {

  # }
  tags = {
    "Name" = "${var.aws_project_str}-private-rtb"
  }
}
resource "aws_route_table_association" "private_subnet_association" {
  for_each       = { for k, v in aws_subnet.private_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.rtb_private.id
}
# AWS SECURITY GROUP
resource "aws_security_group" "public_sg" {
  name   = "${var.aws_project_str}-public-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.aws_project_str}-public-sg"
  }
}
resource "aws_security_group" "private_sg" {
  name   = "${var.aws_project_str}-private-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.aws_project_str}-private-sg"
  }
}

