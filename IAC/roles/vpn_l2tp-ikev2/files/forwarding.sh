#!/bin/bash

. /tmp/vpn_sh/vars

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

conf_bk() { /bin/cp -f "$1" "$1.old-$SYS_DT" 2>/dev/null; }

update_sysctl() {
conf_bk "/etc/sysctl.conf"
conf_bk "/proc/sys/net/ipv4/ip_forward"

  if ! grep -qs "fisher VPN script" /etc/rc.local; then
    cat >> /etc/sysctl.conf <<EOF

# Added by fisher VPN script

kernel.msgmnb = 65536
kernel.msgmax = 65536

net.ipv4.ip_forward = 1
net.ipv4.ip_no_pmtu_disc = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.eth0.send_redirects = 0
net.ipv4.conf.eth0.rp_filter = 0

net.core.wmem_max = 16777216
net.core.rmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 87380 16777216
EOF
  fi
}

setup() {
  update_sysctl
}

setup "$@"

exit 0
