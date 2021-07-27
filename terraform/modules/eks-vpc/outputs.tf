output "vpc_eks_id" {
  value = "${aws_vpc.vpc_eks.id}"
}

output "subnet_ids" {
  value = "${aws_subnet.subnet_eks[*].id}"
}