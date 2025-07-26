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

# Dapatkan daftar akun dari file konfigurasi
data=($(grep -E "^#!" "/etc/xray/config.json" | cut -d ' ' -f 2 | sort -u))

# Proses setiap akun
for user in "${data[@]}"; do
    [[ -z "$user" ]] && continue  # Lewatkan jika tidak ada akun

    # Bersihkan file sementara untuk IP
    > /tmp/iptrojan.txt

    # Ambil alamat IP dari log akses
    data2=($(grep -w "$user" /var/log/xray/access.log | tail -n 500 | awk '{print $3}' | sed 's/tcp://g' | cut -d ":" -f 1 | sort -u))

    # Proses setiap IP dan simpan ke file sementara
    for ip in "${data2[@]}"; do
        grep -qw "$ip" /var/log/xray/access.log && echo "$ip" >> /tmp/iptrojan.txt || echo "$ip" >> /tmp/other.txt
    done

    # Tampilkan informasi jika ada IP yang terkait dengan pengguna
    if [[ -s /tmp/iptrojan.txt ]]; then
        # Ambil waktu login terakhir
        lastlogin=$(journalctl -u xray --no-pager | grep -w "$user" | tail -n 1 | awk '{print $1, $2}')
        [[ -z "$lastlogin" ]] && lastlogin=$(grep -w "$user" /var/log/xray/access.log | tail -n 1 | awk '{print $2}')

        # Ambil batas IP, fallback jika file tidak ada atau kosong
        iplimit=$(<"/etc/kyt/limit/trojan/ip/${user}" 2>/dev/null || echo "No limit")

        # Hitung jumlah IP login
        jum2=$(wc -l < /tmp/iptrojan.txt)

        # Baca penggunaan byte atau tetapkan 0 jika file tidak ada
        byte=$(<"/etc/trojan/${user}" 2>/dev/null || echo 0)
        lim=$(con "$byte")

        # Baca kuota pengguna atau tetapkan 0 jika file tidak ada
        wey=$(<"/etc/limit/trojan/${user}" 2>/dev/null || echo 0)
        gb=$(con "$wey")

        # Tampilkan informasi akun
        echo "User: ${user}"
        echo "Online Time: ${lastlogin}"
        echo "Limit Quota: ${lim}"
        echo "Usage Quota: ${gb}"
        echo "Limit IP: $iplimit"
        echo "Login IP Count: $jum2"
      
        nl /tmp/iptrojan.txt  # Tampilkan daftar IP dengan nomor baris
        echo ""
    fi
done

# Hapus file sementara
rm -f /tmp/other.txt /tmp/iptrojan.txt
