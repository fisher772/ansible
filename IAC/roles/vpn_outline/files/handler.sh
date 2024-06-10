#!/bin/bash

executor() {
  wget -c -q -P /temp/vpn_outline https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh

  chmod +x /temp/vpn_outline/install_server.sh

  sed -i '/END_OF_SERVER_OUTPUT/i\ \
  $(printf "{\"apiUrl\":\"$(get_field_value apiUrl)\",\"certSha256\":\"$(get_field_value certSha256)\"}" > /temp/vpn_outline/linkapi.txt) \
  ' /temp/vpn_outline/install_server.sh > /dev/null 2>&1

  yes | bash /temp/vpn_outline/install_server.sh
}

setup() {
  executor
}

setup "$@"

exit 0
