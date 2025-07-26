#!/bin/bash

MYIP=$(curl -sS ipv4.icanhazip.com)
IP=$(curl -sS ipv4.icanhazip.com)
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
domain=$(cat /etc/xray/domain)









#tr="$(cat ~/log-install.txt | grep -w "trojan WS " | cut -d: -f2|sed 's/ //g')" 
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do

echo ""
read -rp " Username         : " -e user
		user_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

		if [[ ${user_EXISTS} == '1' ]]; then
clear
			echo ""
			echo -e "Sorry Nickname is Ready ! \033[0m "
			echo ""
			read -p "Press any key to back on menu"
			m-trojan
		fi
	done

read -p " Limit User (GB)  : " Quota
echo
read -p " Limit User (IP)  : " iplimit
echo
read -p " Expired (days)   : " exp



#.         DATA LIMIT IP trojan
#################################################
if [[ $iplimit -gt 0 ]]; then
mkdir -p /etc/kyt/limit/trojan/ip
echo -e "$iplimit" > /etc/kyt/limit/trojan/ip/$user
else
echo > /dev/null
fi


# Data Quota trojan
if [ -z ${Quota} ]; then
  Quota="0"
fi

QUOTA1=$(echo "${Quota}" | sed 's/[^0-9]*//g')
QUOTA2=$((${QUOTA1} * 1024 * 1024 * 1024))

if [[ ${QUOTA1} != "0" ]]; then
  echo "${QUOTA2}" >/etc/kyt/limit/trojan/quota/${user}
fi
#################################################

#                   DATA DB trojan
#################################################
DATADB=$(cat /etc/trojan/.trojan.db | grep "^#trojan#" | grep -w "${user}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${user}\b/d" /etc/trojan/.trojan.db
fi
#################################################
uuid=$(cat /proc/sys/kernel/random/uuid)

#         DATA AKUN DI DB
#################################################
# // detail user di data.db
echo "#trojan# ${user} ${exp} ${iplimit}" >>/etc/trojan/.trojan.db
#################################################
if [[ $user =~ ^Trial[A-Za-z0-9]+$ ]]; then
    exp=$(date -d "$masaaktif days" +"%d-%b-%Y")
    expi=$(date -d "$masaaktif hour" +"%H:%M:%S")
    echo "### $user $expi" >> /etc/trialxray.txt
else
    exp=$(date -d "$masaaktif days" +"%d-%b-%Y")
fi



#################################################
tgl=$(date -d "$exp days" +"%d")
bln=$(date -d "$exp days" +"%b")
thn=$(date -d "$exp days" +"%Y")
expe="$tgl $bln, $thn"
tgl2=$(date +"%d")
bln2=$(date +"%b")
thn2=$(date +"%Y")
tnggl="$tgl2 $bln2, $thn2"
exp=`date -d "$exp days" +"%Y-%m-%d"`
sed -i '/#trojanws#$/a\#trojan-user# '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#trojangrpc#$/a\#trojan-user# '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json

#################################################

# // Restart Service
systemctl restart trojanjs

# // Link trojan Akun
GRPC="trojan://${uuid}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=bug.com#${user}"
TLS="trojan://${uuid}@bugkamu.com:443?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
WS="trojan://${uuid}@${domain}:80?path=%2Ftrojan-ws&security=none&host=${domain}&type=ws#${user}"
#              LINK JSON trojan              #
trojanlink1="trojan://${uuid}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=bug.com#${user}"
trojanlink="trojan://${uuid}@bugkamu.com:443?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
trojanlink2="trojan://${uuid}@${domain}:80?path=%2Ftrojan-ws&security=none&host=${domain}&type=ws#${user}"
trojanlink="trojan://${uuid}@${domain}:443?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
trojanlink1="trojan://${uuid}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${domain}#${user}"





#.          DETAIL AKUN USER
#################################################
# // Menyimpan Account Hasil Create
mkdir -p /detail/trojan/
cat > /detail/trojan/$user.txt <<-END
——————————————————————————————————————— 
           trojan Account
———————————————————————————————————————
Username         : $user
Quota            : $Quota Gb
Limit ip         : $iplimit Devic
Expiry in        : $exp Day
———————————————————————————————————————
Port No Grpc     : 80-2082-8880
Port Grpc/Tls    : 443-8443-2095
Network          : ws/grpc
Cipers           : aes-128-gcm
patch            : ws/grpc/Wildcard
Uuid Sadowsok    : ${uuid}
———————————————————————————————————————
Link Grpc        : ${trojanlink1}
———————————————————————————————————————
Link no Grpc     : ${trojanlink}
———————————————————————————————————————
Link Ws          : ${trojanlink2}
———————————————————————————————————————
Opem Clash       : https://${domain}:81/trojan-$user.txt
———————————————————————————————————————
END



#.            FORMAT OPENCLASH
#################################################

cat >/var/www/html/trojan-$user.txt <<-END
———————————————————————————————————————

# Format trojan GO/WS

- name: trojan-$user-GO/WS
  server: ${domain}
  port: 80
  type: trojan
  password: ${uuid}
  network: ws
  sni: ${domain}
  skip-cert-verify: true
  udp: true
  ws-opts:
    path: /trojan-ws
    headers:
        Host: ${domain}

# Format trojan gRPC / Tls

- name: trojan-$user-gRPC
  type: trojan
  server: ${domain}
  port: 443
  password: ${uuid}
  udp: true
  sni: ${domain}
  skip-cert-verify: true
  network: grpc
  grpc-opts:
    grpc-service-name: trojan-grpc
END


systemctl reload trojanjs
systemctl restart trojanjs
systemctl reload nginx
systemctl restart cron



echo "
——————————————————————————————————————— 
           trojan Account
———————————————————————————————————————
Username         : $user
Quota            : $Quota Gb
Limit ip         : $iplimit Devic
Expiry in        : $exp Day
———————————————————————————————————————
Port No Grpc     : 80-2082-8880
Port Grpc/Tls    : 443-8443-2095
Network          : ws/grpc
Cipers           : aes-128-gcm
patch            : ws/grpc/Wildcard
Uuid Sadowsok    : ${uuid}
———————————————————————————————————————
Link Grpc        : ${trojanlink1}
———————————————————————————————————————
Link no Grpc     : ${trojanlink}
———————————————————————————————————————
Link Ws          : ${trojanlink2}
———————————————————————————————————————
Opem Clash       : https://${domain}:81/trojan-$user.txt
———————————————————————————————————————"
