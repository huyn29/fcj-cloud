locals {
  project = "fcj"
}
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = "Development"
      Owner       = "Dev"
    }
  }
}

# module "aws_iam" {
#   source = "./modules/IAM"
# }
module "aws_vpc" {
  source                 = "./modules/VPC"
  aws_project_str        = local.project
  cidr_block_str         = "10.10.0.0/16"
  public_subnet_list     = ["10.10.0.0/24", "10.10.1.0/24"]
  private_subnet_list    = ["10.10.2.0/24", "10.10.3.0/24"]
  availability_zone_list = ["us-east-1a", "us-east-1b"]
}
# DATA RESOURCE AMI
data "aws_ami" "ami_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.3.20240219.0-kernel-6.1-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}
resource "local_file" "save_key" {
  filename        = "ssh_key.pem"
  content         = tls_private_key.private_key.private_key_pem
  file_permission = "0400"

}
# AWS KEY PAIR
resource "aws_key_pair" "key_pair" {
  key_name   = "ssh_key"
  public_key = tls_private_key.private_key.public_key_openssh
  tags = {
    "Name" = "${local.project}-key-pair"
  }
}
resource "aws_instance" "public_instance" {
  ami                         = data.aws_ami.ami_amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = module.aws_vpc.public_subnet[0]
  security_groups             = [module.aws_vpc.public_sg_id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair.id
  tags = {
    "Name" = "${local.project}-public-instance"
  }
}
resource "aws_instance" "private_instance" {
  ami                         = data.aws_ami.ami_amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = module.aws_vpc.private_subnet[1]
  security_groups             = [module.aws_vpc.public_sg_id]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.key_pair.id
  tags = {
    "Name" = "${local.project}-private-instance"
  }
}
