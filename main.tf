provider "aws" {
  region = "us-east-1"
  access_key = data.vault_generic_secret.aws_secrets.data["access_key"]
  secret_key = data.vault_generic_secret.aws_secrets.data["secret_key"]
}

locals{
  instance_type = "t2.micro"
  tag_name = "webserver-A"
  
}

resource "aws_instance" "webserver-A" {
  count = 25
  ami = data.aws_ami.ubuntu.id
  instance_type = local.instance_type

  tags = {
    Name = "${local.tag_name}-instance"
  }

  provisioner "file" {
  source = "nginx_install.sh"
  destination = "/tmp/installNginx.sh"
}

provisioner "remote-exec" {
  inline = [
    "chmod u+x /tmp/installNginx.sh",
    "sudo /tmp/installNginx.sh"
  ]
}

connection {
  host = coalesce(self.public_ip, self.private_ip)
  type = "ssh"
  user = var.INSTANCE_USER
  private_key = tls_private_key.ssh_key.private_key_pem
}
}

resource "aws_key_pair" "web_server_key_pair" {
  key_name= "web_server_key_pair"
  public_key = output.public_key.value
}

#Create EBS volume
resource "aws_ebs_volume" "webserver_volume" {
  availability_zone = "us-east-1a"
  size = 2
  tags = {
    Name = "webserver_volume"
  }
}

#Attach EBS volume to instance
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.webserver_volume.id
  instance_id = aws_instance.webserver-A[count.index].id
}