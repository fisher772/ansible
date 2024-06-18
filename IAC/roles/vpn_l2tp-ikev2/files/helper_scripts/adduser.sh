#!/bin/bash

. vars

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

    cat >> "$path_keys_true/users_creds/${user_name}.txt" <<EOF
user: $user_name
password: $user_pw
EOF
    chmod 644 "$path_keys_true/users_creds/${user_name}.txt"
}

setup() {
  check_dir
  create_eap_user
}

setup "$@"

exit 0
