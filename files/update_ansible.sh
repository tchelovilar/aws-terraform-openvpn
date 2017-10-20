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

# Alterar porta para execucao do ansible
sed -i 's/^[[:space:]]*ansible_port.*/  ansible_port='$PORT_SSH'/' ansible/iventory/aws/hosts

# Alterar configuracao do servidor Openvpn
sed -i 's/^port.*/port '$PORT_OPENVPN'/' ansible/roles/openvpn/templates/server.conf

# Alterar configuracao do arquivo do client
sed -i 's/^remote.*/remote '$SERVER_IP' '$PORT_OPENVPN'/' ansible/roles/openvpn/templates/client.conf.sample


# Alterar Variaveis de Certificados
sed -i 's/^export KEY_COUNTRY.*/export KEY_COUNTRY="'$KEY_COUNTRY'" /' ansible/roles/openvpn/templates/vars
sed -i 's/^export KEY_PROVINCE.*/export KEY_PROVINCE="'${KEY_PROVINCE/ /_}'"/' ansible/roles/openvpn/templates/vars


sed -i 's/^export KEY_CITY.*/export KEY_CITY="'${KEY_CITY/ /_}'"/' ansible/roles/openvpn/templates/vars

sed -i 's/^export KEY_ORG.*/export KEY_ORG="'${KEY_ORG/ /_}'" /' ansible/roles/openvpn/templates/vars
sed -i 's/^export KEY_EMAIL.*/export KEY_EMAIL="'${KEY_EMAIL/ /_}'" /' ansible/roles/openvpn/templates/vars
