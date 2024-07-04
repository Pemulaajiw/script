#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# System Request : Debian 9+/Ubuntu 18.04+/20+
# Develovers » FanVPN-Store
# Email      » HurufKapital58@gmail.com
# telegram   » https://t.me/AJW29
# whatsapp   » wa.me/+6287812264674
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FanVPN-Store

function addtema() {
if [ -f "/etc/fansnetwork/theme/blue" ]; then
#echo "sudah ada tema, mulai proses over write"
rm -rf /etc/fansnetwork/theme
mkdir -p /etc/fansnetwork
mkdir -p /etc/fansnetwork/theme
else
#echo "belum ada tema njuk create folder tema"
mkdir -p /etc/fansnetwork
mkdir -p /etc/fansnetwork/theme
fi
#THEME RED
cat <<EOF>> /etc/fansnetwork/theme/red
BG : \E[40;1;41m
TEXT : \033[0;31m
EOF
#THEME BLUE
cat <<EOF>> /etc/fansnetwork/theme/blue
BG : \E[40;1;44m
TEXT : \033[0;34m
EOF
#THEME GREEN
cat <<EOF>> /etc/fansnetwork/theme/green
BG : \E[40;1;42m
TEXT : \033[0;32m
EOF
#THEME YELLOW
cat <<EOF>> /etc/fansnetwork/theme/yellow
BG : \E[40;1;43m
TEXT : \033[0;33m
EOF
#THEME MAGENTA
cat <<EOF>> /etc/fansnetwork/theme/magenta
BG : \E[40;1;43m
TEXT : \033[0;33m
EOF
#THEME CYAN
cat <<EOF>> /etc/fansnetwork/theme/cyan
BG : \E[40;1;46m
TEXT : \033[0;36m
EOF
#THEME CONFIG
cat <<EOF>> /etc/fansnetwork/theme/color.conf
blue
EOF
}
function fixtema(){
    addtema
    if [ -f "/etc/fansnetwork/theme/blue" ]; then
        #echo ada tema fauzixaji default
        rm -rf /etc/fanstore

        if [ -f "/etc/fanstore/tema/blue" ]; then
            clear
            #echo ada tema fan.....
        else
            #echo ga ada tema fan...
            mkdir -p /etc/ssnvpn

            mkdir -p /etc/fanstore
            mkdir -p /etc/fanstore/theme
            mkdir -p /etc/fanstore/tema
            cp -fr /etc/fansnetwork/theme/* /etc/fanstore/theme
        fi
    else
        #echo ga ada tema fauzixaji default....
        clear
    fi
}
#hapus pagar bila tema error
fixtema
