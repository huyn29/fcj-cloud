variable "aws_project_str" {}
variable "cidr_block_str" {}
variable "public_subnet_list" { type = list(string) }
variable "private_subnet_list" { type = list(string) }
variable "availability_zone_list" { type = list(string) }
