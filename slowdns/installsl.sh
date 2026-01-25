#!/bin/sh
REPOS="raw.githubusercontent.com/Pemulaajiw/script/main"
ns_domain_cloudflare() {
	DOMAIN=$(cat /etc/xray/domain | cut -d "." -f2-4)
	DOMAIN_PATH=$(cat /etc/xray/domain)
	SUB=$(cat /etc/xray/domain | cut -d "." -f1)
	SUB_DOMAIN=${SUB}."${DOMAIN}"
	NS_DOMAIN=ns-${SUB_DOMAIN}
	CF_ID= mbahkoid13@gmail.com
        CF_KEY=a527f7da45eba65e5ce033619e5debe2a42e9
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
	echo $NS_DOMAIN >/etc/xray/dns
}

setup_dnstt() {
	cd
	mkdir -p /etc/slowdns
	cd /etc/slowdns
	wget -O dnstt-server "${REPOS}slowdns/dnstt-server" >/dev/null 2>&1
	chmod +x dnstt-server >/dev/null 2>&1
	wget -O dnstt-client "${REPOS}slowdns/dnstt-client" >/dev/null 2>&1
	chmod +x dnstt-client >/dev/null 2>&1
	./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
	chmod +x *
	wget -O /etc/systemd/system/client.service "${REPOS}slowdns/client" >/dev/null 2>&1
	wget -O /etc/systemd/system/server.service "${REPOS}slowdns/server" >/dev/null 2>&1
	sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/client.service 
	sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/server.service 
}
ns_domain_cloudflare
setup_dnstt

