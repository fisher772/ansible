#!bin/sh
mkdir -m 700 -p ~/.ssh
echo "key">> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys