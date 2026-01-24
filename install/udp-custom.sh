#!/bin/bash
# ==================================================
# UDP Custom Installer by ePro Dev. Team
# ==================================================

# Pindah ke root directory dan buat folder untuk UDP
cd
mkdir -p /root/udp

# Set timezone ke GMT+7 (Jakarta)
echo "📅 Setting timezone ke GMT+7..."
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# ==================================================
# Download udp-custom binary
# ==================================================
echo "⬇️  Mengunduh udp-custom..."
wget -q --show-progress --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1_VyhL5BILtoZZTW4rhnUiYzc4zHOsXQ8' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1_VyhL5BILtoZZTW4rhnUiYzc4zHOsXQ8" \
-O /root/udp/udp-custom && rm -rf /tmp/cookies.txt
chmod +x /root/udp/udp-custom

# Download default config
echo "⬇️  Mengunduh konfigurasi default..."
wget -q --show-progress --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1_XNXsufQXzcTUVVKQoBeX5Ig0J7GngGM' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1_XNXsufQXzcTUVVKQoBeX5Ig0J7GngGM" \
-O /root/udp/config.json && rm -rf /tmp/cookies.txt
chmod 644 /root/udp/config.json

# ==================================================
# Setup systemd service
# ==================================================
echo "⚙️  Membuat service systemd udp-custom..."
SERVICE_FILE="/etc/systemd/system/udp-custom.service"

if [ -z "$1" ]; then
    cat <<EOF > $SERVICE_FILE
[Unit]
Description=UDP Custom by ePro Dev. Team

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
else
    cat <<EOF > $SERVICE_FILE
[Unit]
Description=UDP Custom by ePro Dev. Team

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server -exclude $1
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
fi

# ==================================================
# Start & enable service
# ==================================================
echo "🚀 Menjalankan service udp-custom..."
systemctl daemon-reload
systemctl start udp-custom
systemctl enable udp-custom

echo "✅ UDP Custom telah berhasil dijalankan dan di-enable!"
