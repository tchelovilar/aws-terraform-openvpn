#!/bin/bash

#
PORT_SSH=$1
PORT_OPENVPN=$2
SERVER_IP=$3

KEY_COUNTRY="$4"
KEY_PROVINCE="$5"
KEY_CITY="$6"
KEY_ORG="$7"
KEY_EMAIL="$8"

AWS_REGION="$9"
VPC_NET="${10}"

# Arquivo de variaves do ansible
OPENVPN_VARS="ansible/roles/openvpn/vars/main.yml"

##
## Alterar porta para execucao do ansible, e informacao da AWS no inventario
sed -i 's/^[[:space:]]*ansible_port.*/  ansible_port='$PORT_SSH'/' ansible/iventory/aws/hosts
sed -i 's/^regions =.*/regions = '$AWS_REGION'/' ansible/iventory/aws/ec2.ini


# Fazer conversao do formato da mascara de rede
mask_list=(0.0.0.0 128.0.0.0 192.0.0.0 224.0.0.0 240.0.0.0 248.0.0.0 252.0.0.0 254.0.0.0 255.0.0.0 255.128.0.0 255.192.0.0 255.224.0.0 255.240.0.0 255.248.0.0 255.252.0.0 255.254.0.0 255.255.0.0 255.255.128.0 255.255.192.0 255.255.224.0 255.255.255.240.0 255.255.255.248.0 255.255.255.252.0 255.255.255.254.0 255.255.255.0 255.255.255.128 255.255.255.192 255.255.255.224 255.255.255.240)
net=$(cut -d / -f 1 <<< $VPC_NET)
mask_bits=$(cut -d / -f 2 <<< $VPC_NET)
mask=${mask_list[$mask_bits]}

# Mascara com formato decimal
sed -i 's/^network_mask:.*/network_mask: "'$net' '$mask'"/' $OPENVPN_VARS

# Mascara com formato em bits
sed -i 's/^network:.*/network: '$net'\/'$mask_bits'/' $OPENVPN_VARS

# IP e Porta do Openvpn
sed -i 's/^openvpn_port:.*/openvpn_port: '$PORT_OPENVPN'/' $OPENVPN_VARS
sed -i 's/^openvpn_ip:.*/openvpn_ip: '$SERVER_IP'/' $OPENVPN_VARS


# Variaveis para o Certificado
sed -i 's/^  KEY_COUNTRY:.*/  KEY_COUNTRY: "'$KEY_COUNTRY'"/' $OPENVPN_VARS
sed -i 's/^  KEY_PROVINCE:.*/  KEY_PROVINCE: "'${KEY_PROVINCE/ /_}'"/' $OPENVPN_VARS
sed -i 's/^  KEY_CITY:.*/  KEY_CITY: "'${KEY_CITY/ /_}'"/' $OPENVPN_VARS
sed -i 's/^  KEY_ORG:.*/  KEY_ORG: "'${KEY_ORG/ /_}'"/' $OPENVPN_VARS
sed -i 's/^  KEY_EMAIL:.*/  KEY_EMAIL: "'${KEY_EMAIL/ /_}'"/' $OPENVPN_VARS
