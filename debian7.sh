#!/bin/bash
#
# Script Copyright www.fawzya.net
# ==========================
# 

if [[ $USER != 'root' ]]; then
	echo "Maaf, Anda harus menjalankan ini sebagai root"
	exit
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
ether=`ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:`
if [[ $ether = "" ]]; then
        ether=eth0
fi

vps="FNS";

if [[ $vps = "FNS" ]]; then
	source="http://script.fawzya.net/debian"
else
	source="http://script.fawzya.net/debian"
fi

# go to root
cd

    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
	LGREEN=`echo "\033[0m\033[1;32m"`
    ENTER_LINE=`echo "\033[33m"`
	LRED=`echo "\033[0m\033[1;31m"`
	BLUE=`echo "\033[0m\033[1;36m"`

# detail
country=MY
state=Terengganu
locality=-
organization=Interpass
organizationalunit=InterpassGroup
commonname=Hake
email=-

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;
sudo apt-get install ca-certificates

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -q -O /etc/apt/sources.list $source/null/sources.list.debian7
wget "http://www.dotdeb.org/dotdeb.gpg"
wget "http://www.webmin.com/jcameron-key.asc"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# update
apt-get update; apt-get -y upgrade;

# install webserver
apt-get -y install nginx php5-fpm php5-cli

# install essential package
echo "mrtg mrtg/conf_mods boolean true" | debconf-set-selections
#apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update
#apt-get install screen

# setting vnstat
vnstat -u -i venet0
service vnstat restart

# install screenfetch
cd
wget -q $source/null/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch-dev
chmod +x /usr/bin/screenfetch-dev
echo "clear" >> .profile
echo "screenfetch-dev" >> .profile


# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -q -O /etc/nginx/nginx.conf $source/null/nginx.conf
mkdir -p /home/fns/public_html
echo "<pre>Default Webpage</pre><br/><pre>Auto Installer Script Premium - ForNesia Community</pre>" > /home/fns/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/fns/public_html/info.php
wget -q -O /etc/nginx/conf.d/vps.conf $source/null/vps.conf
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

# install openvpn
cd
apt-get -y install openvpn
wget -q -O /etc/openvpn/openvpn.tar "https://github.com/ForNesiaFreak/FNS/raw/master/sett/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -q -O /etc/openvpn/1194.conf $source/null/1194.conf
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
wget -q -O /etc/iptables.up.rules $source/null/iptables.up.rules
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules
service openvpn restart

# configure openvpn client config
cd /etc/openvpn/
wget -q -O /etc/openvpn/1194-client.ovpn $source/null/1194-client.conf
sed -i $MYIP2 /etc/openvpn/1194-client.ovpn;
PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
useradd -M -s /bin/false PremiumVPS
echo "PremiumVPS:$PASS" | chpasswd
cd

# install badvpn
wget -O /usr/bin/badvpn-udpgw "https://github.com/ForNesiaFreak/FNS/raw/master/sett/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "https://github.com/ForNesiaFreak/FNS/raw/master/sett/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300


# install mrtg
wget -q -O /etc/snmp/snmpd.conf $source/null/snmpd.conf
wget -q -O /root/mrtg-mem.sh $source/null/mrtg-mem.sh
chmod +x /root/mrtg-mem.sh
cd /etc/snmp/
sed -i 's/TRAPDRUN=no/TRAPDRUN=yes/g' /etc/default/snmpd
service snmpd restart
snmpwalk -v 1 -c public localhost 1.3.6.1.4.1.2021.10.1.3.1
mkdir -p /home/fns/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/fns/public_html/mrtg' --output /etc/mrtg.cfg public@localhost
curl $source/null/mrtg.conf >> /etc/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg.cfg
indexmaker --output=/home/fns/public_html/mrtg/index.html /etc/mrtg.cfg
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
cd

# setting port ssh
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
#sed -i '/Port 22/a Port 80' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/#Banner/Banner/g' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=442/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 442 -p 110 -p 109"/g' /etc/default/dropbear
sed -i 's/DROPBEAR_BANNER=""/DROPBEAR_BANNER="\/etc\/issue.net"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart
cd


# upgrade dropbear 2014
apt-get install zlib1g-dev
wget -q https://matt.ucc.asn.au/dropbear/releases/dropbear-2012.55.tar.bz2
bzip2 -cd dropbear-2012.55.tar.bz2 | tar xvf -
cd dropbear-2012.55
./configure
make && make install
mv /usr/sbin/dropbear /usr/sbin/dropbear1
ln /usr/local/sbin/dropbear /usr/sbin/dropbear
service dropbear restart


# install vnstat gui
cd /home/fns/public_html/
wget https://github.com/ForNesiaFreak/FNS/raw/master/go/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i 's/eth0/venet0/g' config.php
sed -i "s/\$iface_list = array('venet0', 'sixxs');/\$iface_list = array('venet0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# install fail2ban
apt-get -y install fail2ban;service fail2ban restart

# Instal (D)DoS Deflate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

# install stunnel
apt-get install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
pid = /stunnel.pid
client = no	
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
[dropbear]
accept = 443
connect = 127.0.0.1:442
connect = 127.0.0.1:109
connect = 127.0.0.1:110
;[squid]
;accept = 8000
;connect = 127.0.0.1:3128
;connect = 127.0.0.1:80
;connect = 127.0.0.1:8080
END

#membuat sertifikat
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

#konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart


# install squid3
wget http://www.borneobesthosting.me/Debian7/squid.sh
chmod 100 squid.sh
./squid.sh

# install webmin
cd
apt-get -y install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python
apt-get -y install apt-transport-https
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.831_all.deb
dpkg --install webmin_1.831_all.deb
service webmin restart
service vnstat restart



# install dos2unix
apt-get install dos2unix



# install New pptp vpn 
wget -q $source/null/fnspptp.sh


# text gambar
apt-get install boxes

# color text
cd
rm -rf /root/.bashrc
wget -O /root/.bashrc "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/.bashrc"

# install lolcat
sudo apt-get -y install ruby
sudo gem install lolcat

# download script
cd
wget -O /usr/bin/motd "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/motd"
wget -O /usr/bin/benchmark "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/benchmark.sh"
wget -O /usr/bin/speedtest "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/speedtest_cli.py"
wget -O /usr/bin/ps-mem "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/ps_mem.py"
wget -O /usr/bin/dropmon "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/dropmon.sh"
wget -O /usr/bin/menu "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/menu.sh"
wget -O /usr/bin/user-active-list "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/user-active-list.sh"
wget -O /usr/bin/user-add "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/user-add.sh"
wget -O /usr/bin/user-add-pptp "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/user-add-pptp.sh"
wget -O /usr/bin/user-del "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/user-del.sh"
wget -O /usr/bin/disable-user-expire "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/disable-user-expire.sh"
wget -O /usr/bin/delete-user-expire "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/delete-user-expire.sh"
wget -O /usr/bin/banned-user "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/banned-user.sh"
wget -O /usr/bin/unbanned-user "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/unbanned-user.sh"
wget -O /usr/bin/user-expire-list "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/user-expire-list.sh"
wget -O /usr/bin/user-gen "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/user-gen.sh"
wget -O /usr/bin/userlimit.sh "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/userlimit.sh"
wget -O /usr/bin/userlimitssh.sh "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/userlimitssh.sh"
wget -O /usr/bin/user-list "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/user-list.sh"
wget -O /usr/bin/user-login "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/user-login.sh"
wget -O /usr/bin/user-pass "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/user-pass.sh"
wget -O /usr/bin/user-renew "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/user-renew.sh"
wget -O /usr/bin/clearcache.sh "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/clearcache.sh"
wget -O /usr/bin/bannermenu "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/bannermenu"
cd

#rm -rf /etc/cron.weekly/
#rm -rf /etc/cron.hourly/
#rm -rf /etc/cron.monthly/
rm -rf /etc/cron.daily/
wget -O /root/passwd "https://raw.githubusercontent.com/cucuatok93/cucuatok/master/tools/passwd.sh"
chmod +x /root/passwd
echo "01 23 * * * root /root/passwd" > /etc/cron.d/passwd

echo "*/30 * * * * root service dropbear restart" > /etc/cron.d/dropbear
echo "00 23 * * * root /usr/bin/disable-user-expire" > /etc/cron.d/disable-user-expire
echo "0 */12 * * * root /sbin/reboot" > /etc/cron.d/reboot
#echo "00 01 * * * root echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a" > /etc/cron.d/clearcacheram3swap
echo "*/30 * * * * root /usr/bin/clearcache.sh" > /etc/cron.d/clearcache1

cd
chmod +x /usr/bin/motd
chmod +x /usr/bin/benchmark
chmod +x /usr/bin/speedtest
chmod +x /usr/bin/ps-mem
#chmod +x /usr/bin/autokill
chmod +x /usr/bin/dropmon
chmod +x /usr/bin/menu
chmod +x /usr/bin/user-active-list
chmod +x /usr/bin/user-add
chmod +x /usr/bin/user-add-pptp
chmod +x /usr/bin/user-del
chmod +x /usr/bin/disable-user-expire
chmod +x /usr/bin/delete-user-expire
chmod +x /usr/bin/banned-user
chmod +x /usr/bin/unbanned-user
chmod +x /usr/bin/user-expire-list
chmod +x /usr/bin/user-gen
chmod +x /usr/bin/userlimit.sh
chmod +x /usr/bin/userlimitssh.sh
chmod +x /usr/bin/user-list
chmod +x /usr/bin/user-login
chmod +x /usr/bin/user-pass
chmod +x /usr/bin/user-renew
chmod +x /usr/bin/clearcache.sh
chmod +x /usr/bin/bannermenu
cd

# finishing
chown -R www-data:www-data /home/fns/public_html
service cron restart
service nginx start
service php-fpm start
service vnstat restart
#service openvpn restart
service snmpd restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile
userexpiredfns

# info
clear
echo -e "${LRED}Autoscript Includes:${NORMAL}" | tee log-install.txt
echo "===========================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "${LRED}Service${NORMAL}"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo -e "${LGREEN}OpenSSH  : ${NORMAL}22, 143"  | tee -a log-install.txt
echo -e "${LGREEN}Dropbear : ${NORMAL}443, 110, 109, 80"  | tee -a log-install.txt
echo -e "${LGREEN}Squid3    : ${NORMAL}8080, 3128 (limit to IP SSH)"  | tee -a log-install.txt
echo -e "${LGREEN}badvpn   : ${NORMAL}badvpn-udpgw port 7300"  | tee -a log-install.txt
echo -e "${LGREEN}PPTP VPN  : ${NORMAL}Create User via Panel Menu"  | tee -a log-install.txt
echo -e "${LGREEN}nginx    : ${NORMAL}81"  | tee -a log-install.txt
echo "===========================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "${LRED}Tools${NORMAL}"  | tee -a log-install.txt
echo "-----"  | tee -a log-install.txt
echo "axel, bmon, htop, iftop, mtr, rkhunter, nethogs: nethogs venet0"  | tee -a log-install.txt
echo "-----"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "${LRED}PANEL MENU${NORMAL}"  | tee -a log-install.txt
echo "------"  | tee -a log-install.txt
echo -e "Silahkan Ketik ${LRED}panel ${NORMAL}Untuk Akses Fitur"  | tee -a log-install.txt
echo -e "Silahkan Ketik ${LRED}insttallvpn ${NORMAL}Untuk Install/Remove VPN Manual"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "${LRED}Fitur lain${NORMAL}"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo -e "${LGREEN}Webmin   : ${NORMAL}http://$MYIP:10000/"  | tee -a log-install.txt
echo -e "${LGREEN}Timezone : ${NORMAL}Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo -e "${LGREEN}Fail2Ban : ${NORMAL}[on]"  | tee -a log-install.txt
echo -e "${LGREEN}(D)DoS Deflate : ${NORMAL}[on]" | tee -a log-install.txt
echo -e "${LGREEN}IPv6     : ${NORMAL}[off]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Auto Lock User Expire tiap jam 00:00" | tee -a log-install.txt
echo "Auto Reboot tiap jam 00:00 dan jam 12:00" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "${LRED}Deafult Akun SSH/OpenVPN${NORMAL}"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo -e "${LGREEN}Username   : ${NORMAL}PremiumVPS"  | tee -a log-install.txt
echo -e "${LGREEN}Password : ${NORMAL}$PASS"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==========================================="  | tee -a log-install.txt
echo "Auto Script Installer Vps By suryadewa bangsat"  | tee -a log-install.txt
echo "suryadewa bangsat (http://www.imadenews.com/contact/ - 08563776008)"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt

echo "-------------------------------------------"  | tee -a log-install.txt
echo "Log Instalasi --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "-------------------------------------------"  | tee -a log-install.txt
echo -e "${LRED}SILAHKAN REBOOT VPS ANDA !${NORMAL}"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==========================================="  | tee -a log-install.txt
cd
rm -f /root/debian7.sh
rm -f /root/fnspptp.sh
rm -f /root/menu.sh
rm -r /root/fornesia87
rm -f /root/fornesia87.tgz
rm -f /root/speedtest_cli.py
rm -f /root/ps_mem.py
rm -f /root/xfg.sh
rm -f /root/daftarip
rm -f /root/dropbear-2012.55.tar.bz2
rm -f /root/webmin_1.831_all.deb
