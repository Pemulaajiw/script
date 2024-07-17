#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# System Request : Debian 9+/Ubuntu 18.04+/20+
# Develovers » FanVPN-Store
# Email      » HurufKapital58@gmail.com
# telegram   » https://t.me/AJW29
# whatsapp   » wa.me/+6287812264674
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FanVPN-Store
# ==========================================
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
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

# // Valid Script
ipsaya=$(curl -sS ipv4.icanhazip.com)
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")
data_ip="https://raw.githubusercontent.com/Pemulaajiw/script/main/register"
checking_sc() {
  useexp=$(wget -qO- $data_ip | grep $ipsaya | awk '{print $3}')
  if [[ $date_list < $useexp ]]; then
    echo -ne
  else
    echo -e "\033[1;93m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[42m          404 NOT FOUND AUTOSCRIPT          \033[0m"
    echo -e "\033[1;93m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e ""
    echo -e "            ${RED}PERMISSION DENIED !${NC}"
    echo -e "   \033[0;33mYour VPS${NC} $ipsaya \033[0;33mHas been Banned${NC}"
    echo -e "     \033[0;33mBuy access permissions for scripts${NC}"
    echo -e "             \033[0;33mContact Admin :${NC}"
    echo -e "      ${GREEN}WhatsApp${NC} wa.me/+6287812264674"
    echo -e "\033[1;93m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    exit 0
  fi
}
checking_sc
clear
# Load params
source /etc/wireguard/params
source /var/lib/crot/ipvps.conf
if [[ "$IP" = "" ]]; then
SERVER_PUB_IP=$(wget -qO- ipinfo.io/ip);
else
SERVER_PUB_IP=$IP
fi
source /var/lib/crot/ipvps.conf
if [[ "$IP2" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP2
fi
echo ""
portwg="$(cat ~/log-install.txt | grep -w "Wireguard" | cut -d: -f2|sed 's/ //g')"
until [[ ${CLIENT_NAME} =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
	read -rp "Username : " -e CLIENT_NAME
	CLIENT_EXISTS=$(grep -w $CLIENT_NAME /etc/wireguard/wg0.conf | wc -l)

	if [[ ${CLIENT_EXISTS} == '1' ]]; then
		echo ""
		echo -e "Username ${RED}${CLIENT_NAME}${NC} Already On VPS Please Choose Another"
		exit 1
	fi
done

echo "IPv4 Detected"
ENDPOINT="$SERVER_PUB_IP:$SERVER_PORT"
WG_CONFIG="/etc/wireguard/wg0.conf"
LASTIP=$( grep "/32" $WG_CONFIG | tail -n1 | awk '{print $3}' | cut -d "/" -f 1 | cut -d "." -f 4 )
if [[ "$LASTIP" = "" ]]; then
CLIENT_ADDRESS="10.66.66.2"
else
CLIENT_ADDRESS="10.66.66.$((LASTIP+1))"
fi

# Google DNS by default
CLIENT_DNS_1="8.8.8.8"

CLIENT_DNS_2="8.8.4.4"
MYIP=$(wget -qO- ifconfig.co);
read -p "Expired (Days) : " masaaktif
hariini=`date -d "0 days" +"%Y-%m-%d"`
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`

# Generate key pair for the client
CLIENT_PRIV_KEY=$(wg genkey)
CLIENT_PUB_KEY=$(echo "$CLIENT_PRIV_KEY" | wg pubkey)
CLIENT_PRE_SHARED_KEY=$(wg genpsk)

# Create client file and add the server as a peer
echo "[Interface]
PrivateKey = $CLIENT_PRIV_KEY
Address = $CLIENT_ADDRESS/24
DNS = $CLIENT_DNS_1,$CLIENT_DNS_2

[Peer]
PublicKey = $SERVER_PUB_KEY
PresharedKey = $CLIENT_PRE_SHARED_KEY
Endpoint = $ENDPOINT
AllowedIPs = 0.0.0.0/0,::/0" >>"$HOME/$SERVER_WG_NIC-client-$CLIENT_NAME.conf"

# Add the client as a peer to the server
echo -e "### Client $CLIENT_NAME $exp
[Peer]
PublicKey = $CLIENT_PUB_KEY
PresharedKey = $CLIENT_PRE_SHARED_KEY
AllowedIPs = $CLIENT_ADDRESS/32" >>"/etc/wireguard/$SERVER_WG_NIC.conf"
systemctl restart "wg-quick@$SERVER_WG_NIC"
cp $HOME/$SERVER_WG_NIC-client-$CLIENT_NAME.conf /home/vps/public_html/$CLIENT_NAME.conf
clear
sleep 0.5
echo Generate PrivateKey
sleep 0.5
echo Generate PublicKey
sleep 0.5
echo Generate PresharedKey
clear
echo -e ""
echo -e "======-WIREGUARD-======"
echo -e "Remarks  : $CLIENT_NAME"
echo -e "IP/Host  : $MYIP"
echo -e "Domain   : $domain"
echo -e "Port     : $portwg"
echo -e "Created  : $hariini"
echo -e "Expired  : $exp"
echo -e "======================="
echo -e "Link WG  : http://$MYIP:89/$CLIENT_NAME.conf"
echo -e "======================="
echo -e "Script Mod By FANSTORE"
rm -f /root/wg0-client-$CLIENT_NAME.conf
