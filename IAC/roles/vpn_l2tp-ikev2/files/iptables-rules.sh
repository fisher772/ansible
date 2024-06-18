#!/bin/bash

. /tmp/vpn_sh/vars

conf_bk() { /bin/cp -f "$1" "$1.old-$SYS_DT" 2>/dev/null; }

check_os() {
  if command -v lsb_release &> /dev/null; then
    os_type=$(lsb_release -si 2>/dev/null)
  else
    if [ -f /etc/redhat-release ]; then
      os_type=RedHat
    fi
  fi
}

check_iptables() {
  if [ -x /sbin/iptables ] && ! iptables -nL INPUT >/dev/null 2>&1; then
    exiterr "IPTables check failed. Reboot and re-run this script."
  fi
}

update_iptables() {
    systemctl stop fail2ban >/dev/null 2>&1

    iptables -F && iptables -X
    iptables -A INPUT -p udp -m multiport --dports 500,4500 -j ACCEPT
    iptables -t nat -A POSTROUTING -s "$VPN_ROUTE_RANGE" -o eth0 -j MASQUERADE
    iptables -t nat -A POSTROUTING -s "$VPN_ROUTE_RANGE" -o eth0 -m policy --pol ipsec --dir out -j ACCEPT
    iptables -t mangle -A FORWARD -s "$VPN_ROUTE_RANGE" -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360
    iptables -t filter -A FORWARD --match policy --pol ipsec --dir in --proto esp -s "$VPN_ROUTE_RANGE" -j ACCEPT
    iptables -t filter -A FORWARD --match policy --pol ipsec --dir out --proto esp -d "$VPN_ROUTE_RANGE" -j ACCEPT
    iptables -I INPUT -p udp --dport 1701 -m policy --dir in --pol none -j DROP
    iptables -A INPUT -p udp -m udp --dport 1701 -m policy --dir in --pol ipsec -j ACCEPT
    iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
    iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -m conntrack --ctstate INVALID -j DROP
    iptables -A FORWARD -i eth0 -o ppp+ -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i ppp+ -o eth0 -j ACCEPT
    iptables -A FORWARD -i ppp+ -o ppp+ -j ACCEPT
    iptables -A FORWARD -j DROP

    iptables-save >> "$IPT_FILE"
    if [ -f "$IPT_FILE2" ]; then
        conf_bk "$IPT_FILE2"
        /bin/cp -f "$IPT_FILE" "$IPT_FILE2"
    fi
}

enable_on_boot() {
  ipt_load=1
  if [ -f "$IPT_FILE2" ] && { [ -f "$IPT_PST" ] || [ -f "$IPT_PST2" ]; }; then
    ipt_load=0
  fi

  if [ "$ipt_load" = "1" ]; then
    mkdir -p /etc/network/if-pre-up.d
cat > /etc/network/if-pre-up.d/iptablesload <<'EOF'
#!/bin/sh
iptables-restore < /etc/iptables.rules
exit 0
EOF
    chmod +x /etc/network/if-pre-up.d/iptablesload

cat > /etc/systemd/system/load-iptables-rules.service <<'EOF'
[Unit]
Description = Load /etc/iptables.rules
DefaultDependencies=no

Before=network-pre.target
Wants=network-pre.target

Wants=systemd-modules-load.service local-fs.target
After=systemd-modules-load.service local-fs.target

[Service]
Type=oneshot
ExecStart=/etc/network/if-pre-up.d/iptablesload

[Install]
WantedBy=multi-user.target
EOF
      systemctl enable load-iptables-rules 2>/dev/null
  fi

  if [ "$os_type" = RedHat ]; then
    for svc in fail2ban strongswan-starter xl2tpd; do
      update-rc.d "$svc" enable >/dev/null 2>&1
      systemctl enable "$svc" 2>/dev/null
    done
  else
    for svc in fail2ban strongswan xl2tpd; do
      update-rc.d "$svc" enable >/dev/null 2>&1
      systemctl enable "$svc" 2>/dev/null
    done
  fi

  if ! grep -qs "fisher VPN script" /etc/rc.local; then
    if [ -f /etc/rc.local ]; then
      conf_bk "/etc/rc.local"
      sed --follow-symlinks -i '/^exit 0/d' /etc/rc.local
    else
      echo '#!/bin/sh' > /etc/rc.local
    fi
cat >> /etc/rc.local <<EOF
# Added by fisher VPN script
(sleep 15
systemctl restart ipsec
systemctl restart xl2tpd
echo 1 > /proc/sys/net/ipv4/ip_forward)&
exit 0
EOF
  fi
}

setup() {
  check_os
  conf_bk
  check_iptables
  update_iptables
  enable_on_boot
}

setup "$@"

exit 0
