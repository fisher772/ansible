#!/bin/bash

. /tmp/vpn_sh/vars

check_dir() {
  if [ -d "$PATH_KEYS_1" ]; then
    path_keys_true="$PATH_KEYS_1"
  elif [ -d "$PATH_KEYS_2" ]; then
    path_keys_true="$PATH_KEYS_2"
  else
    echo "Error: No key paths found"
    exit 1
  fi
}

create_dir() {
  mkdir -p "$path_keys_true"/{cacerts,certs,private,users_creds}
}

create_keys() {
  pki --gen --type rsa --size 4096 --outform pem > "$path_keys_true"/private/ca-key.pem && \

  pki --self --ca --lifetime 3650 --in "$path_keys_true"/private/ca-key.pem \
  --type rsa --dn "C=$VPN_CERT_C, O=$VPN_CERT_O, CN=$VPN_CERT_CN" --outform pem > "$path_keys_true"/cacerts/ca-cert.pem && \

  pki --gen --type rsa --size 4096 --outform pem > "$path_keys_true"/private/server-key.pem && \

  pki --pub --in "$path_keys_true"/private/server-key.pem --type rsa | \
  pki --issue --lifetime 1825 --cacert "$path_keys_true"/cacerts/ca-cert.pem \
  --cakey "$path_keys_true"/private/ca-key.pem --dn "C=$VPN_CERT_C, O=$VPN_CERT_O, CN=$VPN_DOMAIN" \
  --san "$VPN_DOMAIN" --flag serverAuth --flag ikeIntermediate \
  --outform pem > "$path_keys_true"/certs/server-cert.pem
}

create_eap_user() {
    local user_name=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 8 | head -n 1)
    local user_pw=$(openssl rand -base64 24)

    if [ -f /etc/ipsec.secrets ]; then
        path_conf_true="$PATH_CONF_1"
    elif [ -f /etc/strongswan/ipsec.secrets ]; then
        path_conf_true="$PATH_CONF_2"
    fi
    cat >> "$path_conf_true" <<EOF
$user_name : EAP "$user_pw"
EOF

    cat > "$path_keys_true/users_creds/${user_name}.txt" <<EOF
user: $user_name
password: $user_pw
EOF
    chmod 644 "$path_keys_true/users_creds/${user_name}.txt"
}

setup() {
  check_dir
  create_dir
  create_keys
  create_eap_user
}

adduser() {
  check_dir
  create_eap_user
}

if [ "$1" == "--adduser" ]; then
  adduser
  exit 0
fi

setup "$@"

exit 0
