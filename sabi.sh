#!/bin/bash

# SABI
USUARIO_SABI='00nnnnnn' # exemplo: 00123456
SENHA_SABI='xxxxxxxxxxxx'

bold=`tput bold`
normal=`tput sgr0`


# FUNÇÕES 
function press_enter {
    echo ""
    echo -n "Enter para sair"
    read
    clear
}

function biblioteca {
	echo -e "${bold}BIBLIOTECA${normal} \n";
	printf '%-73s %-10s\n' "${bold}Livro" "Prazo${normal}"

	# descobre o link de login
	linksessao=$(curl --silent 'http://sabi.ufrgs.br/F' | grep -o 'http://.*/F/.*?func=bor-loan&adm_library=URS50"')
	# loga e pega link de renovação
	linkrenova=$(curl --silent --request POST $linksessao --data "adm_library=URS50&func=bor-loan&bor_id=${USUARIO_SABI}&bor_verification=${SENHA_SABI}&ssl_flag=Y&func=login-session&login_source=&bor_library=URS50" | grep -o 'http://.*/F/.*?func=bor-loan-renew-all')
	# renova livros de fato e devolve a tabela com os livros
	IFS='
'
	livros=( $(curl --silent $linkrenova | tr '\n' ' ' | grep -oP '(?<=<!--filename: bor-renew-all-body).*?(?=</tr>)' ) )	

	for i in "${livros[@]}"
	do
		campos=( $(echo -n "$i" | grep -oP '(?<=nowrap>).*?(?=</td>)'))
		printf '%-69s %-10s\n' "$( echo ${campos[0]} | cut -c1-75)" "${campos[4]}"
	done

	unset IFS

	# TODO e se não estiver conectado à internet? Salvar a tabela poderia ser interessante para consultas offline
	# TODO exibir débito
	# TODO exibir nome do logado
	press_enter
}

biblioteca
