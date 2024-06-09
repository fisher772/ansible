#!/bin/bash

. /tmp/vpn_sh/vars

create_dir() {
  mkdir -p "$PATH_KEYS"/{cacerts,certs,private}
}

create_keys() {
  pki --gen --type rsa --size 4096 --outform pem > "$PATH_KEYS"/private/ca-key.pem && \

  pki --self --ca --lifetime 3650 --in "$PATH_KEYS"/private/ca-key.pem \
  --type rsa --dn "CN=DevOps VPN CA" --outform pem > "$PATH_KEYS"/cacerts/ca-cert.pem && \

  pki --gen --type rsa --size 4096 --outform pem > "$PATH_KEYS"/private/server-key.pem && \

  pki --pub --in "$PATH_KEYS"/private/server-key.pem --type rsa | \
  pki --issue --lifetime 1825 --cacert "$PATH_KEYS"/cacerts/ca-cert.pem \
  --cakey "$PATH_KEYS"/private/ca-key.pem --dn "CN=$VPN_IP_SERVER" \
  --san "$VPN_IP_SERVER" --san @"$VPN_IP_SERVER" --flag serverAuth --flag ikeIntermediate \
  --outform pem > "$PATH_KEYS"/certs/server-cert.pem
}

setup() {
  create_dir
  create_keys
}

setup "$@"

exit 0
