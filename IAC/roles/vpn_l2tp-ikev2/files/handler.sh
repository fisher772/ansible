#!/bin/bash

for script in /tmp/vpn_sh/*.sh; do
    case "$script" in
        /tmp/vpn_sh/handler.sh)
            ;;
        *)
            echo "RUN $script..."
            chmod +x "$script"
           bash "$script"
            ;;
    esac
done
