
# define variables
variable "region" {
  description = "region of the project on aws"

}

variable "subnet_cidr" {
  description = "cidr block of subnet"

}

variable "vpc_cidr" {
  description = "cidr block of vpc"

}

variable "Environment" {}
variable "Owner" {}


# define cloud provider
provider "aws" {
  region = var.region
}

# define vpc
resource "aws_vpc" "project_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    "Name" : "project_vpc"
    "Environment" : var.Environment
    "Owner" : var.Owner
  }

}

# define subnet 
resource "aws_subnet" "project_public_subnet" {
  vpc_id     = aws_vpc.project_vpc.id
  cidr_block = var.subnet_cidr

  tags = {
    "Name" : "project_public_subnet"
    "Environment" : var.Environment
    "Owner" : var.Owner
  }

}

# define internet gateway
resource "aws_internet_gateway" "project_internet_gateway" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    "Name" : "project_internet_gateway"
    "Environment" : var.Environment
    "Owner" : var.Owner
  }

}

# define route table
resource "aws_route_table" "project_route_table" {
  vpc_id = aws_vpc.project_vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_internet_gateway.id
  }

  tags = {
    "Name" : "project_route_table"
    "Environment" : var.Environment
    "Owner" : var.Owner
  }
}

# define route table association to connect subnet with route table
resource "aws_route_table_association" "project_route_table_subnet_assosiation" {
  subnet_id      = aws_subnet.project_public_subnet.id
  route_table_id = aws_route_table.project_route_table.id

}
