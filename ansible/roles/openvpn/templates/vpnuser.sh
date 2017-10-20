#!/bin/bash


#
CONFIG_SAMPLE=/etc/openvpn/client.conf.sample
DST_CONF=/tmp
DIR_KEYS=/etc/openvpn/keys


#
function create() {
  user=$1
  conf="$DST_CONF/${user}.ovpn"

  # verifica se o usuario ja existe
  egrep -q "CN=${user}" ${DIR_KEYS}/index.txt
  if [ $? -eq 0 ] ; then
    echo -e "\e[31;1mERRO: Usuario ja existe.\e[m"
    exit 1
  fi

  #
  cd /usr/share/easy-rsa/2.0/
  source /etc/openvpn/vars
  ret=$(/usr/share/easy-rsa/2.0/pkitool --batch $user 2>&1 )
  if [ $? != 0 ] ; then
    echo -e "\e[31;1mFalha na execucao do pkitool, segue o retorno:\e[m"
    echo -e "$ret"
    exit 1
  fi

  # Configurao Cliente
  cp $CONFIG_SAMPLE $conf
  echo -e "<ca>\n$(cat ${DIR_KEYS}/ca.crt )\n</ca>\n" >> $conf
  echo -e "<tls-auth>\n$(cat ${DIR_KEYS}/ta.key )\n</tls-auth>\n" >> $conf
  echo -e "<cert>\n$(cat ${DIR_KEYS}/${user}.crt )\n</cert>\n" >> $conf
  echo -e "<key>\n$(cat ${DIR_KEYS}/${user}.key )\n</key>\n" >> $conf

  # Remover chave de usuario
  rm -rf ${DIR_KEYS}/${user}.key

  #
  adduser -s /bin/null $user
  passwd $user

  echo -e "\n\e[32;1mArquivo de configuracao do usuario disponivel em:\e[m\n$conf"
}



#
case $1 in
  create)
    create $2
  ;;
  *)
    echo "Uso: vpnuser create <nome_usuario>"
  ;;
esac
