#!/bin/bash
# ╔════════════════════════════════════════════════════════╗
# ║   ⛓️  D£VSX-NETWORK :: Domain & Cloudflare Auto-Create ║
# ║        Generate random subdomain + create CF records  ║
# ╚════════════════════════════════════════════════════════╝

set -o errexit
set -o pipefail
set -o nounset

# ---------------------------
# 🎨 Warna & util
# ---------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()      { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()     { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------------------------
# 🌐 Konfigurasi (edit bila perlu)
# ---------------------------
REPO="https://raw.githubusercontent.com/Pemulaajiw/script/main/"
DOMAIN="klmpkfsvpn.me"            # domain utama (jangan ganti jika ingin otomatis)
# Cara aman: export CF_ID & CF_KEY di shell sebelum menjalankan script,
# atau ganti baris di bawah ini jika mau hardcode (tidak disarankan).
CF_ID="${CF_ID:-mbahkoid13@gmail.com}"
CF_KEY="${CF_KEY:-a527f7da45eba65e5ce033619e5debe2a42e9}"

# ---------------------------
# ⏳ Instal dependency
# ---------------------------
install_deps() {
  info "Install dependency: jq & curl (jika belum)"
  apt-get update -y >/dev/null 2>&1 || true
  DEPS=(jq curl)
  apt-get install -y "${DEPS[@]}" >/dev/null 2>&1
  ok "Dependency terpasang"
}

# ---------------------------
# 🗂 Persiapan direktori
# ---------------------------
prepare_directories() {
  info "Persiapan direktori /root/xray"
  rm -f /root/xray/scdomain 2>/dev/null || true
  mkdir -p /root/xray
  clear
  ok "Direktori siap"
}

# ---------------------------
# 🎲 Generate random subdomain
# ---------------------------
generate_random_subdomains() {
  info "Generate random subdomain..."
  sub=$(tr -dc 'a-z0-9' </dev/urandom | head -c5 || echo "rnd01")
  subsl=$(tr -dc 'a-z0-9' </dev/urandom | head -c5 || echo "ns01")
  SUB_DOMAIN="${sub}.${DOMAIN}"
  NS_DOMAIN="${subsl}.ns.${DOMAIN}"
  ok "Generated: ${SUB_DOMAIN}  (NS: ${NS_DOMAIN})"
}

# ---------------------------
# 🌍 Ambil IP publik
# ---------------------------
get_public_ip() {
  info "Mendapatkan IP publik..."
  IP=$(curl -sS https://ifconfig.me || curl -sS https://ipv4.icanhazip.com || echo "")
  if [[ -z "$IP" ]]; then
    err "Gagal mendapatkan IP publik"
    exit 1
  fi
  ok "Public IP: $IP"
}

# ---------------------------
# 🧾 Ambil Cloudflare Zone ID
# ---------------------------
get_cloudflare_zone_id() {
  info "Mengambil Cloudflare Zone ID untuk: ${DOMAIN}"
  ZONE=$(curl -sSX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" | jq -r '.result[0].id // empty')

  if [[ -z "$ZONE" ]]; then
    err "Gagal mengambil Zone ID. Periksa CF_ID / CF_KEY dan domain ${DOMAIN}."
    exit 1
  fi
  ok "Zone ID: ${ZONE}"
}

# ---------------------------
# 🔁 Create or Update DNS record
# ---------------------------
update_or_create_record() {
  local record_type=$1
  local name=$2
  local content=$3

  info "Proses DNS ${record_type} -> ${name} : ${content}"

  # Cek record ada
  RECORD_ID=$(curl -sSX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${name}" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" | jq -r '.result[0].id // empty')

  if [[ -z "$RECORD_ID" ]]; then
    info "Record tidak ditemukan, membuat baru..."
    RESPONSE=$(curl -sSX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
      -H "X-Auth-Email: ${CF_ID}" \
      -H "X-Auth-Key: ${CF_KEY}" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"${record_type}\",\"name\":\"${name}\",\"content\":\"${content}\",\"ttl\":120,\"proxied\":false}")
    RECORD_ID=$(echo "$RESPONSE" | jq -r '.result.id // empty')
    if [[ -z "$RECORD_ID" ]]; then
      err "Gagal membuat DNS record untuk ${name}"
      echo "$RESPONSE" | jq -r '.errors[]?.message // empty' 2>/dev/null || true
      exit 1
    fi
    ok "Record dibuat (ID: ${RECORD_ID})"
  else
    info "Record ditemukan (ID: ${RECORD_ID}), mengupdate..."
    RESPONSE=$(curl -sSX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD_ID}" \
      -H "X-Auth-Email: ${CF_ID}" \
      -H "X-Auth-Key: ${CF_KEY}" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"${record_type}\",\"name\":\"${name}\",\"content\":\"${content}\",\"ttl\":120,\"proxied\":false}")
    SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
    if [[ "$SUCCESS" != "true" ]]; then
      err "Gagal mengupdate DNS record ${name}"
      echo "$RESPONSE" | jq -r '.errors[]?.message // empty' 2>/dev/null || true
      exit 1
    fi
    ok "Record ${name} diperbarui"
  fi
}

# ---------------------------
# 🖴 Simpan konfigurasi ke file
# ---------------------------
save_configuration() {
  info "Menyimpan konfigurasi ke file..."
  mkdir -p /var/lib/kyt
  echo "IP=${SUB_DOMAIN}" >/var/lib/kyt/ipvps.conf
  echo "${SUB_DOMAIN}" >/root/domain
  echo "${NS_DOMAIN}" >/root/dns
  echo "${SUB_DOMAIN}" >/etc/xray/domain
  echo "${NS_DOMAIN}" >/etc/xray/dns
  ok "Konfigurasi tersimpan"
}

# ---------------------------
# ℹ️ Tampilkan ringkasan
# ---------------------------
display_info() {
  echo
  echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║${NC}  ${GREEN}Domain Info${NC}                       ${BLUE}║${NC}"
  echo -e "${BLUE}╠════════════════════════════════════════╝${NC}"
  echo -e "  Host   : ${CYAN}${SUB_DOMAIN}${NC}"
  echo -e "  HostNS : ${CYAN}${NS_DOMAIN}${NC}"
  echo -e "  IP     : ${CYAN}${IP}${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
  echo
}

# ---------------------------
# ▶️ Main
# ---------------------------
main() {
  install_deps
  prepare_directories
  generate_random_subdomains
  get_public_ip
  get_cloudflare_zone_id

  # buat/update A record untuk SUB_DOMAIN -> IP publik
  update_or_create_record "A" "${SUB_DOMAIN}" "${IP}"

  # buat/update NS record untuk NS_DOMAIN -> menunjuk ke SUB_DOMAIN
  update_or_create_record "NS" "${NS_DOMAIN}" "${SUB_DOMAIN}"

  display_info
  save_configuration

  ok "Selesai: Record domain dan NS telah dibuat/diupdate."
  sleep 2
}

# ---------------------------
# Jalankan
# ---------------------------
main
