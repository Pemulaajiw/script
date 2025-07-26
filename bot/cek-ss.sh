#!/bin/bash

# Fungsi untuk mengonversi byte menjadi format yang lebih mudah dibaca
function con() {
    local -i bytes=$1
    if (( bytes < 1024 )); then
        echo "${bytes}B"
    elif (( bytes < 1048576 )); then
        echo "$(( (bytes + 1023) / 1024 ))KB"
    elif (( bytes < 1073741824 )); then
        echo "$(( (bytes + 1048575) / 1048576 ))MB"
    else
        echo "$(( (bytes + 1073741823) / 1073741824 ))GB"
    fi
}

# Bersihkan layar dan file sementara
clear
> /tmp/other.txt

# Dapatkan akun pengguna dari file konfigurasi
data=($(grep -E "^#!#" "/etc/xray/config.json" | cut -d ' ' -f 2 | sort -u))

# Proses setiap akun
for user in "${data[@]}"; do
    [[ -z "$user" ]] && continue  # Lewatkan jika akun tidak ditemukan

    > /tmp/ipshadowsocks.txt  # Bersihkan file sementara untuk IP

    # Ambil alamat IP dari log akses
    data2=($(grep -w "$user" /var/log/xray/access.log | tail -n 500 | awk '{print $3}' | sed 's/tcp://g' | cut -d ":" -f 1 | sort -u))

    # Proses setiap IP
    for ip in "${data2[@]}"; do
        grep -qw "$ip" /var/log/xray/access.log && echo "$ip" >> /tmp/ipshadowsocks.txt || echo "$ip" >> /tmp/other.txt
    done

    # Cek apakah ada IP yang terkait dengan pengguna
    if [[ -s /tmp/ipshadowsocks.txt ]]; then
        # Ambil waktu login terakhir dari journalctl atau log akses
        lastlogin=$(journalctl -u xray --no-pager | grep -w "$user" | tail -n 1 | awk '{print $1, $2}')
        [[ -z "$lastlogin" ]] && lastlogin=$(grep -w "$user" /var/log/xray/access.log | tail -n 1 | awk '{print $2}')

        # Baca batas IP pengguna, fallback jika file tidak ada atau kosong
        iplimit=$(<"/etc/kyt/limit/shadowsocks/ip/${user}" 2>/dev/null || echo "No limit")

        # Hitung jumlah IP login
        jum2=$(wc -l < /tmp/ipshadowsocks.txt)

        # Baca penggunaan byte dan batas kuota pengguna
        byte=$(<"/etc/shadowsocks/${user}" 2>/dev/null || echo 0)
        lim=$(con $byte)

        wey=$(<"/etc/limit/shadowsocks/${user}" 2>/dev/null || echo 0)
        gb=$(con $wey)

        # Tampilkan informasi pengguna
        echo "User: ${user}"
        echo "Online Time: ${lastlogin}"
        echo "Limit Quota: ${lim}"
        echo "Usage Quota: ${gb}"
        echo "Limit IP: $iplimit"
        echo "Login IP Count: $jum2"

        nl /tmp/ipshadowsocks.txt  # Tampilkan daftar IP
        echo ""
    fi
done

# Hapus file sementara
rm -f /tmp/other.txt /tmp/ipshadowsocks.txt
