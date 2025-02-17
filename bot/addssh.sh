#!/bin/bash
clear
red() { echo -e "\\033[32;1m${*}\\033[0m"; }
clear
#IZIN SCRIPT
MYIP=$(curl -sS ipv4.icanhazip.com)
echo -e "\e[32mloading...\e[0m"
clear
# Valid Script
Green="\e[92;1m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
FONT="\033[0m"
GREENBG="\033[42;37m"
REDBG="\033[41;37m"
OK="${Green}--->${FONT}"
ERROR="${RED}[ERROR]${FONT}"
GRAY="\e[1;30m"
NC='\e[0m'
red='\e[1;31m'
green='\e[0;32m'
DF='\e[39m'
Bold='\e[1m'
Blink='\e[5m'
yell='\e[33m'
red='\e[31m'
green='\e[32m'
blue='\e[34m'
PURPLE='\e[35m'
cyan='\e[36m'
Lred='\e[91m'
Lgreen='\e[92m'
Lyellow='\e[93m'
NC='\e[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
LIGHT='\033[0;37m'
grenbo="\e[92;1m"
red() { echo -e "\\033[32;1m${*}\\033[0m"; }
# Getting
CHATID=$(grep -E "^#bot# " "/etc/bot/.bot.db" | cut -d ' ' -f 3)
KEY=$(grep -E "^#bot# " "/etc/bot/.bot.db" | cut -d ' ' -f 2)
export TIME="10"
export URL="https://api.telegram.org/bot$KEY/sendMessage"
clear
#IZIN SCRIPT
MYIP=$(curl -sS ipv4.icanhazip.com)
echo -e "\e[32mloading...\e[0m"
clear
# Valid Script
ipsaya=$(curl -sS ipv4.icanhazip.com)
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")
data_ip="https://raw.githubusercontent.com/Lite-VPN/izin/main/ip"
checking_sc() {
  useexp=$(wget -qO- $data_ip | grep $ipsaya | awk '{print $3}')
  if [[ $date_list < $useexp ]]; then
    echo -ne
  else
    echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
    echo -e "\033[42m          404 NOT FOUND AUTOSCRIPT          \033[0m"
    echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
    echo -e ""
    echo -e "            ${RED}PERMISSION DENIED !${NC}"
    echo -e "   \033[0;33mYour VPS${NC} $ipsaya \033[0;33mHas been Banned${NC}"
    echo -e "     \033[0;33mBuy access permissions for scripts${NC}"
    echo -e "             \033[0;33mContact Admin :${NC}"
    echo -e "      ${GREEN}WhatsApp${NC} wa.me/6283867809137"
    echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
    exit 0
  fi
}
checking_sc
clear
export TIME="10"
IP=$(curl -sS ipv4.icanhazip.com)
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )
CITY=$(curl -s ipinfo.io/city )
domain=$(cat /etc/xray/domain)
clear
echo -e "\033[1;93m☉————————————————————————☉\033[0m"
echo -e " SSH Ovpn Account           "
echo -e "\033[1;93m☉————————————————————————☉\033[0m"
read -p " Username : " Login
read -p " Password : " Pass
read -p " Limit IP     : " iplimit
read -p " Limit Quota : " Quota
read -p " Expired (Days) : " masaaktif
#limitip
if [[ $iplimit -gt 0 ]]; then
mkdir -p /etc/kyt/limit/ssh/ip
echo -e "$iplimit" > /etc/kyt/limit/ssh/ip/$Login
else
echo > /dev/null
fi
clear
clear
tgl=$(date -d "$masaaktif days" +"%d")
bln=$(date -d "$masaaktif days" +"%b")
thn=$(date -d "$masaaktif days" +"%Y")
expe="$tgl $bln, $thn"
tgl2=$(date +"%d")
bln2=$(date +"%b")
thn2=$(date +"%Y")
tnggl="$tgl2 $bln2, $thn2"
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
expi="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
hariini=`date -d "0 days" +"%Y-%m-%d"`
expi=`date -d "$masaaktif days" +"%Y-%m-%d"`

if [ ! -e /etc/ssh ]; then
  mkdir -p /etc/ssh
fi

if [ -z ${Quota} ]; then
  Quota="0"
fi

c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))

if [[ ${c} != "0" ]]; then
  echo "${d}" >/etc/ssh/${Login}
fi
DATADB=$(cat /etc/ssh/.ssh.db | grep "^#ssh#" | grep -w "${Login}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${Login}\b/d" /etc/ssh/.ssh.db
fi
echo "#ssh# ${Login} ${Pass} ${Quota} ${iplimit} ${expe}" >>/etc/ssh/.ssh.db
clear

cat > /var/www/html/ssh-$Login.txt <<-END
◇━━━━━━━━━━━━━━━━━◇
Format SSH OVPN Account
◇━━━━━━━━━━━━━━━━━◇
Username         : $Login
Password         : $Pass
◇━━━━━━━━━━━━━━━━━◇
IP               : $IP
Host             : $domain
Port OpenSSH     : 443, 80, 22
Port Dropbear    : 443, 109
Port Dropbear WS : 443, 109
Port SSH UDP     : 1-65535
Port SSH WS      : 80, 8080, 8081-9999
Port SSH SSL WS  : 443
Port SSL/TLS     : 400-900
Port OVPN WS SSL : 443
Port OVPN SSL    : 443
Port OVPN TCP    : 1194
Port OVPN UDP    : 2200
BadVPN UDP       : 7100, 7300, 7300
◇━━━━━━━━━━━━━━━━━◇
Aktif Selama     : $masaaktif Hari
Dibuat Pada      : $tnggl
Berakhir Pada    : $expe
◇━━━━━━━━━━━━━━━━━◇
Payload WSS: GET wss://BUG.COM/ HTTP/1.1[crlf]Host: $domain[crlf]Upgrade: websocket[crlf][crlf] 
◇━━━━━━━━━━━━━━━━━◇
OVPN Download : https://$domain:81/
◇━━━━━━━━━━━━━━━━━◇

END

CHATID="$CHATID"
KEY="$KEY"
TIME="$TIME"
URL="$URL"
TEXT="
<code>☉————————————————————————☉</code>
<code>🍀Succes Cretae SSH Account🍀     </code>
<code>☉————————————————————————☉</code>
<code> "${z}${r} ${NC}${z}CITY          ${NC}: $CITY"</code>
<code> "${z}${r} ${NC}${z}ISP           ${NC}: $ISP"
<code>☉————————————————————————☉</code>
<code>Username         : </code> <code>$Login</code>
<code>Password         : </code> <code>$Pass</code>
<code>Limit Quota       ; </code> <code>$Quota</code>
<code>☉————————————————————————☉</code>
<code>IP               : $IP</code>
<code>Host             : </code> <code>$domain</code>
<code>Port OpenSSH     : 443, 80, 22</code>
<code>Port Dropbear    : 443, 109</code>
<code>Port SSH WS      : 80, 8080, 8081-9999 </code>
<code>Port SSH UDP     : 1-65535 </code>
<code>Port SSH SSL WS  : 443</code>
<code>Port SSL/TLS     : 400-900</code>
<code>Port OVPN WS SSL : 443</code>
<code>Port OVPN SSL    : 443</code>
<code>Port OVPN TCP    : 443, 1194</code>
<code>Port OVPN UDP    : 2200</code>
<code>BadVPN UDP       : 7100, 7300, 7300</code>
<code>☉————————————————————————☉</code>
<code>Payload WS       : </code><code>GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf][crlf]</code>
<code>☉————————————————————————☉</code>
<code>Payload WSS      : </code><code>GET wss://BUG.COM/ HTTP/1.1[crlf]Host: $domain[crlf]Upgrade: websocket[crlf][crlf]</code>
<code>☉————————————————————————☉</code>
OVPN Download : https://$domain:81/
<code>☉————————————————————————☉</code>
<code>Save Link Account: </code>https://$domain:81/ssh-$Login.txt
<code>☉————————————————————————☉</code>
Aktif Selama         : $masaaktif Hari
Dibuat Pada          : $tnggl
Berakhir Pada        : $expe
<code>☉————————————————————————☉</code>
"

curl -s --max-time $TIME -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
clear
echo ""
echo -e "\033[1;93m☉————————————————————————☉\033[0m" | tee -a /etc/user-create/user.log
echo -e "🧿Status Create SSH Succes🧿   " | tee -a /etc/user-create/user.log
echo -e "\033[1;93m☉————————————————————————☉\033[0m" | tee -a /etc/user-create/user.log
echo -e "${z}${r} ${NC}${z}CITY           ${NC}: $CITY" | tee -a /etc/user-create/user.log
echo -e "${z}${r} ${NC}${z}ISP            ${NC}: $ISP" | tee -a /etc/user-create/user.log
echo -e "\033[1;93m☉————————————————————————☉\033[0m" | tee -a /etc/user-create/user.log
echo -e "Host             : $domain" | tee -a /etc/user-create/user.log
echo -e "IP               : $IP" | tee -a /etc/user-create/user.log
echo -e "Username         : $Login" | tee -a /etc/user-create/user.log
echo -e "Password         : $Pass" | tee -a /etc/user-create/user.log
echo -e "\033[1;93m☉————————————————————————☉\033[0m" | tee -a /etc/user-
echo -e "Limit Quota      : $Quota GB" | tee -a /etc/user-create/user.log
echo -e "Limit Ip         : ${iplimit} User" | tee -a /etc/user-create/user.log
#echo -e "Host Slowdns     : ${NS}" | tee -a /etc/user-create/user.log
#echo -e "Pub Key          : ${PUB}" | tee -a /etc/user-create/user.log
#echo -e "Location         : $CITY" | tee -a /etc/user-create/user.log
echo -e "Port OpenSSH     : 443, 80, 22" | tee -a /etc/user-create/user.log
#echo -e "Port DNS         : 443, 53 ,22 " | tee -a /etc/user-create/user.log
echo -e "Port SSH UDP     : 1-65535" | tee -a /etc/user-create/user.log
echo -e "Port Dropbear    : 443, 109" | tee -a /etc/user-create/user.log
echo -e "Port SSH WS      : 80, 8080, 8880, 2082" | tee -a /etc/user-create/user.log
echo -e "Port SSH SSL WS  : 443" | tee -a /etc/user-create/user.log
echo -e "Port SSL/TLS     : 400-900" | tee -a /etc/user-create/user.log
echo -e "Port OVPN WS SSL : 443" | tee -a /etc/user-create/user.log
echo -e "Port OVPN SSL    : 443" | tee -a /etc/user-create/user.log
echo -e "Port OVPN TCP    : 443, 1194" | tee -a /etc/user-create/user.log
echo -e "Port OVPN UDP    : 2200" | tee -a /etc/user-create/user.log
echo -e "BadVPN UDP       : 7100, 7300, 7300" | tee -a /etc/user-create/user.log
echo -e "\033[1;93m☉————————————————————————☉\033[0m" | tee -a /etc/user-create/user.log
echo -e "Payload WS       : GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf][crlf]" | tee -a /etc/user-create/user.log
echo -e "\033[1;93m☉————————————————————————☉\033[0m" | tee -a /etc/user-create/user.log
echo -e "Payload WSS      : GET wss://BUG.COM/ HTTP/1.1[crlf]Host: $domain[crlf]Upgrade: websocket[crlf][crlf]" | tee -a /etc/user-create/user.log
echo -e "\033[1;93m☉————————————————————————☉\033[0m" | tee -a /etc/user-create/user.log
echo -e "OVPN Download    : https://$domain:81/" | tee -a /etc/user-create/user.log
echo -e "\033[1;93m☉————————————————————————☉\033[0m" | tee -a /etc/user-create/user.log
echo -e "Save Link Account: https://$domain:81/ssh-$Login.txt" | tee -a /etc/user-create/user.log
echo -e "\033[1;93m☉————————————————————————☉\033[0m" | tee -a /etc/user-create/user.log
echo -e "Aktif Selama     : $masaaktif Hari" | tee -a /etc/user-create/user.log
echo -e "Dibuat Pada      : $tnggl" | tee -a /etc/user-create/user.log
echo -e "Berakhir Pada    : $expe" | tee -a /etc/user-create/user.log
echo -e "\033[1;93m☉————————————————————————☉\033[0m" | tee -a /etc/user-create/user.log
echo "" | tee -a /etc/user-create/user.log
read -p "Enter Back To Menu"
menu
