# Структура для работы с ansible

Для удобства используется inventory directory structure.  
В качестве inventory выступает каталог inventory. Структура каталогов имеет следующий вид:
```
├── ansible.cfg.jenkins - конфиг адаптированный под использование ansible через Jenkins job
├── playbooks - хранилище плейбуков
├── roles - хранилище ролей
├── inventory - хранилище inventory
│   └── jenkins_agent - inventory item, содержит каталоги host_vars/group_vars
│       ├── group_vars
│       │   └── jenkins_agent
│       │       ├── vars - файл с переменными в открытом виде
│       │       └── vault - файл для хранения секретов
│       └── hosts - хостфайл, в котором перечислены узлы сети, относящиеся к данному inventory item

```


Для запуска плейбука используется команда
```
ansible-playbook -i inventory/jenkins_agent playbooks/jenkins_agent.yml
```
Возможен вариант подключения к хостам с помощью ssh-ключа (юзер drit в jenkins), либо по логину/паролю.  
Данные для подключения по ssh могут быть заданы в vars или vault в зависимости от подключения.  
При запуске через Jenkins в ansible.cfg добавляются параметры roles_path и vault_password_file, чтобы определить путь к хранилищу ролей, а также избежать запроса на ввод паролей ssh-юзера и пароля от vault.

## Пример использования
### Условие
Имеем некий сервер test.lan.devops.ru, на котором хотим установить docker-ce. Доступ к серверу по ssh организован от юзера devops через ключ, sudo требует ввод пароля, ключ сервисного пользователя jenkins добавлен в authorized_keys.
### Решение
С помощью скрипта ansible_inventory.sh создаем структуру inventory, где будут файлы hosts, vars, vault  
```
./ansible_inventory.sh docker_hosts
```
После чего в каталоге inventory будет лежать готовая для заполнения данными структура и краткий help по созданию vault. Им мы и воспользуемся:
```
ansible-vault create inventory/docker_hosts/group_vars/docker_hosts/vault
```
ВНИМАНИЕ! ПАРОЛЬ НА VAULT ДОЛЖЕН БЫТЬ ВСЕГДА ОДИН И ТОТ ЖЕ, ЧТОБЫ JENKINS МОГ С ЕГО ПОМОЩЬЮ ДЕШИФРОВАТЬ VAULT.  
В vault заносим sudo password для юзера drit:
```
ansible_become_pass: $o$trongPa$$
```
Задаем host_vars/group_vars. Здесь нам нужно указать, как минимум, настройки подключения к хостам. В нашем случае нужно указать имя юзера в файле ./inventory/docker_hosts/group_vars/docker_hosts/vars:

```
ansible_user: drit
```
Правим ./inventory/docker_hosts/hosts , добавляем запись о нашем сервере test.lan.ubrr.ru.  
В каталог roles ложим все нужные роли. Пусть в нашем случае это будут yum_repos и docker_ce.  
В каталоге playbooks создаем плейбук с именем install_docker_ce.yml, в котором будут вызываться вышеописанные роли.  
Чтобы выполнить плейбук через jenkins, можно воспользоваться параметризированной джобой https://jenkins.lan.ubrr.ru/job/DevOps/job/Ansible/job/Run-Ansible-Playbook/  
Если же нужно выполнять действие регулярно, то рядом можно создать джобу с нужными нам параметрами:
```
build job: './Run-Ansible-Playbook', parameters: [
    string(name: 'inventoryName', value: 'docker_hosts'),
    string(name: 'playbookName', value: 'install_docker_ce')
]
```
# Получение секретов из hashicorp vault
Ansible может получать секреты из hashicorp vault.  
Для этого необходимо установить пакет hvac
```
pip install hvac
pip3 install hvac
```
Далее нужно добавить в терсинальную сессию переменные окружения.  
Для авторизации через токен:  
```
export VAULT_ADDR=https://vault-dev.lan.ubrr.ru:8200 
export VAULT_AUTH_METHOD=token
export VAULT_TOKEN=TOKENISHERE
```
С ldap-авторизацией не все так просто, т.к. нет нативно поддерживаемых переменных окружения для логина и пароля.  
Обход данной проблемы заключается в самостоятельном определении и обработке переменных VAULT_USER/VAULTPASSWORD в плейбуках.
Для авторизации через ldap:
```
export VAULT_ADDR=https://vault-dev.lan.ubrr.ru:8200 
export VAULT_AUTH_METHOD=ldap
export VAULT_USER=USERISHERE
export VAULT_PASSWORD=PASSWORDISHERE
```
В итоге, остается только запустить плейбук:  
```
ansible-playbook -i inventory/vault/ ./playbooks/setup_vault-dev.yml 
```
