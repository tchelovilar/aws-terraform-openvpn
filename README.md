# Openvpn via Terrafom e Ansible

### Features ###

* Criação da Instância e Security Group.
* Configuração centralizada do Openvpn no arquivo do Terraform.
* Configuração do serviço do Openvpn com autenticação via usuáio e certificados.
* Script para criação de usuário exportando configurações e certificados
  para um arquivo único pronto para usar.


### Pré Requisitos ###

 * Instalação do Ansible, Terraform e aws cli.
   - http://docs.ansible.com/ansible/latest/intro_installation.html
   - https://www.terraform.io/intro/getting-started/install.html
   - https://aws.amazon.com/cli
 * Ter um usuário com permissões da API AWS para criação da instância
 * Chave pública para acesso a instância


## Como usar ##

### Configuração do Ambiente ###

Altere o arquivo `variables.tf` alterando os parâmetros de de configuração da
do ambiente da conta AWS onde vai ser configurado o Openvpn.

Nesse arquivo estão os parâmetros de região da AWS, chave ssh a aser utilizada,
ID de subnet e parâmetros do Openvpn.


### Preparação ###

**Baixar módulos do Terraform**
Execute o comando abaixo na pasta raiz para preparar para o uso do Terraform:
```
terraform init
```


**Carregar chave pública**
Execute o comando abaixo para carregar para o ssh agent a chave pública a ser utilizada,
substituindo `<arquivo>` pelo arquivo com a chave:
```
ssh-add <arquivo>
```



**Configurar chaves de acesso para API da AWS e Terraform**
Usando as mesmas chaves do passo anterior, faça a configuração de acesso do AWS cli:
```
aws configure
```


### Executar a instalação ###
Tendo executado os passos anteriores e estando o arquivo `variables.tf` devidamente
configurado, primeiramente execute o `plan` do Terraform para que seja validada as
configurações e verificar as alterações a serem realizadas:
```
terraform plan
```

Se tudo correr bem, e você estiver certo de estar com as configurações da conta
correta, aplique as alterações:
```
terraform apply
```

O processo leva em torno de 5 minutos, no final vai ser printado na tela as
informações de acesso SSH da instância.


### Adicionar usuários a VPN ###

Para facilitar a adição de novos usuários, utilize o script abaixo, ele vai gerar
um arquivo `.ovpn` contendo todas as configurações e certificados necessários
para conexão:
```
vpnuser create <nome_do_usuario>
```


# TODO

* Ajustar a parte de revogação, para remover os usuários
* Mudar a criação do certificado para um CN diferente do nome, registando esse
  nas informações do usuário Linux, para caso precise recriar o certificado.
* Página web para alteração de senha.
