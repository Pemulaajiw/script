#!/bin/bash
clear
red() { echo -e "\\033[32;1m${*}\\033[0m"; }
domain=$(cat /etc/xray/domain)
PUB=$(cat /etc/slowdns/server.pub)
CITY=$(cat /etc/xray/city)
NS=$(cat /etc/xray/dns)
clear
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
  echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e " \e[1;97;101m            ADD vless ACCOUNT           \e[0m"
  echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

  read -p "User: " user
  CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

  if [[ ${CLIENT_EXISTS} == '1' ]]; then
    clear
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e " \e[1;97;101m            ADD vless ACCOUNT           \e[0m"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "A client with the specified name was already created, please choose another name."
    echo ""
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    exit 0
systemctl restart cybervpn
  fi
done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
read -p "Limit User (GB): " Quota
read -p "Limit User (ip): " ip

echo $ip > /etc/kyt/limit/vless/ip/${user}

#read -p "     Limit User (IP)  : " iplim
tgl=$(date -d "$masaaktif days" +"%d")
bln=$(date -d "$masaaktif days" +"%b")
thn=$(date -d "$masaaktif days" +"%Y")
expe="$tgl-$bln-$thn"
tgl2=$(date +"%d")
bln2=$(date +"%b")
thn2=$(date +"%Y")
tnggl="$tgl2-$bln2-$thn2"


if [[ $user =~ ^Trial[A-Za-z0-9]+$ ]]; then
    exp=$(date -d "$masaaktif days" +"%d-%b-%Y")
    expi=$(date -d "$masaaktif hour" +"%H:%M:%S")
    echo "### $user $expi" >> /etc/trialxray.txt
else
    exp=$(date -d "$masaaktif days" +"%d-%b-%Y")
fi



sed -i '/#vlessws#$/a\#vless-user# '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\#vless-user# '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
cat >/home/vps/public_html/vless-$user.yaml <<-END

# Format vless WS TLS

- name: vless-$user-WS TLS
  server: ${domain}
  port: 443
  type: vless
  uuid: ${uuid}
  cipher: auto
  tls: true
  skip-cert-verify: true
  servername: ${domain}
  network: ws
  ws-opts:
    path: /vless
    headers:
      Host: ${domain}

# Format vless WS Non TLS

- name: vless-$user-WS (CDN) Non TLS
  server: ${domain}
  port: 80
  type: vless
  uuid: ${uuid}
  cipher: auto
  tls: false
  skip-cert-verify: false
  servername: ${domain}
  network: ws
  ws-opts:
    path: /vless
    headers:
      Host: ${domain}
  udp: true

# Format vless gRPC (SNI)

- name: vless-$user-gRPC (SNI)
  server: ${domain}
  port: 443
  type: vless
  uuid: ${uuid}
  cipher: auto
  tls: true
  skip-cert-verify: true
  servername: ${domain}
  network: grpc
  grpc-opts:
  grpc-mode: gun
  grpc-service-name: vless-grpc
  udp: true



END
_______________________________
 Link vless Account
_______________________________
Link TLS : vless://${uuid}@${domain}:443?path=/vless&security=tls&encryption=none&host=${domain}&type=ws#${user}"
_______________________________
Link none TLS : vless://${uuid}@${domain}:80?path=/vless&encryption=none&host=${domain}&type=ws#${user}"
_______________________________
Link GRPC : vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}
_______________________________

vlesslink1="vless://${uuid}@${domain}:443?path=/vless&security=tls&encryption=none&host=${domain}&type=ws#${user}"
vlesslink2="vless://${uuid}@${domain}:80?path=/vless&encryption=none&host=${domain}&type=ws#${user}"
vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}"

systemctl restart xray
systemctl restart nginx
systemctl restart haproxy
systemctl restart vlessjs
service cron restart
echo "$user $exp $max $uuid" >> /root/limit/limitvless.txt

if [ ! -e /etc/vless ]; then
  mkdir -p /etc/vless
fi

if [ -z ${iplim} ]; then
  iplim="0"
fi

if [ -z ${Quota} ]; then
  Quota="0"
fi

c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))

if [[ ${c} != "0" ]]; then
  echo "${d}" >/etc/kyt/limit/vless/quota/${user}
  echo "${iplim}" >/etc/kyt/limit/vless/ip/${user}IP
fi
DATADB=$(cat /etc/vless/.vless.db | grep "^#&" | grep -w "${user}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${user}\b/d" /etc/vless/.vless.db
fi
status="UNLOCKED"
echo "#vless# ${user} ${expe} ${status} ${uuid} ${Quota}" >>/etc/vless/.vless.db

echo "#& ${user} ${expe}" >>/etc/kyt/vl
mkdir -p /detail/vless/
cat > /detail/vless/${user}.txt <<-END
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
               vless ACCOUNT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Remarks     : ${user}
Domain      : ${domain}
User Quota  : ${Quota} GB
port TLS    : 443
Port DNS    : 443, 53 
Port NTLS   : 80, 8080, 2086
User ID     : ${uuid}
AlterId     : 0
Security    : auto
Encryption  : none
Path        : /vlesss - /multipath
Path Dynamic : CF-XRAY:http://bug.com</
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Link TLS   : ${vlesslink1}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Link NTLS  : ${vlesslink2}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Link GRPC  : ${vlesslink3}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Format OpenClash : https://${domain}:81/vless-$user.txt
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Aktif Selama   : $masaaktif Hari
Dibuat Pada    : $tnggl
Berakhir Pada  : $expe
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
END

clear
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " \e[1;97;101m       SUCCES CREAT vless ACCOUNT       \e[0m"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Remarks     : ${user}"
echo -e "Domain      : ${domain}"
echo -e "Location    : $CITY"
echo -e "User Quota  : ${Quota} GB"
echo -e "port TLS    : 443"
echo -e "Port DNS    : 443, 53 "
echo -e "Port NTLS   : 80, 8080, 2086"
echo -e "Port GRPC   : 443"
echo -e "Port XRAY   : 443,80"
echo -e "User ID     : ${uuid}"
echo -e "AlterId     : 0"
echo -e "Security    : auto"
echo -e "Encryption  : none"
echo -e "Path        : /vlesss - /multipath"
echo -e "Path Dynamic : CF-XRAY:http://bug.com</"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link TLS   : ${vlesslink1}"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link NTLS  : ${vlesslink2}"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link GRPC  : ${vlesslink3}"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Format OpenClash : https://${domain}:81/vless-$user.txt"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Aktif Selama   : $masaaktif Hari"
echo -e "Dibuat Pada    : $tnggl"
echo -e "Berakhir Pada  : $expe"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
#read -n 1 -s -r -p "Press [ Enter ] to back menu vless"
#vless

#systemctl restart delproject
