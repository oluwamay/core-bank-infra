variable "ROOT_TOKEN" {
  description = "ROOT token for vault"
  sensitive = true
}

variable "VAULT_ADDR"{
  description= "Hashicorp vault web address"
}

variable "INSTANCE_USER"{
  description = "value of the user to be used for ssh"
  default = "ubuntu"
}