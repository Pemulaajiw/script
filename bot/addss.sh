#!/bin/bash
clear

MYIP=$(curl -sS ipv4.icanhazip.com)
# // Get Info
IP=$(curl -sS ipv4.icanhazip.com)
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
domain=$(cat /etc/xray/domain)
clear

echo ""
read -rp " Username         : " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
			echo -e "\e[91m Sorry Nickname is Ready ! \033[0m "
			echo ""
			read -p "Press any key to back on menu"
			add-shadowsocks
		fi
#	done

cipher="aes-128-gcm"
uuid=$(cat /proc/sys/kernel/random/uuid)
echo
read -p " Limit User (GB)  : " Quota
echo
read -p " Limit User (IP)  : " iplimit
echo
read -p " Expired (days)   : " masaaktif


#.          LIMIT IP SHADOWSOCKS
#################################################
if [[ $iplimit -gt 0 ]]; then
mkdir -p /etc/kyt/limit/shadowsocks/ip
echo -e "$iplimit" > /etc/kyt/limit/shadowsocks/ip/$user
else
echo > /dev/null
fi
#################################################



#.             DATA QUOTA SHADOWSOCKS
#################################################
if [[ $Quota -gt 0 ]]; then
echo > /dev/null
fi

QUOTA1=$(echo "${Quota}" | sed 's/[^0-9]*//g')
QUOTA2=$((${QUOTA1} * 1024 * 1024 * 1024))

if [[ ${QUOTA1} != "0" ]]; then
  echo "${QUOTA2}" >/etc/kyt/limit/shadowsocks/quota/${user}
fi
################################################# 



#.             DATA AKUN SHADOWSOCKS.db
#################################################
DATADB=$(cat /etc/shadowsocks/.shadowsocks.db | grep "^#shadowsocks#" | grep -w "${user}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${user}\b/d" /etc/shadowsocks/.shadowsocks.db
fi
#################################################

#.           DETAIL AKUN SHADOWSOCKS
#################################################
# Data akun user : nama limitip quota expired domain uuid
echo "#shadowsocks# ${user} ${iplimit} ${exp} " >>/etc/shadowsocks/.shadowsocks.db
#################################################

if [[ $user =~ ^Trial[A-Za-z0-9]+$ ]]; then
    exp=$(date -d "$masaaktif days" +"%d-%b-%Y")
    expi=$(date -d "$masaaktif hour" +"%H:%M:%S")
    echo "### $user $expi" >> /etc/trialxray.txt
else
    exp=$(date -d "$masaaktif days" +"%d-%b-%Y")
fi

#.          DATAA TANGGAL
#################################################
tgl=$(date -d "$masaaktif days" +"%d")
bln=$(date -d "$masaaktif days" +"%b")
thn=$(date -d "$masaaktif days" +"%Y")
expe="$tgl $bln, $thn"
tgl2=$(date +"%d")
bln2=$(date +"%b")
thn2=$(date +"%Y")
tnggl="$tgl2 $bln2, $thn2"
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#shadowsocks-ws#$/a\#shadowsocks-user# '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#shadowsocks-grpc#$/a\#shadowsocks-user# '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/xray/config.json
echo $cipher:$uuid > /tmp/log
shadowsocks_base64=$(cat /tmp/log)
echo -n "${shadowsocks_base64}" | base64 > /tmp/log1
shadowsocks_base64e=$(cat /tmp/log1)
#################################################



#.              LINK JSON
#################################################
shadowsockslink="ss://${shadowsocks_base64e}@$domain:$tls?plugin=xray-plugin;mux=0;path=/ss-ws;host=$domain;tls#${user}"
shadowsockslink1="ss://${shadowsocks_base64e}@$domain:$tls?plugin=xray-plugin;mux=0;serviceName=ss-grpc;host=$domain;tls#${user}"
#buat ss WEBSOCKET
sslinkws="ss://${shadowsocks_base64e}@${domain}:443?path=/ss-ws&security=tls&encryption=none&type=ws#${user}"
nonsslinkws="ss://${shadowsocks_base64e}@${domain}:80?path=/ss-ws&security=none&encryption=none&type=ws#${user}"
#buat ss GRPC
sslinkgrpc="ss://${shadowsocks_base64e}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=ss-grpc&sni=bug.com#${user}"
nonsslinkgrpc="ss://${shadowsocks_base64e}@${domain}:80?mode=gun&security=none&encryption=none&type=grpc&serviceName=ss-grpc&sni=bug.com#${user}"
#################################################



#.                 RESTART shadowsocksJS
#################################################
rm -rf /tmp/log
rm -rf /tmp/log1
#################################################



#.             DETAIL CONFIG AKUN
#################################################
# Create Dir Untuk Menyimpan Data Akun
mkdir -p /detail/shadowsocks/
# // Simpan Detail Akun User
cat > /detail/shadowsocks/$user.txt <<-END
——————————————————————————————————————— 
         Shadowsocks Account
———————————————————————————————————————
Username         : $user
Quota            : $Quota Gb
Limit ip         : $iplimit Devic
Expiry in        : $masaaktif Day
———————————————————————————————————————
Port No Grpc     : 80-2082-8880
Port Grpc        : 443-8443-2095
Network          : ws/grpc
Cipers           : aes-128-gcm
patch            : ws/grpc/Wildcard
Uuid Sadowsok    : ${uuid}
———————————————————————————————————————
Link Grpc        : ${sslinkgrpc}
———————————————————————————————————————
Link no Grpc     : ${nonsslinkgrpc}
———————————————————————————————————————
Link Ws          : ${sslinkws}
———————————————————————————————————————
Open Clash       : https://${domain}:81/shadowsocks-$user.txt
———————————————————————————————————————
END

function Send_Notif(){
KEY_TELE=$(sed -n '1p' /root/.notifbot | awk '{print $1}')
URL="https://api.telegram.org/bot$KEY_TELE/sendMessage"
ID_TELE=$(sed -n '2p' /root/.notifbot | awk '{print $1}')
TIMES="10"

# // MEMBER NOTIF KE TELEGRAM HASIL CEEATE
TEXT="
<code>———————————————————————————————————————</code>
<code>  🟢Shadowsocks successfully created🟢 </code>
<code>———————————————————————————————————————</code>
<code> USERNAME : $user        </code>
<code> LIMIT IP : $iplimit ip  </code>
<code> QUOTA    : $Quota Gb    </code>
<code> ISP VPS  : $ISP         </code>
<code>———————————————————————————————————————</code>
<code> EXPIRED  : $exp Day     </code>
<code>———————————————————————————————————————</code>
<code> DOMAIN   : $domain      </code>
<code>———————————————————————————————————————</code>
<code>       Script  Roh Tunneling        </code>
<code>         Thanks Have ordered           </code>
<code>———————————————————————————————————————</code>
"

#.  MEMBERI NOTIF KE TELE SETELAH AKUN DI BUAT
#################################################
curl -s --max-time $TIMES -d "chat_id=$ID_TELE&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL
#################################################
}

Send_Notif






#.              OPENCLASH
#################################################

cat > /var/www/html/shadowsocks-user.txt <<-END

# Format Shadowsocks GO/WS

- name: Shadowsocks-$user
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

# Format Shadowsocks gRPC / Tls

- name: Shadowsocks-$user
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
cat > /var/www/html/sodosokws-$user.txt <<-END
{ 
 "dns": {
    "servers": [
      "8.8.8.8",
      "8.8.4.4"
    ]
  },
 "inbounds": [
   {
      "port": 10808,
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true,
        "userLevel": 8
      },
      "sniffing": {
        "destOverride": [
          "http",
          "tls"
        ],
        "enabled": true
      },
      "tag": "socks"
    },
    {
      "port": 10809,
      "protocol": "http",
      "settings": {
        "userLevel": 8
      },
      "tag": "http"
    }
  ],
  "log": {
    "loglevel": "none"
  },
  "outbounds": [
    {
      "mux": {
        "enabled": true
      },
      "protocol": "shadowsocks",
      "settings": {
        "servers": [
          {
            "address": "$domain",
            "level": 8,
            "method": "$cipher",
            "password": "$uuid",
            "port": 443
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "allowInsecure": true,
          "serverName": "isi_bug_disini"
        },
        "wsSettings": {
          "headers": {
            "Host": "$domain"
          },
          "path": "/ss-ws"
        }
      },
      "tag": "proxy"
    },
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "settings": {
        "response": {
          "type": "http"
        }
      },
      "tag": "block"
    }
  ],
  "policy": {
    "levels": {
      "8": {
        "connIdle": 300,
        "downlinkOnly": 1,
        "handshake": 4,
        "uplinkOnly": 1
      }
    },
    "system": {
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  },
  "routing": {
    "domainStrategy": "Asls",
"rules": []
  },
  "stats": {}
}
END
cat > /var/www/html/sodosokgrpc-$user.txt <<-END
{
    "dns": {
    "servers": [
      "8.8.8.8",
      "8.8.4.4"
    ]
  },
 "inbounds": [
   {
      "port": 10808,
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true,
        "userLevel": 8
      },
      "sniffing": {
        "destOverride": [
          "http",
          "tls"
        ],
        "enabled": true
      },
      "tag": "socks"
    },
    {
      "port": 10809,
      "protocol": "http",
      "settings": {
        "userLevel": 8
      },
      "tag": "http"
    }
  ],
  "log": {
    "loglevel": "none"
  },
  "outbounds": [
    {
      "mux": {
        "enabled": true
      },
      "protocol": "shadowsocks",
      "settings": {
        "servers": [
          {
            "address": "$domain",
            "level": 8,
            "method": "$cipher",
            "password": "$uuid",
            "port": 443
          }
        ]
      },
      "streamSettings": {
        "grpcSettings": {
          "multiMode": true,
          "serviceName": "ss-grpc"
        },
        "network": "grpc",
        "security": "tls",
        "tlsSettings": {
          "allowInsecure": true,
          "serverName": "isi_bug_disini"
        }
      },
      "tag": "proxy"
    },
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "settings": {
        "response": {
          "type": "http"
        }
      },
      "tag": "block"
    }
  ],
  "policy": {
    "levels": {
      "8": {
        "connIdle": 300,
        "downlinkOnly": 1,
        "handshake": 4,
        "uplinkOnly": 1
      }
    },
    "system": {
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  },
  "routing": {
    "domainStrategy": "Asls",
"rules": []
  },
  "stats": {}
}
END
systemctl reload xray >/dev/null 2>&1
service cron restart >/dev/null 2>&1
systemctl restart shadowsocksjs
systemctl restart xray
clear

echo "
——————————————————————————————————————— 
         Shadowsocks Account
———————————————————————————————————————
Username         : $user
Quota            : $Quota Gb
Limit ip         : $iplimit Devic
Expiry in        : $masaaktif Day
———————————————————————————————————————
Port No Grpc     : 80-2082-8880
Port Grpc        : 443-8443-2095
Network          : ws/grpc
Cipers           : aes-128-gcm
patch            : ws/grpc/Wildcard
Uuid Sadowsok    : ${uuid}
———————————————————————————————————————
Link Grpc        : ${sslinkgrpc}
———————————————————————————————————————
Link no Grpc     : ${nonsslinkgrpc}
———————————————————————————————————————
Link Ws          : ${sslinkws}
———————————————————————————————————————
Open Clash       : https://${domain}:81/shadowsocks-$user.txt
———————————————————————————————————————"
