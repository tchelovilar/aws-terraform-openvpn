#!/bin/bash


#
CONFIG_SAMPLE=/etc/openvpn/client.conf.sample
CONFIG_SERVER=/etc/openvpn/server.conf
DST_CONF=/tmp
DIR_KEYS=/etc/openvpn/keys

#
cd /usr/share/easy-rsa/3/
source /etc/openvpn/vars

#
function create() {
  user=$1
  conf="$DST_CONF/${user}.ovpn"

  # verifica se o usuario ja existe
  egrep -q "CN=${user}/" ${DIR_KEYS}/index.txt
  if [ $? -eq 0 ] ; then
    echo -e "\e[31;1mERRO: Usuario ja existe.\e[m"
    exit 1
  fi

  #
  ret=$(/usr/share/easy-rsa/3/easyrsa build-client-full $user nopass  2>&1 )
  if [ $? != 0 ] ; then
    echo -e "\e[31;1mFalha na execucao do easy-rsa, segue o retorno:\e[m"
    echo -e "$ret"
    exit 1
  fi

  # Configurao Cliente
  cp $CONFIG_SAMPLE $conf
  echo -e "<ca>\n$(cat ${DIR_KEYS}/ca.crt )\n</ca>\n" >> $conf
  echo -e "<tls-auth>\n$(cat ${DIR_KEYS}/ta.key )\n</tls-auth>\n" >> $conf
  echo -e "<cert>\n$(cat ${DIR_KEYS}/issued/${user}.crt )\n</cert>\n" >> $conf
  echo -e "<key>\n$(cat ${DIR_KEYS}/private/${user}.key )\n</key>\n" >> $conf

  # Remover chave de usuario
  rm -rf ${DIR_KEYS}/private/${user}.key

  #
  adduser -s /bin/null $user
  passwd $user

  echo -e "\n\e[32;1mArquivo de configuracao do usuario disponivel em:\e[m\n$conf"
}


function list {
  echo "# Usuários ativos"
  egrep  -v "(^R|CN=server/)" ${DIR_KEYS}/index.txt | sed -r "s/.*CN=([[:alnum:]\.\-\_]*)\/.*/\1/g"
}


function revoke {
  user="$1"
  egrep -q "^V.*CN=${user}/" ${DIR_KEYS}/index.txt
  if [ $? != 0 ] ; then
    echo -e "\e[31;1mUsuário não existe.\e[m"
    exit 1
  fi
  ret=$(./easyrsa --batch revoke $1)
  if ! egrep -q "^crl-verify" ${CONFIG_SERVER} ; then
    echo "crl-verify keys/crl.pem" >> ${CONFIG_SERVER}
    /etc/init.d/openvpn reload
  fi
  ./easyrsa gen-crl > /dev/null 2>&1
}

#
case $1 in
  create)
    create $2
  ;;
  list)
    list $2
  ;;
  revoke)
    revoke $2
  ;;
  *)
    echo -e "Uso:"
    echo -e "- Criar usuários"
    echo -e "  vpnuser create <nome_usuario>"
    echo -e "\n- Listar usuários existentes"
    echo -e "  vpnuser list"
    echo -e "\n- Revogar certificado"
    echo -e "  vpnuser revoke"
  ;;
esac
