resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "file" "private_key" {
  content = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/ssh_key.pem"
}

output "public_key" {
  value= tls_private_key.ssh_key.public_key_openssh
  sensitive = true
}