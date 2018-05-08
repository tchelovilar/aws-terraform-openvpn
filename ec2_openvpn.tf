###
### EC2
resource "aws_instance" "openvpn" {
  #ami           = "${var.ec2_openvpn["ami"]}"
  ami                         = "${data.aws_ami.amazon_linux.image_id}"
  instance_type               = "${var.ec2_openvpn["type"]}"
  subnet_id                   = "${var.vpc["subnet_pub1"]}"
  key_name                    = "${var.env["keypair"]}"
  user_data                   = "${data.template_file.user_data_openvpn.rendered}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.sg_openvpn.id}"]

  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
  }

  tags {
    Name = "${var.env["name"]}-${var.ec2_openvpn["name"]}"
    Role = "openvpn"
  }

  lifecycle {
    ignore_changes  = ["ami", "user_data"]
    prevent_destroy = true
  }
}

###
### Elastic IP
resource "aws_eip" "openvpn" {
  instance = "${aws_instance.openvpn.id}"
  vpc      = true
}

###
### Execucao de scripts para a configuracao do Openvpn
resource "null_resource" "ansible" {
  depends_on = ["aws_instance.openvpn"]

  triggers {
    openvpn_id = "${aws_instance.openvpn.id}"
  }

  provisioner "local-exec" {
    command = "./files/update_ansible.sh ${var.ec2_openvpn["porta_ssh"]} ${var.ec2_openvpn["porta_openvpn"]} ${aws_eip.openvpn.public_ip} '${var.openvpn["KEY_COUNTRY"]}' '${var.openvpn["KEY_PROVINCE"]}' '${var.openvpn["KEY_CITY"]}' '${var.openvpn["KEY_ORG"]}' '${var.openvpn["KEY_EMAIL"]}' ${var.env["regiao"]} ${data.aws_vpc.local.cidr_block}"
  }

  provisioner "local-exec" {
    # O sleep eh por conta de um delay que tem apos criar a instancia e aplicar o
    # user_data
    command = "sleep 40; cd ansible; ansible-playbook -e 'host_key_checking=False' -i iventory/aws/ pb_openvpn.yml ; cd .."
  }
}

###
###
output "Openvpn_Acesso" {
  value = "IP: ${aws_eip.openvpn.public_ip} Porta SSH: ${var.ec2_openvpn["porta_ssh"]}"
}

###
### Security Group
resource "aws_security_group" "sg_openvpn" {
  name        = "sg_openvpn"
  description = "Permissoes para instancia openvpn"
  vpc_id      = "${var.vpc["id"]}"

  lifecycle {
    ignore_changes = ["ingress", "egress"]
  }

  ingress {
    from_port   = "${var.ec2_openvpn["porta_ssh"]}"
    to_port     = "${var.ec2_openvpn["porta_ssh"]}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Porta SSH"
  }

  ingress {
    from_port   = "${var.ec2_openvpn["porta_openvpn"]}"
    to_port     = "${var.ec2_openvpn["porta_openvpn"]}"
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Porta Openvpn"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.aws_vpc.local.cidr_block}"]
    description = "Local VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###
###
data "template_file" "user_data_openvpn" {
  template = "${file("files/user_data_openvpn")}"

  vars {
    SSH_PORT = "${var.ec2_openvpn["porta_ssh"]}"
  }
}

# Debug
# output "Userdata" {
#   value = "${data.template_file.user_data_openvpn.rendered}"
# }

###
### Buscar AMI mais recente do Amazon Linux
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
