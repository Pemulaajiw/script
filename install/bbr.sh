#!/bin/bash
# ╔════════════════════════════════════════════════════════════╗
# ║ 🚀 XWAN VPN :: SPEED OPTIMIZER v1.0                        ║
# ║ ⚙️  Developer: XWAN STORE | Optimasi TCP & System Kernel   ║
# ╚════════════════════════════════════════════════════════════╝

# 🎨 WARNA
NC="\e[0m"
RED="\e[31m"
GRN="\e[32m"
YLW="\e[33m"
BLU="\e[34m"
CYN="\e[36m"
WHT="\e[37m"

clear
echo -e "${CYN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYN}║   ⚙️  XrAN VPN — Speed Optimization Tool     ║${NC}"
echo -e "${CYN}╚══════════════════════════════════════════════╝${NC}"
sleep 1

# ==========================================================
# 🔧 FUNCTION: Add_To_New_Line
# → Menambahkan teks ke baris baru di file target
# ==========================================================
Add_To_New_Line() {
	if [ "$(tail -n1 "$1" | wc -l)" == "0" ]; then
		echo "" >> "$1"
	fi
	echo "$2" >> "$1"
}

# ==========================================================
# 🔍 FUNCTION: Check_And_Add_Line
# → Mengecek apakah baris sudah ada, jika belum tambahkan
# ==========================================================
Check_And_Add_Line() {
	if [ -z "$(grep "$2" "$1")" ]; then
		Add_To_New_Line "$1" "$2"
	fi
}

# ==========================================================
# ⚙️ FUNCTION: Install_BBR
# → Mengaktifkan TCP_BBR untuk optimasi koneksi
# ==========================================================
Install_BBR() {
	echo -e "${BLU}╔══════════════════════════════════════════════╗${NC}"
	echo -e "${BLU}║ 🚀 Install TCP_BBR BY XWAN STORE             ║${NC}"
	echo -e "${BLU}╚══════════════════════════════════════════════╝${NC}"

	if lsmod | grep -q bbr; then
		echo -e "${GRN}✔ TCP_BBR sudah terpasang.${NC}"
		echo ""
		return 1
	fi

	echo -e "${YLW}⏳ Memulai instalasi TCP_BBR...${NC}"
	modprobe tcp_bbr

	Add_To_New_Line "/etc/modules-load.d/modules.conf" "tcp_bbr"
	Add_To_New_Line "/etc/sysctl.conf" "net.core.default_qdisc = fq"
	Add_To_New_Line "/etc/sysctl.conf" "net.ipv4.tcp_congestion_control = bbr"
	sysctl -p &> /dev/null

	if sysctl net.ipv4.tcp_available_congestion_control | grep -q bbr && \
	   sysctl net.ipv4.tcp_congestion_control | grep -q bbr && \
	   lsmod | grep -q "tcp_bbr"; then
		echo -e "${GRN}✔ TCP_BBR berhasil diaktifkan.${NC}"
	else
		echo -e "${RED}✖ Gagal mengaktifkan TCP_BBR.${NC}"
	fi

	echo ""
	sleep 1
}

# ==========================================================
# ⚙️ FUNCTION: Optimize_Parameters
# → Meningkatkan performa jaringan & sistem file
# ==========================================================
Optimize_Parameters() {
	echo -e "${CYN}╔══════════════════════════════════════════════╗${NC}"
	echo -e "${CYN}║ 🔧 Optimasi Parameter Sistem                 ║${NC}"
	echo -e "${CYN}╚══════════════════════════════════════════════╝${NC}"

	# 🔹 Limit File Descriptor
	Check_And_Add_Line "/etc/security/limits.conf" "* soft nofile 51200"
	Check_And_Add_Line "/etc/security/limits.conf" "* hard nofile 51200"
	Check_And_Add_Line "/etc/security/limits.conf" "root soft nofile 51200"
	Check_And_Add_Line "/etc/security/limits.conf" "root hard nofile 51200"

	# 🔹 Kernel Performance Tweaks
	Check_And_Add_Line "/etc/sysctl.conf" "fs.file-max = 51200"
	Check_And_Add_Line "/etc/sysctl.conf" "net.core.rmem_max = 67108864"
	Check_And_Add_Line "/etc/sysctl.conf" "net.core.wmem_max = 67108864"
	Check_And_Add_Line "/etc/sysctl.conf" "net.core.netdev_max_backlog = 250000"
	Check_And_Add_Line "/etc/sysctl.conf" "net.core.somaxconn = 4096"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_syncookies = 1"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_tw_reuse = 1"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_fin_timeout = 30"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_keepalive_time = 1200"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.ip_local_port_range = 10000 65000"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_max_syn_backlog = 8192"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_max_tw_buckets = 5000"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_fastopen = 3"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_mem = 25600 51200 102400"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_rmem = 4096 87380 67108864"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_wmem = 4096 65536 67108864"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_mtu_probing = 1"

	sysctl -p &> /dev/null
	echo -e "${GRN}✔ Optimasi parameter sistem selesai.${NC}"
	echo ""
	sleep 1
}

# ==========================================================
# 🚀 EKSEKUSI UTAMA
# ==========================================================
Install_BBR
Optimize_Parameters

# ==========================================================
# 🧹 BERSIHKAN
# ==========================================================
rm -f /root/bbr.sh

# ==========================================================
# ✅ SELESAI
# ==========================================================
echo -e "${BLU}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLU}║ ✅ Optimasi selesai! Reboot disarankan.      ║${NC}"
echo -e "${BLU}╚══════════════════════════════════════════════╝${NC}"
