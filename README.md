# Structure for working with Ansible. IAC

[![GitHub](https://img.shields.io/badge/GitHub-Repo-red%3Flogo%3Dgithub?logo=github&label=GitHub%20Ansible-Repo)](https://github.com/fisher772/ansible)

Ansible is an open source IT automation engine that automates provisioning, configuration management, application deployment, orchestration, and many other IT processes. It is free to use, and the project benefits from the experience and intelligence of its thousands of contributors.

[Ansible reference docs](https://docs.ansible.com)

[Ansible reference docs for Install and Upgrade](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible)


For convenience, an inventory directory structure is used.

The inventory directory acts as an inventory. The directory structure looks like this:

\* You can override it for the CI/CD agent or create a separate item for the agent


```
├── IAC
│ ├── inventory         - inventory storage
│ │ ├── ansible.cfg     - config adapted for use with Ansible
│ │ ├── env_example     - host file example, which lists network nodes in yml format, related to this inventory
│ │ ├── group_vars      - directory with variables for node groups in plain text and an example in yml format
│ │ ├── hosts.yml       - host file, which lists network nodes in yml format, related to this inventory
│ │ └── host_vars       - directory with single-host variables in plain text and an example in yml format
│ ├── playbooks         - Ansible playbooks repository
│ └── roles             - Ansible pipeline/role patterns repository

```


To launch a playbook, use the following commands:

```
# Launching with hosts/inventory item specified
ansible-playbook -i inventory/<inventory_item> playbooks/<playbook_agent.yml>

# If hosts are defined in a playbook or additionally in role variables using playbooks
ansible-playbook playbooks/<dir_playbook>/<playbook.yml>
```
It is possible to connect to hosts using an ssh key or login/password.
Data for connecting via ssh can be specified in vars or vault depending on the connection.

```
# Getting secrets from hashicorp vault
Ansible can get secrets from Hashicorp Vault
To do this, you need to install the hvac package

pip install hvac
pip3 install hvac
```

Next, you need to add the following to the terminal session environment variables.

For authorization via token:

```
export VAULT_ADDR=https://vault-dev.lan.ubrr.ru:8200 
export VAULT_AUTH_METHOD=token
export VAULT_TOKEN=TOKENISHERE
```

With LDAP authorization, things are not so simple, because there are no natively supported environment variables for login and password.
The workaround for this problem is to independently define and process the VAULT_USER/VAULTPASSWORD variables in playbooks.

For authorization via LDAP:

```
export VAULT_ADDR=https://vault.xmaple.com:8200 
export VAULT_AUTH_METHOD=ldap
export VAULT_USER=USERISHERE
export VAULT_PASSWORD=PASSWORDISHERE
```

Finally, all that remains is to launch the playbook:

```
ansible-playbook -i inventory/vault ./playbooks/setup_vault.yml 
```
