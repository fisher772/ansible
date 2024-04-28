#!/bin/bash

create_inventory()
{
    if [[ -d "inventory/$1" ]];
    then
        echo "Inventory '$1' already exist. Skipped."
    else
        mkdir -p inventory/$1/host_vars/$1
        mkdir -p inventory/$1/group_vars/$1
        echo "[$1]" > inventory/$1/hosts
        touch inventory/$1/host_vars/$1/vars
        echo "To create host_vars vault run: "
        echo "ansible-vault create inventory/$1/host_vars/$1/vault"
        touch inventory/$1/group_vars/$1/vars
        echo "To create group_vars vault run: "
        echo "ansible-vault create inventory/$1/group_vars/$1/vault"
        echo "Inventory '$1' created."
    fi
}

if [[ $# -eq 0 ]]; then
    echo 'At least one inventory name argument required'
    echo 'Usage example: ./ansible_inventory inventory_name1 inventory_name2 inventory_name3'
    exit 0
fi

for inventory_name in "$@"; do
    create_inventory $inventory_name
done
