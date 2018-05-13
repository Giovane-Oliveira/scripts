#!/bin/bash
setterm -foreground white -background blue

if [ "$USER" != "root" ] ; then
dialog --msgbox "Você não está como super usuário!" 7 40 
exit
fi


menu() {
clear
echo "------------------------------------------------" 
echo "Bem-vindo ao script de gereciamento do servidor" 
echo "------------------------------------------------" 
echo "                                                         Autor: Giovane Oliveira"
echo
figlet "CPD SMS " 
echo
echo "[1] Para deixar o monitor sempre ligado"
echo "[2] Htop pra ficar vendo processos"
echo "[3] Para gerenciar o proxy"
echo "[4] Para gerenciar o firewall"
echo "[5] Para resolver pacotes quebrados"
echo "[6] Copiar a lista de bloqueio do proxy para o firewall"
echo "[7] Copiar a lista de bloqueio do firewall para o proxy"
echo "[8] Editar as configurações do samba"
echo "[9] Editar as configurações do dhcp"
echo "[10] Configurar interfaces de rede"
echo "[11] Sair"
echo "Digite a opção desejada:"
read op
case $op in
1)ligado;;
2)htop; menu;;
3)proxy;;
4)firewall;;
5)/opt/pacotes.sh; menu;;
6) cat /etc/squid3/sites_bloqueados.txt > /opt/url;echo "Lista copiada com sucesso!";
sleep 3; /opt/sh.sh; sleep 3; menu;;
7) cat /opt/url > /etc/squid3/sites_bloqueados.txt;echo "Lista copiada com sucesso!";
sleep 3; /etc/init.d/squid3 reload;echo "Nova lista aplicada com sucesso!";sleep 3; menu;;
8)figlet samba 4; sleep 2; nano /etc/samba/smb.conf; 
/etc/init.d/samba restart;clear;
echo "Novas configurações carregadas com sucesso!"; sleep 2; menu;;
9) figlet dhcp; sleep 2; nano /etc/dhcp/dhcpd.conf; /etc/init.d/isc-dhcp-server restart; 
clear; echo "Novas configurações carregadas com sucesso!";sleep 2;menu;;
10) interfaces;;
11) echo "Tchau!"; sleep 2; clear; setterm -foreground white -background black;
clear; sudo su;exit;;
*)echo "Opção inválida!"; sleep 2; menu;;
esac
}

interfaces() {
figlet Interfaces de rede
echo "[ 1 ] Para setar endereço estático na interface"
echo "[ 2 ] Para utilizar endereçamento via dhcp"
echo "[ 3 ] Voltar ao menu anterior"
read op
case $op in
1)estatica; echo "Pronto!";sleep 3; clear; menu;;
2)echo "Informe a interface de rede:"; read eth; chattr -i /etc/resolv.conf;
ifdown $eth;ifup $eth;dhclient $eth;echo "Pronto!";sleep 3; clear; menu;;
3)menu;;
*)clear; echo "Resposta inválida!"; interfaces;;
esac
}

estatica() {
echo "Informe a interface de rede:"; read eth;
echo "Informe o endereço ipv4:"; read ip;
echo "Informe a mascára de rede:"; read mask;
echo "Informe o broadcast da rede:"; read broadcast;
echo "Informe o gateway da rede:"; read gateway;
echo "Informe o endereço dns primário:"; read dns1;
echo "Informe o endereço dns secundário:"; read dns2;
ifconfig $eth $ip netmask $mask broadcast $broadcast up;
route del default;
route add default gw $gateway dev $eth;
ifdown $eth;
ifup $eth;
chattr -i /etc/resolv.conf;
echo nameserver $dns1 > /etc/resolv.conf;
echo nameserver $dns2 >> /etc/resolv.conf;
chattr +i /etc/resolv.conf;
/etc/init.d/networking restart;

}

ligado() {

clear
echo "Este comando só funciona se for executado diretamente da máquina servidor"
echo " Responda com s/p sim ou n/p não:"
read op
case $op in
s)setterm -blank 0; clear; echo "Monitor sempre ligado ativado!";sleep 2; menu;;
n)menu;;
*)clear; echo "Resposta inválida!"; setterm;;
esac
}

proxy() {
clear
echo "----------------------------------------" 
echo "Gerenciamento do Proxy" 
echo "----------------------------------------"
echo "                                                         Autor: Giovane Oliveira"
figlet Squid 3
echo
echo "[ 1 ] Adicionar ou remover ip para acesso liberado" 
echo "[ 2 ] Liberar somente o youtube" 
echo "[ 3 ] Adicionar ou remover sites a serem bloqueados" 
echo "[ 4 ] Adicionar ou remover palavras a serem bloqueadas" 
echo "[ 5 ] Gerenciar regras do squid" 
echo "[ 6 ] Gerenciar arquivos bloqueados" 
echo "[ 7 ] Liberar tudo menos as redes sociais" 
echo "[ 8 ] Verificar se o squid está funcionando" 
echo "[ 9 ] Liberar sites" 
echo "[ 10 ] Restartar o squid" 
echo "[ 11 ] Voltar ao menu" 
echo "[ 12 ] Sair" 
echo "Digite a opção desejada:"
read op
case $op in

1)nano /etc/squid3/adms.txt
echo "Recarregando as configurações"
sleep 3
/etc/init.d/squid3 reload
echo "Pronto!"
sleep 2
proxy;;

2)nano /etc/squid3/users_youtube.txt
echo "Recarregando as configurações"
sleep 3
/etc/init.d/squid3 reload
echo "Pronto!"
sleep 2
proxy;;

3)nano /etc/squid3/sites_bloqueados.txt
echo "Recarregando as configurações"
sleep 3
/etc/init.d/squid3 reload
echo "Pronto!"
sleep 2
proxy;;

4)nano /etc/squid3/palavras_bloqueadas.txt
echo "Recarregando as configurações"
sleep 3
/etc/init.d/squid3 reload
echo "Pronto!"
sleep 2
proxy;;

5)nano /etc/squid3/squid.conf
echo "Recarregando as configurações"
sleep 3
/etc/init.d/squid3 reload
echo "Pronto!"
sleep 2
proxy;;

6)nano /etc/squid3/formato_arquivo.txt
echo "Recarregando as configurações"
sleep 3
/etc/init.d/squid3 reload
echo "Pronto!"
sleep 2
proxy;;

7)nano /etc/squid3/sala9.txt
echo "Recarregando as configurações"
sleep 3
/etc/init.d/squid3 reload
echo "Pronto!"
sleep 2
proxy;;

8)aux=$(ps aux | grep squid3)
if [ "$aux" != "" ] ; then
echo "O squid está rodando!"
ps aux | grep squid3
sleep 5
proxy
else
echo "O squid não está rodando!"
proxy
fi;;
9)nano /etc/squid3/sites_liberados.txt
echo "Recarregando as configurações"
sleep 3
/etc/init.d/squid3 reload
echo "Pronto!"
sleep 2
proxy;;

10)squid;;

11)menu;;

12)sudo su; echo "Tchau!"; sleep 2; clear; setterm -foreground white -background black;
clear; exit;;

*)echo "Opção inválida!";proxy;;
esac

menu
}

squid() {
clear
echo "Atenção! O programa recarrega as configurações automáticamente"
echo "Tem certeza que deseja restartar? s/p sim e n/p não"
echo "Digite a opção desejada:"
read op
case $op in
s)/etc/init.d/squid3 restart
echo "Pronto!"
sleep 3
proxy;;
n)proxy;;
*)echo "Opção inválida!";squid;;
esac
}



firewall() {
clear
echo "----------------------------------------" 
echo "Gerenciamento do Firewall" 
echo "----------------------------------------" 
echo "                                                         Autor: Giovane Oliveira"
figlet Iptables
echo
echo "[ 1 ] Abrir script de configuração firewall" 
echo "[ 2 ] Editar lista de ips com acesso total" 
echo "[ 3 ] Adicionar ou remover url's bloqueadas pelo firewall" 
echo "[ 4 ] Pesquisar regras aplicadas" 
echo "[ 5 ] Apresentar regras ativas do firewall" 
echo "[ 6 ] Fazer backup das listas do firewall" 
echo "[ 7 ] Voltar ao menu" 
echo "[ 8 ] Sair" 
echo "Digite a opção desejada:" 
read opcao
case $opcao in

1)nano /opt/sh.sh;/opt/sh.sh;clear;
echo "As novas regras foram aplicadas!";sleep 3;firewall;;

2)nano /opt/ipsti;/opt/sh.sh;clear;
echo "As novas regras foram aplicadas!";sleep 3;firewall;;

3)nano /opt/url;/opt/sh.sh;clear;
echo "As novas regras foram aplicadas!";sleep 3;firewall;;

4)pesquisar;;

5)iptables -L > /opt/relatorio && iptables -t nat -L >> /opt/relatorio; nano /opt/relatorio; echo "" > /opt/relatorio; firewall;;

6)backup;;

7)menu;;

8)sudo su; echo "Encerrando...";sleep 3;echo "Tchau!"; sleep 2; clear; 
clear;setterm -foreground white -background black; exit;;

*) echo "Opção desconhecida!"; firewall;;
esac
}

backup() {
echo "MENU" 
echo "1) Restaurar backup" 
echo "2) Fazer backup"
echo "Digite a opção a ser escolhida:"
read op
case $op in
1)echo "Restaurando ..."
sleep 10
cat /opt/backups/ipsti > /opt/ipsti
cat /opt/backups/url > /opt/url
cat /opt/sh.sh
sleep 2
clear
echo "Backup restaurado com sucesso!" 
sleep 3
firewall;;

2)echo "Gerando backup ..."
sleep 10
cat /opt/ipsti > /opt/backups/ipsti
cat /opt/url > /opt/backups/url
echo "Backup gerado com sucesso!"
sleep 3 
firewall;;
esac
}

pesquisar() {
echo "Digite o ip, url ou porta a ser pesquisada:" 
read string
a=$(iptables -L | grep $string)
if [ "$a" != "" ] ; then
echo "Contém regra com essa informação" 
iptables -L | grep $string
sleep 5
firewall
else 
echo "Não contém nenhuma regra com o dado informado" 
sleep 3
firewall
fi

}

menu
