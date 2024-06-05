#!/bin/bash

# Enable IP masquerading
iptables --table nat --append POSTROUTING --jump MASQUERADE

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Disable accepting and sending redirects for all interfaces
for each in /proc/sys/net/ipv4/conf/*
do
    echo 0 > $each/accept_redirects
    echo 0 > $each/send_redirects
done

# Restart IPsec service if installed
if command -v ipsec >/dev/null; then
    /etc/init.d/ipsec restart
fi
