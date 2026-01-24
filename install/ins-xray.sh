#!/bin/bash
# ╔════════════════════════════════════════════════════════════════╗
# ║   ⛓️  D£VSX-NETWORK v12.0.3 :: [Ω-Protocol]                    ║
# ║         ⚙️  Secure | Fast | Adaptive | Next-Gen                ║
# ╚════════════════════════════════════════════════════════════════╝

# ===============================
# 🎨 WARNA
# ===============================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m'

# ===============================
# ⏳ FUNCTION PROGRESS BAR
# ===============================
progress_bar() {
  local duration=$1
  local message=$2
  local bar_length=30
  echo -ne "${CYAN}${message} ["
  for ((i=0;i<bar_length;i++)); do
    sleep $(bc -l <<<"$duration/$bar_length")
    echo -ne "█"
  done
  echo -e "] ${GREEN}DONE${NC}"
}

# ===============================
# 🌐 REPO
# ===============================
REPO="https://raw.githubusercontent.com/Pemulaajiw/script/"

clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}   🚀  ${CYAN}Starting Xray Installation...${NC}                          ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
sleep 0.5

# ===============================
# 📡 DOMAIN DETECTION
# ===============================
domain=$(cat /etc/xray/domain 2>/dev/null || echo "example.com")

# ===============================
# 🔧 SYSTEM SETUP
# ===============================
echo -e "[ ${YELLOW}•${NC} ] Preparing system..."
apt install -y iptables iptables-persistent chrony ntpdate >/dev/null 2>&1
ntpdate pool.ntp.org >/dev/null 2>&1
timedatectl set-ntp true
systemctl enable chrony >/dev/null 2>&1
systemctl restart chrony >/dev/null 2>&1
timedatectl set-timezone Asia/Jakarta
progress_bar 2 "System setup"

# ===============================
# 📦 DEPENDENCIES
# ===============================
echo -e "[ ${YELLOW}•${NC} ] Installing dependencies..."
apt update -y >/dev/null 2>&1
apt install -y curl socat xz-utils wget apt-transport-https gnupg dnsutils lsb-release zip pwgen openssl cron bash-completion >/dev/null 2>&1
progress_bar 3 "Dependencies install"

# ===============================
# ⚙️ XRAY CORE INSTALL
# ===============================
echo -e "[ ${YELLOW}•${NC} ] Installing Xray Core..."
mkdir -p /var/log/xray /etc/xray /run/xray
chown www-data:www-data /var/log/xray /run/xray
touch /var/log/xray/{access,error,access2,error2}.log
latest_version="24.11.30"
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version "$latest_version"
progress_bar 5 "Xray Core v${latest_version} install"

# ===============================
# 🔐 SSL CERTIFICATE
# ===============================
echo -e "[ ${YELLOW}•${NC} ] Generating SSL Certificate..."
systemctl stop nginx haproxy >/dev/null 2>&1
mkdir -p /root/.acme.sh
curl -s https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade >/dev/null 2>&1
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256
/root/.acme.sh/acme.sh --installcert -d "$domain" --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
progress_bar 6 "SSL Certificate"

# ===============================
# 🧩 UUID & CONFIG XRAY (TIDAK DIUBAH)
# ===============================
uuid=$(cat /proc/sys/kernel/random/uuid)
echo -e "[ ${GREEN}✓${NC} ] UUID generated: $uuid"
# xray config
cat > /etc/xray/config.json << END
{
  "log" : {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
      {
      "listen": "127.0.0.1",
      "port": 10000,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
   {
     "listen": "127.0.0.1",
     "port": "10001",
     "protocol": "vless",
      "settings": {
          "decryption":"none",
            "clients": [
               {
                 "id": "${uuid}",                 
                 "level": 0
#vless
             }
          ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": {
                "path": "/vless"
          }
        }
     },
     {
     "listen": "127.0.0.1",
     "port": "10002",
     "protocol": "vmess",
      "settings": {
            "clients": [
               {
                 "id": "${uuid}",
                 "alterId": 0,
                 "level": 0
#vmess
             }
          ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": {
                "path": "/vmess"
          }
        }
     },
    {
      "listen": "127.0.0.1",
      "port": "10003",
      "protocol": "trojan",
      "settings": {
          "decryption":"none",		
           "clients": [
              {
                 "password": "${uuid}", 
                 "level": 0
#trojanws
              }
          ],
         "udp": true
       },
       "streamSettings":{
           "network": "ws",
           "wsSettings": {
               "path": "/trojan"
            }
         }
     },
    {
         "listen": "127.0.0.1",
        "port": "10004",
        "protocol": "shadowsocks",
        "settings": {
           "clients": [
           {
           "method": "aes-128-gcm",
          "password": "${uuid}", 
          "level": 0
#ssws
           }
          ],
          "network": "tcp,udp"
       },
       "streamSettings":{
          "network": "ws",
             "wsSettings": {
               "path": "/ss-ws"
           }
        }
     },	
      {
        "listen": "127.0.0.1",
     "port": "10005",
        "protocol": "vless",
        "settings": {
         "decryption":"none",
           "clients": [
             {
               "id": "${uuid}", 
               "level": 0
#vlessgrpc
             }
          ]
       },
          "streamSettings":{
             "network": "grpc",
             "grpcSettings": {
                "serviceName": "vless-grpc"
           }
        }
     },
     {
      "listen": "127.0.0.1",
     "port": "10006",
     "protocol": "vmess",
      "settings": {
            "clients": [
               {
                 "id": "${uuid}",
                 "alterId": 0,
                 "level": 0
#vmessgrpc
             }
          ]
       },
       "streamSettings":{
         "network": "grpc",
            "grpcSettings": {
                "serviceName": "vmess-grpc"
          }
        }
     },
     {
        "listen": "127.0.0.1",
     "port": "10007",
        "protocol": "trojan",
        "settings": {
          "decryption":"none",
             "clients": [
               {
                 "password": "${uuid}", 
                 "level": 0
#trojangrpc
               }
           ]
        },
         "streamSettings":{
         "network": "grpc",
           "grpcSettings": {
               "serviceName": "trojan-grpc"
         }
      }
   },
   {
    "listen": "127.0.0.1",
    "port": "10008",
    "protocol": "shadowsocks",
    "settings": {
        "clients": [
          {
             "method": "aes-128-gcm",
             "password": "${uuid}", 
             "level": 0
#ssgrpc
           }
         ],
           "network": "tcp,udp"
      },
    "streamSettings":{
     "network": "grpc",
        "grpcSettings": {
           "serviceName": "ss-grpc"
          }
       }
    }	
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "inboundTag": ["api"],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "protocol": ["bittorrent"],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "outboundTag": "freedom",
        "domain": [
          "*.gojek.com",
          "*.go-pay.co.id",
          "*.shopee.co.id",
          "*.tokopedia.com",
          "*.bukalapak.com",
          "*.ovo.id",
          "*.dana.id",
          "*.linkaja.id",
          "*.mandiri.co.id",
          "*.bca.co.id",
          "*.bni.co.id",
          "*.bri.co.id",
          "*.cimbniaga.co.id",
          "*.myxl.co.id",
          "*.tsel.com",
          "*.indosatooredoo.com",
          "*.axisnet.id"
        ]
      }
    ]
  },
  "stats": {},
  "api": {
    "services": ["StatsService"],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  }
}
END
sleep 0.5

# ===============================
# SYSTEMD SERVICES
# ===============================
echo -e "[ ${YELLOW}•${NC} ] Creating systemd services..."
cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
After=network.target nss-lookup.target
Documentation=https://github.com/xtls

[Service]
User=www-data
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
LimitNOFILE=1000000
LimitNPROC=10000

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/runn.service <<EOF
[Unit]
Description=Casper9 Helper Service
After=network.target

[Service]
Type=simple
ExecStartPre=-/usr/bin/mkdir -p /var/run/xray
ExecStart=/usr/bin/chown www-data:www-data /var/run/xray
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF
progress_bar 2 "Systemd services"

# ===============================
# 🌐 WEB CONFIG
# ===============================
echo -e "[ ${YELLOW}•${NC} ] Configuring Nginx & Haproxy..."
wget -q -O /etc/nginx/conf.d/xray.conf "${REPO}install/xray.conf"
wget -q -O /etc/haproxy/haproxy.cfg "${REPO}install/haproxy.cfg"
sed -i "s/xxx/$domain/g" /etc/nginx/conf.d/xray.conf
sed -i "s/xxx/$domain/g" /etc/haproxy/haproxy.cfg
cat /etc/xray/xray.key /etc/xray/xray.crt > /etc/haproxy/hap.pem
progress_bar 3 "Web config applied"

# ===============================
# 🚀 ENABLE SERVICES
# ===============================
rm -rf /etc/systemd/system/xray.service.d
systemctl daemon-reload
systemctl enable --now xray haproxy nginx runn >/dev/null 2>&1
progress_bar 2 "All services started"

# ===============================
# 🎯 FINAL PANEL
# ===============================
clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}   ✅  ${GREEN}XRAY INSTALLATION COMPLETED${NC}                               ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   🌐 Domain: ${YELLOW}$domain${NC}                                         ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   ⚙️  UUID: ${CYAN}$uuid${NC}                                          ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
