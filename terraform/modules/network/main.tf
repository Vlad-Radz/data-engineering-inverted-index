resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "Default subnet"
  }
}