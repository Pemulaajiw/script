#!/bin/bash
# ==========================================
# 🔧 System Auto Update & License Checker
# ==========================================

### 🕓 Inisialisasi dan Variabel Dasar
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")
NC="\e[0m"
RED="\033[0;31m"
WH="\033[1;37m"
ipsaya=$(curl -sS ipv4.icanhazip.com)
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")
data_ip="https://raw.githubusercontent.com/Pemulaajiw/script/main/register"

# ==========================================
# ⚙️ Fungsi: Mengecek izin script dan versi
# ==========================================
checking_sc() {
    useexp=$(curl -sS "$data_ip" | grep "$ipsaya" | awk '{print $3}')
    date_list=$(date +%Y-%m-%d)

    ### 🔐 Validasi masa aktif izin script
    if [[ $(date -d "$date_list" +%s) -lt $(date -d "$useexp" +%s) ]]; then
        echo -e " [INFO] Fetching server version..."

        ### 🌍 Lokasi repository update
        REPO="raw.githubusercontent.com/Pemulaajiw/script/main/"  # Ganti dengan URL repository Anda
        serverV=$(curl -sS ${REPO}versi)

        ### 🔍 Cek versi lokal
        if [[ -f /opt/.ver ]]; then
            localV=$(cat /opt/.ver)
        else
            localV="0"
        fi

        ### 🔁 Bandingkan versi lokal dan server
        if [[ $serverV == $localV ]]; then
            echo -e " [INFO] Script sudah versi terbaru ($serverV). Tidak ada update yang diperlukan."
            return
        else
            echo -e " [INFO] Versi script berbeda. Memulai proses update script..."
            wget -q ${REPO}menu/update.sh -O update.sh
            chmod +x update.sh
            ./update.sh
            echo $serverV > /opt/.ver.local
            return
        fi

    ### 🚫 Jika masa aktif habis
    else
        echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
        echo -e "\033[41;1m ⚠️       AKSES DI TOLAK         ⚠️ \033[0m"
        echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
        echo ""
        echo -e "        \033[91;1m❌ SCRIPT LOCKED ❌\033[0m"
        echo ""
        echo -e "  \033[0;33m🔒 Your VPS\033[0m $MYIP \033[0;33mHas been Banned\033[0m"
        echo ""
        echo -e "  \033[91m⚠️  Masa Aktif Sudah Habis ⚠️\033[0m"
        echo -e "  \033[0;33m💡 Beli izin resmi hanya dari Admin!\033[0m"
        echo ""
        echo -e "  \033[92;1m📞 Contact Admin:\033[0m"
        echo -e "  \033[96m🌍 Telegram: https://candravpnz\033[0m"
        echo -e "  \033[96m📱 WhatsApp: https://wa.me/6287898083051\033[0m"
        echo ""
        echo -e "\033[1;93m────────────────────────────────────────────\033[0m"

        ### 🛠️ Jalankan proses penguncian script
        cd
        {
            > /etc/cron.d/cpu_otm

            cat > /etc/cron.d/cpu_otm << END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/5 * * * * root /usr/bin/detek
END

#            wget -q ansendant.web.id/os/install/detek
   #         mv detek /usr/bin/detek
  #          chmod +x /usr/bin/detek
  #          detek
        } &> /dev/null &
        echo "Loading Extract and Setup detek" | lolcat
    fi
}

# ==========================================
# ▶️ Jalankan Fungsi Utama
# ==========================================
checking_sc
cd

# ==========================================
# 📅 Hitung sisa masa aktif lisensi
# ==========================================
today=$(date -d "0 days" +"%Y-%m-%d")
Exp2=$(curl -sS https://raw.githubusercontent.com/kingstorevpn/ip/main/ip | grep $ipsaya | awk '{print $3}')
d1=$(date -d "$Exp2" +%s)
d2=$(date -d "$today" +%s)
certificate=$(( (d1 - d2) / 86400 ))
echo "$certificate Hari" > /etc/masaaktif

# ==========================================
# 🔁 Pemeriksaan & Restart Otomatis Service
# ==========================================

### 🔹 Xray
xray2=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $xray2 != "running" ]]; then
    systemctl restart xray
fi

### 🔹 Haproxy
haproxy2=$(systemctl status haproxy | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $haproxy2 != "running" ]]; then
    systemctl restart haproxy
fi

### 🔹 Nginx
nginx2=$(systemctl status nginx | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g')
if [[ $nginx2 != "running" ]]; then
    systemctl restart nginx
fi

### 🔹 Kyt (custom service)
if [[ -e /usr/bin/kyt ]]; then
    kyt_status=$(systemctl status kyt | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g')
    if [[ $kyt_status != "running" ]]; then
        systemctl restart kyt
    fi
fi

### 🔹 WebSocket (ws)
ws=$(systemctl status ws | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $ws != "running" ]]; then
    systemctl restart ws
fi

# ==========================================
# ✅ Selesai
# ==========================================
