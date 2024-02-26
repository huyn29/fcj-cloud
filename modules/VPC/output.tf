output "vpc_id" {
  description = "aws vpc id"
  value       = aws_vpc.vpc.id
}
output "public_subnet" {
  description = "List public subnet"
  value       = aws_subnet.public_subnet[*].id
}
output "private_subnet" {
  description = "List private subnet"
  value       = aws_subnet.private_subnet[*].id
}
output "public_sg_id" {
  description = "Public security id"
  value       = aws_security_group.public_sg.id
}
output "private_sg_id" {
  description = "Private security id"
  value       = aws_security_group.private_sg.id
}
