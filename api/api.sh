#!/bin/bash
clear

# === Warna ===
green="\e[38;5;82m"
red="\e[38;5;196m"
neutral="\e[0m"
orange="\e[38;5;130m"
blue="\e[38;5;39m"
yellow="\e[38;5;226m"
purple="\e[38;5;141m"
bold_white="\e[1;37m"
pink="\e[38;5;205m"
reset="\e[0m"

# === Banner / Header ===
print_header() {
    echo -e "${green}⛓️  D£VSX-NETWORK v12.0.3 :: [Ω-Protocol]${neutral}"
    echo -e "${blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${neutral}"
    echo -e "   ⚙️  ${bold_white}Secure${neutral} | ${green}Fast${neutral} | ${purple}Adaptive${neutral} | ${yellow}Next-Gen${neutral}"
    echo -e "${blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${neutral}\n"
}

# === Rainbow Text ===
print_rainbow() {
    local text="$1"
    local length=${#text}
    local start_color=(0 5 0)
    local mid_color=(0 200 0)
    local end_color=(0 5 0)

    for ((i = 0; i < length; i++)); do
        local progress=$(echo "scale=2; $i / ($length - 1)" | bc)
        if (($(echo "$progress < 0.5" | bc -l))); then
            local factor=$(echo "scale=2; $progress * 2" | bc)
            r=$(echo "scale=0; (${start_color[0]} * (1-$factor) + ${mid_color[0]} * $factor)/1" | bc)
            g=$(echo "scale=0; (${start_color[1]} * (1-$factor) + ${mid_color[1]} * $factor)/1" | bc)
            b=$(echo "scale=0; (${start_color[2]} * (1-$factor) + ${mid_color[2]} * $factor)/1" | bc)
        else
            local factor=$(echo "scale=2; ($progress - 0.5) * 2" | bc)
            r=$(echo "scale=0; (${mid_color[0]} * (1-$factor) + ${end_color[0]} * $factor)/1" | bc)
            g=$(echo "scale=0; (${mid_color[1]} * (1-$factor) + ${end_color[1]} * $factor)/1" | bc)
            b=$(echo "scale=0; (${mid_color[2]} * (1-$factor) + ${end_color[2]} * $factor)/1" | bc)
        fi
        printf "\e[38;2;%d;%d;%dm%s" "$r" "$g" "$b" "${text:$i:1}"
    done
    echo -e "$reset"
}

# === Cek Status ===
cek_status() {
    if systemctl is-active --quiet "$1"; then
        echo -e "${green}🟢 ONLINE${neutral}"
    else
        echo -e "${red}🔴 OFFLINE${neutral}"
    fi
}

# === Setup Bot ===
setup_bot() {
    print_header
    print_rainbow "🚀 Initializing API-XWAN Setup..."

    NODE_VERSION=$(node -v 2>/dev/null | grep -oP '(?<=v)\d+' || echo "0")
    rm -f /var/lib/dpkg/stato* /var/lib/dpkg/lock*

    if [ "$NODE_VERSION" -lt 22 ]; then
        echo -e "${yellow}📦 Installing Node.js v22...${neutral}"
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        apt-get install -y nodejs
        npm install -g npm@latest
    else
        echo -e "${green}✅ Node.js v$NODE_VERSION already up-to-date.${neutral}"
    fi

    # === Extract API Files ===
    if [ ! -f /usr/bin/api-xwan/api.js ]; then
        echo -e "${blue}📁 Downloading API-XWAN package...${neutral}"
        curl -sL "https://raw.githubusercontent.com/Pemulaajiw/script/main/api/api-xwan.zip" -o /usr/bin/api-xwan.zip
        cd /usr/bin && 7z x -punlock-DiJual250wkwk api-xwan.zip >/dev/null 2>&1
        rm api-xwan.zip* && chmod +x api-xwan/* && cd
    fi

    # === Install Dependencies ===
    npm list --prefix /usr/bin/api-xwan express child_process >/dev/null 2>&1 || {
        echo -e "${yellow}📦 Installing dependencies...${neutral}"
        npm install --prefix /usr/bin/api-xwan express child_process
    }

    # === Generate AUTH_KEY ===
    NEW_AUTH_KEY=$(openssl rand -hex 3)
    sed -i '/export AUTH_KEY=/d' /etc/profile
    echo "export AUTH_KEY=\"$NEW_AUTH_KEY\"" >> /etc/profile
    source /etc/profile

    SERVER_IP=$(curl -sS ipv4.icanhazip.com)
    DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "(Domain not set)")

    echo -e "${purple}🤖 Enter Telegram Bot Token:${neutral}"
    read -rp "Token: " BOT_TOKEN
    echo -e "${purple}💬 Enter Telegram Chat ID:${neutral}"
    read -rp "Chat ID: " CHAT_ID

    echo "export KEYAPI=\"$BOT_TOKEN\"" >/etc/botapi.conf
    echo "export CHATID=\"$CHAT_ID\"" >>/etc/botapi.conf
    grep -q "botapi.conf" /etc/profile || echo "source /etc/botapi.conf" >> /etc/profile
    source /etc/botapi.conf

    MESSAGE="🚀 *api-xwan Installed Successfully* 🚀
🔑 *Auth Key:* \`$AUTH_KEY\`
🌐 *Server IP:* \`$SERVER_IP\`
🌍 *Domain:* \`$DOMAIN\`"

    curl -s -X POST "https://api.telegram.org/bot$KEYAPI/sendMessage" \
        -d "chat_id=$CHATID" \
        -d "text=$MESSAGE" \
        -d "parse_mode=Markdown"

    echo -e "\n${green}✅ Setup Complete! Auth Key sent to your Telegram.${neutral}"
    echo -e "${blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${neutral}\n"
}

# === Server App Config ===
server_app() {
    print_rainbow "⚙️ Configuring System Service..."

    cat >/etc/systemd/system/apisellvpn.service <<EOF
[Unit]
Description=App Bot sellvpn Service
After=network.target

[Service]
ExecStart=/bin/bash /usr/bin/apisellvpn
Restart=always
User=root
Environment=PATH=/usr/bin:/usr/local/bin
Environment=NODE_ENV=production
WorkingDirectory=/usr/bin

[Install]
WantedBy=multi-user.target
EOF

    cat >/usr/bin/apisellvpn <<EOF
#!/bin/bash
source /etc/profile
cd /usr/bin/api-xwan
node api.js
EOF

    chmod +x /usr/bin/apisellvpn

    # Cek dan hentikan port 5888 jika aktif
    CEK_PORT=$(lsof -i:5888 | awk 'NR>1 {print $2}' | sort -u)
    if [[ -n "$CEK_PORT" ]]; then
        echo -e "${orange}🔧 Closing port 5888...${neutral}"
        echo "$CEK_PORT" | xargs kill -9
    fi

    systemctl daemon-reload >/dev/null 2>&1
    systemctl enable apisellvpn.service >/dev/null 2>&1
    systemctl restart apisellvpn.service >/dev/null 2>&1

    echo -e "\n${blue}🔍 Server Status: $(cek_status apisellvpn.service)${neutral}"
    echo -e "${green}✨ All systems operational!${neutral}\n"
}

# === Main ===
setup_bot
server_app
