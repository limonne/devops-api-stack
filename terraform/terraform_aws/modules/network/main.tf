locals {
  env               = var.environment
  availability_zone = "eu-west-1a"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform-lab-vpc-${local.env}"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.availability_zone

  lifecycle {
    precondition {
      condition     = local.availability_zone == "eu-west-1a"
      error_message = "Region must be eu-west-1a"
    }
    postcondition {
      condition     = local.availability_zone == "eu-west-1a"
      error_message = "Region must be eu-west-1a"
    }
  }

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraform-lab-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

