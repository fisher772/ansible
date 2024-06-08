#!/bin/bash

export "$(cat.env)"

conf_bk() { /bin/cp -f "$1" "$1.old-$SYS_DT" 2>/dev/null; }

check_iptables() {
  if [ -x /sbin/iptables ] && ! iptables -nL INPUT >/dev/null 2>&1; then
    exiterr "IPTables check failed. Reboot and re-run this script."
  fi
}


update_iptables() {
    systemctl stop fail2ban >/dev/null 2>&1

    iptables -FX
    iptables -A INPUT -p udp -m udp --dport 1701 -m policy --dir in --pol none -j DROP
    iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
    iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p udp -m multiport --dports 500,4500 -j ACCEPT
    iptables -A INPUT -p udp -m udp --dport 1701 -m policy --dir in --pol ipsec -j ACCEPT
    iptables -A INPUT -p udp -m udp --dport 1701 -j DROP
    iptables -A FORWARD -m conntrack --ctstate INVALID -j DROP
    iptables -A FORWARD -i eth0 -o ppp+ -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i ppp+ -o eth0 -j ACCEPT
    iptables -A FORWARD -i ppp+ -o ppp+ -j ACCEPT
    iptables -A FORWARD -j DROP
    iptables -t nat -A POSTROUTING -s $VPN_ROUTE_RANGE -o eth0 -j MASQUERADE

    iptables-save >> "$IPT_FILE"
    if [ -f "$IPT_FILE2" ]; then
        conf_bk "$IPT_FILE2"
        /bin/cp -f "$IPT_FILE" "$IPT_FILE2"
    fi

    systemctl restart fail2ban
}

