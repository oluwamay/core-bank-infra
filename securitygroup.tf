resource "aws_security_group" "webserver_sg" {
  name = "webserver_sg"

  ingress {
    cidr_blocks = data.aws_ip_ranges.az_ip_ranges.cidr_blocks
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }
}

data "aws_ip_ranges" "az_ip_ranges" {
  regions = ["us-east-1"]
  services = [ "EC2" ]
}