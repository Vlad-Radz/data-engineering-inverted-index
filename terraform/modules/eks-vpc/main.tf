#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "vpc_eks" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({"App" = "pyspark-demo", "kubernetes.io/cluster/${var.cluster_name}" = "shared"})
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnet_eks" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc_eks.id

  tags = tomap({"App" = "pyspark-demo", "kubernetes.io/cluster/${var.cluster_name}" = "shared"})
}

resource "aws_internet_gateway" "ig_eks" {
  vpc_id = aws_vpc.vpc_eks.id

  tags = {
    App = "pyspark-demo"
  }
}

resource "aws_route_table" "rt_eks" {
  vpc_id = aws_vpc.vpc_eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig_eks.id
  }
}

resource "aws_route_table_association" "rt_association_eks" {
  count = 2

  subnet_id      = aws_subnet.subnet_eks.*.id[count.index]
  route_table_id = aws_route_table.rt_eks.id
}