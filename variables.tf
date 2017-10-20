
###
### Ambiente
variable "env" {
  default = {
      name    = "vilar-test" # Usado como prefixo no nome da instancia
			regiao  = "us-east-1"
      keypair = "marcelo.vilar"
    }
}

# Configuracoes da VPC
variable "vpc" {
  default = {
    id = "vpc-b43b3bb3"
    subnet_pub1  = "subnet-3ad4325"
  }
}


###
### Configuracoes para o Openvpn
variable "openvpn" {
  default = {
		KEY_COUNTRY  = "BR"
		KEY_PROVINCE = "PR"
		KEY_CITY     = "Maringa"
		KEY_ORG      = "Vilar"
		KEY_EMAIL    = "tchelovilar@gmail.com"
	}
}


###
### EC2

# graylog
variable "ec2_openvpn" {
  default = {
    name          = "openvpn"
    #ami           = "ami-8c1be5f6" # Alterado para buscar AMI mais recente do Amz Linux
    type          = "t2.micro"
		porta_ssh     = "42000"
		porta_openvpn = "34289"
  }
}




### Variaveis de autenticacao, nao coloque os valores aqui, defina as variaveis
### no console da seguinte forma:
# export TF_VAR_aws_access_key="valor"
# export TF_VAR_aws_secret_key="valor"
variable "aws_access_key" {}
variable "aws_secret_key" {}


###
### Nao alterar
provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region     = "${var.env["regiao"]}"
}
