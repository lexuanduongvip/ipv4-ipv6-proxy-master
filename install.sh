#!/bin/sh
random() {
	tr </dev/urandom -dc A-Za-z0-9 | head -c5
	echo
}

array=(1 2 3 4 5 6 7 8 9 0 a b c d e f)
gen64() {
	ip64() {
		echo "${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}"
	}
	echo "$1:$(ip64):$(ip64):$(ip64):$(ip64)"
}
install_3proxy() {
    echo "installing 3proxy"
    mkdir -p /3proxy
    cd /3proxy
    URL="https://github.com/z3APA3A/3proxy/archive/0.9.3.tar.gz"
    wget -qO- $URL | bsdtar -xvf-
    cd 3proxy-0.9.3
    make -f Makefile.Linux
    mkdir -p /usr/local/etc/3proxy/{bin,logs,stat}
    mv /3proxy/3proxy-0.9.3/bin/3proxy /usr/local/etc/3proxy/bin/
    wget https://raw.githubusercontent.com/xlandgroup/ipv4-ipv6-proxy/master/scripts/3proxy.service-Centos8 --output-document=/3proxy/3proxy-0.9.3/scripts/3proxy.service2
    cp /3proxy/3proxy-0.9.3/scripts/3proxy.service2 /usr/lib/systemd/system/3proxy.service
    systemctl link /usr/lib/systemd/system/3proxy.service
    systemctl daemon-reload
#    systemctl enable 3proxy
    echo "* hard nofile 999999" >>  /etc/security/limits.conf
    echo "* soft nofile 999999" >>  /etc/security/limits.conf
    echo "net.ipv6.conf.ens3.proxy_ndp=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.proxy_ndp=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.forwarding=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
    echo "net.ipv6.ip_nonlocal_bind = 1" >> /etc/sysctl.conf
    echo "net.core.somaxconn = 50000" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_max_syn_backlog = 30000" >> /etc/sysctl.conf
    echo "net.core.netdev_max_backlog = 5000" >> /etc/sysctl.conf
    echo "net.ipv4.ip_local_port_range = 13000 65535" >> /etc/sysctl.conf 
    echo "net.ipv4.udp_rmem_min = 8192" >> /etc/sysctl.conf 
    echo "net.ipv4.udp_wmem_min = 8192" >> /etc/sysctl.conf 
    echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf 
    echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf 
    echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf 
    echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf 
    echo "net.ipv6.conf.all.forwarding = 0" >> /etc/sysctl.conf 
    echo "net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.conf 
    echo "net.core.rmem_max = 16777216" >> /etc/sysctl.conf 
    echo "net.core.wmem_max = 16777216" >> /etc/sysctl.conf 
    echo "net.core.rmem_default = 16777216" >> /etc/sysctl.conf 
    echo "net.core.wmem_default = 16777216" >> /etc/sysctl.conf 
    echo "net.core.optmem_max = 40960" >> /etc/sysctl.conf 
    echo "net.ipv4.tcp_rmem = 4096 87380 16777216" >> /etc/sysctl.conf 
    echo "net.ipv4.tcp_wmem = 4096 65536 16777216" >> /etc/sysctl.conf 
    echo "net.ipv4.tcp_keepalive_time = 60" >> /etc/sysctl.conf 
    echo "net.ipv4.tcp_max_tw_buckets = 2000000" >> /etc/sysctl.conf 
    echo "net.ipv4.tcp_fin_timeout = 10" >> /etc/sysctl.conf 
    echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf 
    echo "net.ipv4.tcp_tw_recycle = 0" >> /etc/sysctl.conf 
    echo "net.ipv4.tcp_keepalive_intvl = 15" >> /etc/sysctl.conf 
    echo "net.ipv4.tcp_keepalive_probes = 5" >> /etc/sysctl.conf 
    echo "net.ipv4.netfilter.ip_conntrack_max = 655360" >> /etc/sysctl.conf 
    echo " net.netfilter.nf_conntrack_max = 655360" >> /etc/sysctl.conf 
    echo "net.ipv4.netfilter.ip_conntrack_buckets = 327680" >> /etc/sysctl.conf 
    echo "net.netfilter.nf_conntrack_buckets = 327680" >> /etc/sysctl.conf 
    echo "net.ipv4.netfilter.ip_conntrack_tcp_timeout_established = 600" >> /etc/sysctl.conf 
    echo "net.netfilter.nf_conntrack_tcp_timeout_established = 600" >> /etc/sysctl.conf 
    echo "net.ipv6.conf.all.enable_ipv6 = 1" >> /etc/sysctl.conf 
    echo "net.ipv6.conf.default.enable_ipv6 = 1" >> /etc/sysctl.conf 
    echo "net.ipv6.conf.lo.enable_ipv6 = 1" >> /etc/sysctl.conf 
    echo "net.ipv4.tcp_synack_retries = 3" >> /etc/sysctl.conf 
    echo "net.ipv4.tcp_syn_retries = 3" >> /etc/sysctl.conf 
    echo 327680 > /sys/module/nf_conntrack/parameters/hashsize
    sysctl -p
    sysctl -p /etc/sysctl.d/99-network-tuning.conf
    systemctl stop firewalld
    systemctl disable firewalld
    systemctl enable firewalld
    systemctl restart firewalld

    cd $WORKDIR
}

gen_3proxy() {
    cat <<EOF
daemon
maxconn 2000
nserver 208.67.222.222
nserver 208.67.220.220
nserver 2001:4860:4860::8888
nserver 2001:4860:4860::8844
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
setgid 65535
setuid 65535
stacksize 6291456
parent 1000 http ipv6 85
proxy -p81 -a -6 -iipv4 -eipv6
auth iponly
flush
auth strong

users $(awk -F "/" 'BEGIN{ORS="";} {print $1 ":CL:" $2 " "}' ${WORKDATA})

$(awk -F "/" '{print "auth strong\n" \
"allow " $1 "\n" \
"proxy -6 -n -a -p" $4 " -i" $3 " -e"$5"\n" \
"flush\n"}' ${WORKDATA})
EOF
}

gen_proxy_file_for_user() {
    cat >proxy.txt <<EOF
$(awk -F "/" '{print $3 ":" $4 ":" $1 ":" $2 }' ${WORKDATA})
EOF
}

upload_proxy() {
    cd $WORKDIR
    local PASS=$(random)
    zip --password $PASS proxy.zip proxy.txt
    URL=$(curl -F "file=@proxy.zip" https://file.io)

    echo "Proxy is ready! Format IP:PORT:LOGIN:PASS"
    echo "Download zip archive from: ${URL}"
    echo "Password: ${PASS}"

}
gen_data() {
    seq $FIRST_PORT $LAST_PORT | while read port; do
        echo "$(random)/$(random)/$IP4/$port/$(gen64 $IP6)"
    done
}

gen_iptables() {
    cat <<EOF
    $(awk -F "/" '{print "iptables -I INPUT -p tcp --dport " $4 "  -m state --state NEW -j ACCEPT"}' ${WORKDATA}) 
EOF
}

gen_ifconfig() {
    cat <<EOF
$(awk -F "/" '{print "ifconfig ens3 inet6 add " $5 "/64"}' ${WORKDATA})
EOF
}
echo "installing apps"
yum -y install gcc net-tools bsdtar zip make >/dev/null

install_3proxy

echo "working folder = /home/proxy-installer"
WORKDIR="/home/proxy-installer"
WORKDATA="${WORKDIR}/data.txt"
mkdir $WORKDIR && cd $_

IP4=$(curl -4 -s icanhazip.com)
IP6=$(curl -6 -s icanhazip.com | cut -f1-4 -d':')

echo "Internal ip = ${IP4}. Exteranl sub for ip6 = ${IP6}"

FIRST_PORT=10000
LAST_PORT=11000
gen_data >$WORKDIR/data.txt
gen_iptables >$WORKDIR/boot_iptables.sh
gen_ifconfig >$WORKDIR/boot_ifconfig.sh
chmod +x $WORKDIR/boot_*.sh /etc/rc.local

gen_3proxy >/usr/local/etc/3proxy/3proxy.cfg

cat >>/etc/rc.local <<EOF
systemctl start NetworkManager.service
ifup ens3
bash ${WORKDIR}/boot_iptables.sh
bash ${WORKDIR}/boot_ifconfig.sh
ulimit -n 65535
/usr/local/etc/3proxy/bin/3proxy /usr/local/etc/3proxy/3proxy.cfg &
EOF

bash /etc/rc.local

gen_proxy_file_for_user

upload_proxy
