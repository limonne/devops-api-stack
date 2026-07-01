output "vpc_id" {
  value = aws_vpc.main.id
}

output "cidr_ipv4" {
  value = aws_vpc.main.cidr_block
}
