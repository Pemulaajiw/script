#!/bin/bash
MYIP=$(curl -sS ipv4.icanhazip.com)

#install
cp /media/cybervpn/var.txt /tmp
cp /root/cybervpn/var.txt /tmp
rm -rf cybervpn
apt update && apt upgrade -y
apt install python3 python3-pip -y
apt install sqlite3 -y
cd /media/
rm -rf cybervpn
wget https://raw.githubusercontent.com/Pemulaajiw/script_allos/main/menu/cybervpn.zip
unzip cybervpn.zip
cd cybervpn
rm var.txt
rm database.db
pip3 install -r requirements.txt
pip install pillow
pip install speedtest-cli
pip3 install aiohttp
pip3 install paramiko
clear
rm -rf bot
rm bot.*
cd /usr/bin
wget https://raw.githubusercontent.com/Pemulaajiw/script/main/fanst/bot.zip
7z x -pFanVpnID0311 bot.zip
mv bot/* /usr/bin
chmod +x /usr/bin/*
rm -rf bot.zip
#isi data
nsdom=$(cat /root/nsdomain)
domain=$(cat /etc/xray/domain)
clear
clear
VERSION=$(grep "VERSION_ID" /etc/os-release | cut -d'"' -f2)
OS=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')

# Fungsi untuk menginstal di Debian 11 atau lebih rendah dan Ubuntu 18.04, 20.04
install_debian11_ubuntu20_down() {
    echo "Deteksi $OS versi $VERSION atau lebih rendah..."
    pip3 install -r cybervpn/requirements.txt
}

install_debian12_ubuntu22_up() {
    echo "Deteksi $OS versi $VERSION atau lebih tinggi..."
    pip3 install -r cybervpn/requirements.txt --break-system-packages
}

if [[ "$OS" == "debian" ]]; then
    if (( $(echo "$VERSION < 12" | bc -l) )); then
        install_debian11_ubuntu20_down
    else
        install_debian12_ubuntu22_up
    fi
elif [[ "$OS" == "ubuntu" ]]; then
    if (( $(echo "$VERSION < 22.04" | bc -l) )); then
        install_debian11_ubuntu20_down
    else
        install_debian12_ubuntu22_up
    fi
elif [[ "$OS" == "ubuntu" ]]; then
    if (( $(echo "$VERSION < 24.04" | bc -l) )); then
        install_debian11_ubuntu20_down
    else
        install_debian12_ubuntu22_up
    fi
elif [[ "$OS" == "ubuntu" ]]; then
    if (( $(echo "$VERSION < 25.04" | bc -l) )); then
        install_debian11_ubuntu20_down
    else
        install_debian12_ubuntu22_up
    fi
else
    echo "Distribusi tidak dikenali. Hanya mendukung Debian dan Ubuntu."
fi
echo
echo -e "\033[97m◇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◇\033[0m"
echo -e " \e[44;97;1m          ADD BOT CYBERVPN         \033[0m"
echo -e "\033[97m◇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◇\033[0m"
read -e -p "Masukkan Bot Token: " token
read -e -p "Masukkan ID Telegram :" admin

echo "$token" > /root/.notifbot
echo "$admin" >> /root/.notifbot

cat > /media/cybervpn/var.txt << END
ADMIN="$admin"
BOT_TOKEN="$token"
DOMAIN="$domain"
DNS="$nsdom"
PUB="7fbd1f8aa0abfe15a7903e837f78aba39cf61d36f183bd604daa2fe4ef3b7b59"
OWN="$user"
SALDO="100000"
END


