#!/bin/bash
Green="\e[92;1m"
RED="\033[1;31m"
YELLOW="\033[33m"
BLUE="\033[36m"
FONT="\033[0m"
GREENBG="\033[42;37m"
REDBG="\033[41;37m"
NC='\e[0m'
REPOS="https://raw.githubusercontent.com/Pemulaajiw/script/main/"
ns_domain_cloudflare() {
	DOMAIN="h3nstore.my.id"
	DOMAIN_PATH=$(cat /etc/xray/domain)
	echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
	echo -e "           Masukan Subdomain              "
	echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" 
	echo "" 
	read -p " Subdomain : " SUB
	if [ -z $SUB ]; then
    exit
    else
	SUB_DOMAIN=${SUB}."h3nstore.my.id"
	NS_DOMAIN=ns.${SUB_DOMAIN}
	CF_ID=hurufkapital58@gmail.com
        CF_KEY=9d68eb52b48974c82c91ac2aee1a5b7ecf663
	set -euo pipefail
	IP=$(wget -qO- ipinfo.io/ip)
	echo "Updating DNS NS for ${NS_DOMAIN}..."
	ZONE=$(
		curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
		-H "X-Auth-Email: ${CF_ID}" \
		-H "X-Auth-Key: ${CF_KEY}" \
		-H "Content-Type: application/json" | jq -r .result[0].id
	)

	RECORD=$(
		curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${NS_DOMAIN}" \
		-H "X-Auth-Email: ${CF_ID}" \
		-H "X-Auth-Key: ${CF_KEY}" \
		-H "Content-Type: application/json" | jq -r .result[0].id
	)

	if [[ "${#RECORD}" -le 10 ]]; then
		RECORD=$(
			curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
			-H "X-Auth-Email: ${CF_ID}" \
			-H "X-Auth-Key: ${CF_KEY}" \
			-H "Content-Type: application/json" \
			--data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${DOMAIN_PATH}'","proxied":false}' | jq -r .result.id
		)
	fi

	RESULT=$(
		curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
		-H "X-Auth-Email: ${CF_ID}" \
		-H "X-Auth-Key: ${CF_KEY}" \
		-H "Content-Type: application/json" \
		--data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${DOMAIN_PATH}'","proxied":false}'
	)
	fi
}
setup_dnstt() {
	cd
	mkdir -p /etc/slowdns
	cd /etc/slowdns
	wget -O dnstt-server "${REPOS}slowdns/dnstt-server" >/dev/null 2>&1 #arahkan ke file di gh Wajib!!
	chmod +x dnstt-server >/dev/null 2>&1
	wget -O dnstt-client "${REPOS}slowdns/dnstt-client" >/dev/null 2>&1 #arahkan ke file di gh Wajib!!
	chmod +x dnstt-client >/dev/null 2>&1
	./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
	chmod +x *
	cd
	wget -O /etc/systemd/system/client.service "${REPOS}slowdns/client" >/dev/null 2>&1 #arahkan ke file di gh Wajib!!
	wget -O /etc/systemd/system/server.service "${REPOS}slowdns/server" >/dev/null 2>&1 #arahkan ke file di gh Wajib!!
	sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/client.service 
	sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/server.service 
	systemctl daemon-reload
	systemctl restart server
	systemctl restart client
	systemctl enable server
	systemctl enable client
}
print_install() {
echo -e "${BLUE} =============================== ${FONT}"
echo -e "${YELLOW} # $1 ${FONT}"
echo -e "${BLUE} =============================== ${FONT}"
sleep 1
}
print_success() {
if [[ 0 -eq $? ]]; then
echo -e "${BLUE} =============================== ${FONT}"
echo -e "${Green} # $1 berhasil dipasang"
echo -e "${BLUE} =============================== ${FONT}"
sleep 2
fi
}
setup(){
echo ""
echo ""
echo -e "   ${BLUE}_______________________________$NC"
echo -e "   \e[1;32m    WELCOME TO SLOWDNS SETUP $NC"
echo -e "   ${BLUE}_______________________________$NC"
echo ""
echo "    Menyiapan Pemasangan Slowdns dalam 2 detik !"
sleep 2
clear
ns_domain_cloudflare
setup_dnstt
echo ""
rm -rf slowdns.sh
clear
print_success "SETUP SLOWDNS YOUR SERVER"
sleep 2
menu
}
setup