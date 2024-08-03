#!/bin/bash

change_resolve() {
  if [[ -f /etc/resolv.conf || true && ! -f /etc/resolv.conf.bak ]]; then
    mkdir -p /etc/systemd/resolved.conf.d 2>/dev/null
    rm -f /etc/systemd/resolved.conf.d/* 2>/dev/null
    mv -v /etc/resolv.conf /etc/resolv.conf.bak 2>/dev/null
    cat > /etc/systemd/resolved.conf.d/adguard.conf <<EOF
#fisher adguard
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
EOF
    ln -s /etc/systemd/resolved.conf.d/adguard.conf /etc/resolv.conf
    echo "Restart systemd-resolved"
    systemctl reload-or-restart systemd-resolved
  else
    :
  fi
}

change_resolve

exit 0
