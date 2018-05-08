
###
### Ambiente
variable "env" {
  default = {
    name       = "vilar-test" # Usado como prefixo no nome da instancia
    regiao     = "us-east-1"
    keypair    = "marcelo.vilar.rivendel.testes"
    account_id = "485164690107"
  }
}

# Configuracoes da VPC
variable "vpc" {
  default = {
    id = "vpc-a7aaa3de"
    subnet_pub1  = "subnet-3a14fb71"
  }
}


###
### Configuracoes para o Openvpn
variable "openvpn" {
  default = {
    KEY_COUNTRY  = "BR"
    KEY_PROVINCE = "SP"
    KEY_CITY     = "Sao Paulo"
    KEY_ORG      = "Corp"
    KEY_EMAIL    = "it@corp.com.br"
  }
}


###
### EC2

#
variable "ec2_openvpn" {
  default = {
    name          = "openvpn"
    #ami           = "ami-8c1be5f6" # Alterado para buscar AMI mais recente do Amz Linux
    type          = "t2.micro"
    porta_ssh     = "42000"
    porta_openvpn = "34289"
  }
}



###
### Nao alterar
provider "aws" {
  region     = "${var.env["regiao"]}"
  allowed_account_ids = ["${var.env["account_id"]}"]
}
