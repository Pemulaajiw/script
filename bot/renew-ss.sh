#!/bin/bash

clear
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
NUMBER_OF_CLIENTS=$(grep -E "^#shadowsocks-user# " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq)
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		 echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
             echo -e " \e[1;97;101m       RENEW SHADOWSOCKS ACCOUNT       \e[0m"
             echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
		echo ""
		echo "You have no existing clients!"
        echo ""
		exit 1
	fi
             echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

read -p "username: " user
read -p "Extend (days): " masaaktif
exp=$(grep -wE "^#shadowsocks-user# $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`

if [ ! -e /etc/shadowsocks/ ]; then
  mkdir -p /etc/shadowsocks/
fi

sed -i "s/#shadowsocks-user# $user $exp/#shadowsocks-user# $user $exp4/g" /etc/xray/config.json
sed -i "s/#shadowsocks# $user $exp/#shadowsocks-user# $user $exp4/g" /etc/shadowsocks/.shadowsocks.db
systemctl restart xray
clear
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e " \e[1;97;101m      SUCCES RENEW SHADOWSOCKS ACCOUNT     \e[0m"
  echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Client Name : $user"
echo " Expired On  : $exp4"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
