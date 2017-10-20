data "aws_vpc" "local" {
  id = "${var.vpc["id"]}"
}
