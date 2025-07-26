#!/bin/bash


clear
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
red() { echo -e "\\033[32;1m${*}\\033[0m"; }
echo -e "\033[96m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " \e[1;97m                       MEMBER                  \e[0m"
echo -e "\033[96m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\033[1;36m  USERNAME          EXP DATE          \033[0m "
echo -e ""
while read expired
do
AKUN="$(echo $expired | cut -d: -f1)"
ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
status="$(passwd -S $AKUN | awk '{print $2}' )"
if [[ $ID -ge 1000 ]]; then
if [[ "$status" = "L" ]]; then
printf "%-17s %2s %-17s %2s \n" "  $AKUN" "  $exp     "
else
fi
done < /etc/passwd
echo -e "\033[96m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " \e[1;97m                     RENEW  USER               \e[0m"
echo -e "\033[96m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -p "  Username : " Pengguna

if getent passwd $Pengguna >/dev/null 2>&1; then
    ok="ok"
else
    echo -e "Failure: User $Pengguna Not Exist."
    echo ""
    read -n 1 -s -r -p "Press [ Enter ] to back menu ssh"
    ssh
fi

if [ -z $Pengguna ]; then
    echo -e "Username cannot be empty "
    echo ""
    read -n 1 -s -r -p "Press [ Enter ] to back menu ssh"
    ssh
fi

egrep "^$Pengguna" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
    read -p "Day Extend : " Days
    if [ -z $Days ]; then
        Days="1"
    fi
    Today=$(date +%s)
    Days_Detailed=$(($Days * 86400))
    Expire_On=$(($Today + $Days_Detailed))
    Expiration=$(date -u --date="1970-01-01 $Expire_On sec GMT" +%Y/%m/%d)
    Expiration_Display=$(date -u --date="1970-01-01 $Expire_On sec GMT" '+%d %b %Y')
    passwd -u $Pengguna
    usermod -e $Expiration $Pengguna
    egrep "^$Pengguna" /etc/passwd >/dev/null
    echo -e "$Pass\n$Pass\n" | passwd $Pengguna &>/dev/null
    clear
echo -e "\033[96m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " \e[1;97m              RENEW  USER               \e[0m"
echo -e "\033[96m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   Username   : $Pengguna"
    echo -e "   Days Added : $Days Days"
    echo -e "   Expires on : $Expiration_Display"
else
    clear
echo -e "\033[96m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " \e[1;97m              RENEW  USER               \e[0m"
echo -e "\033[96m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Username Doesnt Exist      "
fi
echo ""
read -n 1 -s -r -p "Press [ Enter ] to back menu ssh"
ssh
