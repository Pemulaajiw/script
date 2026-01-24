#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║   ⛓️  -NETWORK :: SYSTEM BOOTSTRAP & OPTIMIZE (Next-Gen)     ║
# ║    Installs: core tools, web, vpn, haproxy, vnstat, badvpn, bbr  ║
# ╚══════════════════════════════════════════════════════════════════╝
set -o errexit
set -o nounset
set -o pipefail

# ---------------------------
# 🎨 Colors & helpers
# ---------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERR ]${NC} $*"; exit 1; }

progress() {
  local msg=$1; local secs=${2:-1}
  printf "%s " "${CYAN}[..]${NC} ${msg}"
  sleep "$secs"
  echo -e " ${GREEN}done${NC}"
}

# ---------------------------
# ⚙️ Vars & repo
# ---------------------------
REPO="https://raw.githubusercontent.com/Pemulaajiw/script/main/"
export DEBIAN_FRONTEND=noninteractive

# get primary network interface (non-empty)
NET_IFACE=$(ip -o -4 route show to default 2>/dev/null | awk '{print $5}' | head -n1 || echo "eth0")
MYIP=$(wget -qO- ipinfo.io/ip || curl -sS https://ipv4.icanhazip.com || echo "0.0.0.0")
MYIP_PLACEHOLDER="s/xxxxxxxxx/${MYIP}/g"

# OS detection
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  OS_NAME=${ID:-unknown}
  OS_VERSION=${VERSION_ID:-unknown}
  info "Detected OS: ${OS_NAME} ${OS_VERSION}"
else
  err "Cannot detect OS. Exiting."
fi

# ---------------------------
# 0) Quick header
# ---------------------------
clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}   ⛓️  -NETWORK :: Bootstrap & Optimization (Next-Gen)    ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo

# ---------------------------
# 1) System update & essentials
# ---------------------------
info "Updating system packages (this may take a while)..."
apt update -y >/dev/null 2>&1 || true
apt upgrade -y >/dev/null 2>&1 || true
apt dist-upgrade -y >/dev/null 2>&1 || true
ok "System updated"

info "Installing essential packages..."
PKGS=(screen curl jq bzip2 gzip vnstat coreutils rsyslog iftop zip unzip git apt-transport-https build-essential netfilter-persistent figlet ruby lolcat php php-fpm php-cli php-mysql libxml-parser-perl neofetch lsof htop net-tools wget nano sed gnupg bc dirmngr)
apt-get install -y "${PKGS[@]}" >/dev/null 2>&1 || warn "Some packages failed to install (check network/repo)."
ok "Essential packages installed"

# ensure lolcat installed via gem (may require ruby)
if ! command -v lolcat >/dev/null 2>&1; then
  gem install lolcat >/dev/null 2>&1 || warn "lolcat install failed"
fi

# ---------------------------
# 2) Remove unwanted services
# ---------------------------
info "Removing firewall managers that may conflict (ufw, firewalld)..."
apt-get remove --purge -y ufw firewalld >/dev/null 2>&1 || true
ok "Firewall managers removed (if present)"

# ---------------------------
# 3) rc.local service (compat)
# ---------------------------
info "Ensuring rc.local compatibility service..."
cat > /etc/systemd/system/rc-local.service <<'EOF'
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/rc.local <<'EOF'
#!/bin/sh -e
# rc.local stub for compatibility
exit 0
EOF

chmod +x /etc/rc.local
systemctl daemon-reload
systemctl enable --now rc-local.service >/dev/null 2>&1 || warn "rc-local enable failed"
ok "rc.local service ensured"

# ---------------------------
# 4) Kernel / IPv6 tweaks
# ---------------------------
info "Disabling IPv6 (runtime) and ensuring persistence..."
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 || true
if ! grep -q "disable_ipv6" /etc/rc.local 2>/dev/null; then
  sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
fi
ok "IPv6 disabled"

# ---------------------------
# 5) Webstack: nginx + php
# ---------------------------
info "Installing and configuring Nginx + PHP-FPM..."
apt-get install -y nginx certbot >/dev/null 2>&1 || warn "nginx/certbot install failed"
# replace default configs with repo ones if available
if wget -q -O /etc/nginx/nginx.conf "${REPO}install/nginx.conf"; then
  ok "nginx.conf fetched"
fi
if wget -q -O /etc/nginx/conf.d/vps.conf "${REPO}install/vps.conf"; then
  ok "vps.conf fetched"
fi

# PHP-FPM socket -> TCP
if [[ -f /etc/php/7.4/fpm/pool.d/www.conf ]]; then
  sed -i 's/listen = \/var\/run\/php\/php7.4-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php/7.4/fpm/pool.d/www.conf || true
fi
# generic replacement (older/newer PHP)
sed -i 's@listen = /var/run/php-fpm.sock@listen = 127.0.0.1:9000@g' /etc/php/*/fpm/pool.d/* 2>/dev/null || true

mkdir -p /home/vps/public_html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
chown -R www-data:www-data /home/vps/public_html
chmod -R g+rw /home/vps/public_html

# fetch index.html if exists
wget -q -O /home/vps/public_html/index.html "${REPO}install/index.html1" || true
systemctl restart nginx >/dev/null 2>&1 || warn "nginx restart failed"
ok "Webserver ready"

# ---------------------------
# 6) badvpn (udp2raw-like helpers)
# ---------------------------
info "Installing badvpn binary & services..."
wget -q -O /usr/sbin/badvpn "${REPO}install/badvpn" || warn "badvpn fetch failed"
chmod +x /usr/sbin/badvpn || true

for i in 1 2 3; do
  svc="/etc/systemd/system/badvpn${i}.service"
  if wget -q -O "${svc}" "${REPO}install/badvpn${i}.service"; then
    systemctl daemon-reload
    systemctl enable --now badvpn${i} >/dev/null 2>&1 || warn "badvpn${i} enable failed"
  fi
done
ok "badvpn services configured"

# ---------------------------
# 7) SSH & Dropbear tweaks
# ---------------------------
info "Configuring SSH ports & authentication..."
SSH_CONF='/etc/ssh/sshd_config'

# enable password auth (awal)
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' "$SSH_CONF" || true

# remove existing Port lines and add desired ports (idempotent)
sed -i '/^Port /d' "$SSH_CONF"
cat >> "$SSH_CONF" <<'EOF'
Port 22
Port 500
Port 40000
Port 51443
Port 58080
Port 200
Port 2222
Port 2223
EOF
systemctl restart ssh >/dev/null 2>&1 || warn "ssh restart failed"
ok "SSH configured"

info "Installing & configuring Dropbear..."
apt-get install -y dropbear >/dev/null 2>&1 || warn "dropbear install failed"
wget -q -O /etc/default/dropbear "${REPO}install/dropbear" || true
dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key >/dev/null 2>&1 || true
chmod 600 /etc/dropbear/dropbear_dss_host_key >/dev/null 2>&1 || true
grep -Fxq "/bin/false" /etc/shells || echo "/bin/false" >> /etc/shells
grep -Fxq "/usr/sbin/nologin" /etc/shells || echo "/usr/sbin/nologin" >> /etc/shells
systemctl restart dropbear >/dev/null 2>&1 || warn "dropbear restart failed"
ok "Dropbear setup complete"

# ---------------------------
# ✅ FIX: pastikan OpenSSH tetap utama & password login jalan
# ---------------------------
info "Ensuring OpenSSH remains primary & password logins are allowed..."

# Pastikan PasswordAuthentication YES
if grep -q "^#\?PasswordAuthentication" "$SSH_CONF"; then
  sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$SSH_CONF" || true
else
  echo "PasswordAuthentication yes" >> "$SSH_CONF"
fi

# Izinkan root login (kalau kamu pakai root di Termius)
if grep -q "^#\?PermitRootLogin" "$SSH_CONF"; then
  sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' "$SSH_CONF" || true
else
  echo "PermitRootLogin yes" >> "$SSH_CONF"
fi

# Hapus aturan AuthenticationMethods kalau ada (kadang bikin key-only)
sed -i '/^AuthenticationMethods/d' "$SSH_CONF" || true

# Pastikan port 22 tetap ada
if ! grep -q "^Port 22" "$SSH_CONF"; then
  echo "Port 22" >> "$SSH_CONF"
fi

# Aktifkan dan restart SSH
systemctl enable ssh >/dev/null 2>&1 || true
systemctl restart ssh >/dev/null 2>&1 || warn "ssh restart failed"
ok "OpenSSH password authentication ensured"

# ---------------------------
# 8) Squid proxy
# ---------------------------
info "Installing Squid proxy..."
if [[ "${OS_NAME}" == "debian" && "${OS_VERSION%%.*}" -eq 10 ]] || [[ "${OS_NAME}" == "ubuntu" && "${OS_VERSION%%.*}" -eq 20 ]]; then
  apt-get install -y squid3 >/dev/null 2>&1 || warn "squid3 install failed"
else
  apt-get install -y squid >/dev/null 2>&1 || warn "squid install failed"
fi
if wget -q -O /etc/squid/squid.conf "${REPO}install/squid3.conf"; then
  sed -i "${MYIP_PLACEHOLDER}" /etc/squid/squid.conf || true
  systemctl restart squid >/dev/null 2>&1 || warn "squid restart failed"
  ok "Squid configured"
else
  warn "Failed to fetch squid conf"
fi

# ---------------------------
# 9) vnStat (monitor bandwidth)
# ---------------------------
info "Installing vnStat from source to ensure latest support..."
apt-get install -y libsqlite3-dev >/dev/null 2>&1 || true
wget -q https://humdi.net/vnstat/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz >/dev/null 2>&1 || true
cd vnstat-2.6 || true
./configure --prefix=/usr --sysconfdir=/etc >/dev/null 2>&1 || true
make >/dev/null 2>&1 || true
make install >/dev/null 2>&1 || true
cd
rm -rf vnstat-2.6 vnstat-2.6.tar.gz || true

# register interface
vnstat -u -i "$NET_IFACE" >/dev/null 2>&1 || true
sed -i "s@Interface \"eth0\"@Interface \"${NET_IFACE}\"@g" /etc/vnstat.conf || true
chown -R vnstat:vnstat /var/lib/vnstat || true
systemctl enable --now vnstat >/dev/null 2>&1 || warn "vnstat enable failed"
ok "vnStat installed and configured"

# ---------------------------
# 10) HAProxy
# ---------------------------
info "Installing/ensuring HAProxy..."
if ! dpkg -l | grep -q haproxy; then
  apt-get install -y haproxy >/dev/null 2>&1 || warn "haproxy install failed"
fi
if wget -q -O /etc/haproxy/haproxy.cfg "${REPO}install/haproxy.cfg"; then
  ok "haproxy.cfg fetched"
fi
systemctl daemon-reload
systemctl enable --now haproxy >/dev/null 2>&1 || warn "haproxy enable/start failed"
ok "HAProxy running"

# ---------------------------
# 11) OpenVPN, lolcat (external scripts)
# ---------------------------
info "Running external install scripts (vpn, lolcat)..."
if wget -q -O /root/vpn.sh "${REPO}install/vpn.sh"; then
  chmod +x /root/vpn.sh && bash /root/vpn.sh || warn "vpn.sh failed"
fi
if wget -q -O /root/lolcat.sh "${REPO}install/lolcat.sh"; then
  chmod +x /root/lolcat.sh && bash /root/lolcat.sh || warn "lolcat.sh failed"
fi
ok "External scripts executed (if downloaded)"

# ---------------------------
# 12) Swapfile 1GB
# ---------------------------
info "Creating 1GB swapfile..."
if [[ ! -f /swapfile ]]; then
  dd if=/dev/zero of=/swapfile bs=1M count=1024 status=none || warn "dd swap failed"
  mkswap /swapfile >/dev/null 2>&1 || warn "mkswap failed"
  chown root:root /swapfile
  chmod 0600 /swapfile
  swapon /swapfile || warn "swapon failed"
  grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi
ok "Swapfile ready"

# ---------------------------
# 13) Fail2ban & DOS-Deflate
# ---------------------------
info "Installing fail2ban..."
apt-get install -y fail2ban >/dev/null 2>&1 || warn "fail2ban install failed"
ok "fail2ban installed"

info "Installing DOS-Deflate (simple ddos mitigation)..."
if [[ ! -d /usr/local/ddos ]]; then
  mkdir -p /usr/local/ddos
  wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf || true
  wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE || true
  wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list || true
  wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh || true
  chmod 0755 /usr/local/ddos/ddos.sh || true
  ln -sf /usr/local/ddos/ddos.sh /usr/local/bin/ddos
  /usr/local/ddos/ddos.sh --cron >/dev/null 2>&1 || true
fi
ok "DOS-Deflate installed (if resources available)"

# ---------------------------
# 14) Issue banner & syslog tweaks
# ---------------------------
info "Updating /etc/issue.net and rsyslog..."
wget -q -O /etc/issue.net "${REPO}install/issue.net" || true
# remote rsyslog config if provided:
if wget -q -O /root/setrsyslog.sh "${REPO}install/setrsyslog.sh"; then
  chmod +x /root/setrsyslog.sh && bash /root/setrsyslog.sh || warn "setrsyslog script failed"
fi
ok "Banner & rsyslog done"

# ---------------------------
# 15) Kernel tuning & BBR
# ---------------------------
info "Installing BBR & kernel optimizations..."
if wget -q -O /root/bbr.sh "${REPO}install/bbr.sh"; then
  chmod +x /root/bbr.sh && bash /root/bbr.sh || warn "bbr script failed"
fi
ok "BBR & kernel tweaks applied (if script available)"

# ---------------------------
# 16) ipserver & torrent block rules
# ---------------------------
info "Applying ipserver & iptables torrent-block rules..."
if wget -q -O /root/ipserver "${REPO}install/ipserver"; then
  chmod +x /root/ipserver && /root/ipserver || true
fi

# torrent block patterns
for pat in "get_peers" "announce_peer" "find_node" "BitTorrent" "BitTorrent protocol" "peer_id=" ".torrent" "announce.php?passkey=" "torrent" "announce" "info_hash"; do
  iptables -A FORWARD -m string --algo bm --string "$pat" -j DROP >/dev/null 2>&1 || true
done
iptables-save > /etc/iptables.up.rules || true
iptables-restore -t < /etc/iptables.up.rules || true
netfilter-persistent save >/dev/null 2>&1 || true
netfilter-persistent reload >/dev/null 2>&1 || true
ok "iptables rules applied"

# ---------------------------
# 17) Cron jobs
# ---------------------------
info "Installing cron jobs for maintenance..."
cat > /etc/cron.d/xp_otm <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/local/sbin/xp
EOF

cat > /etc/cron.d/bckp_otm <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 22 * * * root /usr/local/sbin/backup
EOF

cat > /etc/cron.d/cpu_otm <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/5 * * * * root /usr/bin/autocpu
EOF

# autocpu helper
wget -q -O /usr/bin/autocpu "${REPO}install/autocpu.sh" && chmod +x /usr/bin/autocpu || true

cat > /etc/cron.d/xp_sc <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
1 0 * * * root /usr/local/sbin/expsc
EOF

cat > /etc/cron.d/logclean <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/10 * * * * root truncate -s 0 /var/log/syslog \
    && truncate -s 0 /var/log/nginx/error.log \
    && truncate -s 0 /var/log/nginx/access.log \
    && truncate -s 0 /var/log/xray/error.log \
    && truncate -s 0 /var/log/xray/access.log
EOF

cat > /etc/cron.d/daily_reboot <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
5 0 * * * root /sbin/reboot
EOF

systemctl restart cron >/dev/null 2>&1 || true
ok "Cron jobs installed"

# ---------------------------
# 18) Cleanup & final tweaks
# ---------------------------
info "Cleaning up unused packages and files..."
apt autoclean -y >/dev/null 2>&1 || true
apt-get -y --purge remove samba* apache2* bind9* exim4 sendmail* >/dev/null 2>&1 || true
apt autoremove -y >/dev/null 2>&1 || true

chown -R www-data:www-data /home/vps/public_html || true

# remove installer leftovers if present
rm -f /root/key.pem /root/cert.pem /root/ssh-vpn.sh /root/bbr.sh 2>/dev/null || true
rm -rf /etc/apache2 2>/dev/null || true

clear
echo
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║ ✅  -NETWORK Bootstrap Completed                         ║${NC}"
echo -e "${GREEN}║ ✅  Reboot recommended for kernel tweaks & swap activation    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${CYAN}Summary:${NC}"
echo -e "  - IP: ${YELLOW}${MYIP}${NC}"
echo -e "  - Interface: ${YELLOW}${NET_IFACE}${NC}"
echo -e "  - Web root: ${YELLOW}/home/vps/public_html${NC}"
echo
echo -e "${YELLOW}Tip:${NC} Check services with 'systemctl status haproxy nginx xray vnstat' and logs in /var/log/"
echo
