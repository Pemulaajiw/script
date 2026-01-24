#!/bin/bash
# ==========================================
# Limit Service Installer - Newbie Store
# Author: Ansendant (modified by ChatGPT)
# Repo: https://raw.githubusercontent.com/Pemulaajiw/script/main/
# ==========================================

REPO="https://raw.githubusercontent.com/Pemulaajiw/script/main/"

# ------------------------------------------
# Prepare systemd dan direktori kerja
# ------------------------------------------
cd
systemctl daemon-reload

# ------------------------------------------
# Download systemd service untuk limit klasik
# ------------------------------------------
echo "[INFO] Mengunduh file systemd service versi lama..."
wget -q -O /etc/systemd/system/limitvmess.service "${REPO}install/limitvmess.service" && chmod +x /etc/systemd/system/limitvmess.service
wget -q -O /etc/systemd/system/limitvless.service "${REPO}install/limitvless.service" && chmod +x /etc/systemd/system/limitvless.service
wget -q -O /etc/systemd/system/limittrojan.service "${REPO}install/limittrojan.service" && chmod +x /etc/systemd/system/limittrojan.service

# Jika mau aktifkan Shadowsocks
# wget -q -O /etc/systemd/system/limitshadowsocks.service "${REPO}install/limitshadowsocks.service" && chmod +x /etc/systemd/system/limitshadowsocks.service

# ------------------------------------------
# Reload daemon dan enable service lama
# ------------------------------------------
echo "[INFO] Reload systemd daemon..."
systemctl daemon-reload

echo "[INFO] Enable & start classic services..."
systemctl enable --now limitvmess
systemctl enable --now limitvless
systemctl enable --now limittrojan
# systemctl enable --now limitshadowsocks

# ------------------------------------------
# Start service klasik (jika belum jalan)
# ------------------------------------------
systemctl start limitvmess
systemctl start limitvless
systemctl start limittrojan
# systemctl start limitshadowsocks

echo -e "\033[1;32m[SUCCESS]\033[0m Semua limit service klasik berhasil diaktifkan!"
echo
function limit-ip(){
# =======================================================
# ✨ Tambahan: versi systemd-template baru (limit-ip@)
# =======================================================

echo "[INFO] Menambahkan versi systemd-template (limit-ip@)..."
# Menghapus limit ip lama
rm -rf /usr/local/sbin/limit-ip

# Script utama
wget -q -O /usr/local/sbin/unlockxray "${REPO}install/unlockxray" && chmod +x /usr/local/sbin/unlockxray
wget -q -O /usr/local/sbin/limit-ip "${REPO}install/limit-ip" && chmod +x /usr/local/sbin/limit-ip
cd /usr/local/sbin/
sed -i 's/\r//' limit-ip
cd
# Template service
cat > /etc/systemd/system/limit-ip@.service <<'EOF'
[Unit]
Description=Limit-IP AutoLock for %i
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/limit-ip %i
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
EOF

# Template timer
cat > /etc/systemd/system/limit-ip@.timer <<'EOF'
[Unit]
Description=Run limit-ip %i every 1 minute

[Timer]
OnBootSec=30s
OnUnitActiveSec=1min
AccuracySec=10s
Unit=limit-ip@%i.service

[Install]
WantedBy=timers.target
EOF

# Reload dan aktifkan
systemctl daemon-reload
systemctl enable --now limit-ip@vmip.timer
systemctl enable --now limit-ip@vlip.timer
systemctl enable --now limit-ip@trip.timer

echo
echo "[INFO] Timer instance aktif:"
systemctl list-timers | grep limit-ip@ || echo "Belum aktif, cek manual dengan: systemctl list-timers"
echo
echo -e "\033[1;32m[SUCCESS]\033[0m Sistem limit-ip template berhasil diinstal & berjalan otomatis!"
echo
}
limit-ip