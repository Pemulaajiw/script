#!/bin/bash
# ╔════════════════════════════════════════════════════╗
# ║   ⛓️  D£VSX-NETWORK :: [Installer - Bandwidth Tool] ║
# ║        Rclone + Wondershaper + Limit Setup         ║
# ╚════════════════════════════════════════════════════╝

set -e

# ──────────────────────────────
# 🎨 Warna Tampilan
# ──────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ──────────────────────────────
# ⚙️  Variabel Utama
# ──────────────────────────────
REPO="https://raw.githubusercontent.com/Pemulaajiw/script/main/"
RCLONE_CONF="${REPO}config/rclone.conf"

# ──────────────────────────────
# 🧩 Header Tampilan
# ──────────────────────────────
clear
echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}   ${GREEN}-NETWORK :: Auto Setup Tools${NC}       ${BLUE}║${NC}"
echo -e "${BLUE}╠═══════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║${NC}   ⚙️  Installing Rclone, Wondershaper, Limit   ${BLUE}║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
echo

# ──────────────────────────────
# 📦 Install Rclone
# ──────────────────────────────
info "Installing Rclone..."
apt install -y rclone >/dev/null 2>&1 || error "Failed to install Rclone"
printf "q\n" | rclone config >/dev/null 2>&1
wget -q -O /root/.config/rclone/rclone.conf "${RCLONE_CONF}" || error "Failed to fetch Rclone config"
ok "Rclone installed and configured."

# ──────────────────────────────
# ⚙️  Install Wondershaper
# ──────────────────────────────
info "Installing Wondershaper (bandwidth limiter)..."
git clone -q https://github.com/casper9/wondershaper.git || error "Failed to clone wondershaper repo"
cd wondershaper
make install >/dev/null 2>&1 || error "Wondershaper install failed"
cd
rm -rf wondershaper
ok "Wondershaper installed successfully."

# ──────────────────────────────
# 📜 Download & Jalankan limit.sh
# ──────────────────────────────
info "Downloading and running limit.sh script..."
wget -q "${REPO}install/limit.sh" -O /root/limit.sh || error "Failed to download limit.sh"
chmod +x /root/limit.sh
bash /root/limit.sh
ok "Bandwidth limit configuration applied."

# ──────────────────────────────
# 🧹 Bersihkan File Lama
# ──────────────────────────────
info "Cleaning up unused files..."
rm -f /root/set-br.sh 2>/dev/null
ok "Cleanup completed."

# ──────────────────────────────
# ✅ Selesai
# ──────────────────────────────
echo
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ INSTALLATION COMPLETE - ALL SYSTEM READY ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo
echo -e "${CYAN}You can now manage bandwidth limits using:${NC}"
echo -e "  ${YELLOW}limit.sh${NC}  → Configure and control interface speed."
echo

sleep 2
exit 0
