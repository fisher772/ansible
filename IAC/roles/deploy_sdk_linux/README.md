Scenario "Soil/Fertilizer"

This Ansible playbook is designed to automate the deployment of SDK services on Linux systems. It supports both Debian/Ubuntu and RedHat distributions, ensuring a smooth deployment process across different Linux environments.


Features

Cross-platform support: The playbook is designed to work with both Debian/Ubuntu and RedHat distributions.
Automated package installation: It installs necessary packages and utilities for the SDK services.
Docker repository setup: Configures Docker repositories for both Debian/Ubuntu and RedHat distributions.
Service management: Manages the installation, starting, and enabling of services.
SSH key management: Handles SSH key generation, cleaning, and addition to GitHub.


Prerequisites

Ansible installed on the control node.
SSH access to the target hosts.
Python installed on the target hosts.


Usage

Define your hosts: Specify the target hosts in the MYHOSTS variable in your inventory file or as an extra variable when running the playbook.
Prepare credentials: Create a credentials.yml file with any necessary credentials or configuration details.
Run the playbook: Execute the playbook using the following command:
ansible-playbook deploy_sdk_linux.yml -i inventory.ini
Replace inventory.ini with the path to your inventory file.


Customization

Custom packages: Modify the packages variable to include any additional packages you need to install.
Custom services: Update the services variable to include any specific services you need to manage.
SSH key management: Adjust the SSH key management tasks according to your requirements, including the path to the SSH key file and the GitHub URL.


Notes

The playbook uses the become directive to execute tasks with elevated privileges. Ensure that the user specified in the inventory file has the necessary sudo privileges on the target hosts.
The playbook assumes that the target hosts are accessible via SSH and that Python is installed.


License

This project is licensed under the MIT License. See the LICENSE file for details.


==================================================================================================


Сценарий "Почва/Удобрение"

Этот плейбук Ansible предназначен для автоматизации развертывания SDK-сервисов на системах Linux. Он поддерживает как Debian/Ubuntu, так и RedHat дистрибутивы, обеспечивая плавное развертывание в различных Linux окружениях.


Функции

Поддержка кросс-платформенности: Плейбук разработан для работы как с Debian/Ubuntu, так и с RedHat дистрибутивами.
Автоматизированная установка пакетов: Устанавливает необходимые пакеты и утилиты для SDK-сервисов.
Настройка репозитория Docker: Конфигурирует репозитории Docker для Debian/Ubuntu и RedHat дистрибутивов.
Управление сервисами: Управляет установкой, запуском и включением сервисов.
Управление SSH-ключами: Обрабатывает генерацию SSH-ключей, их очистку и добавление в GitHub.
Предварительные требования
Ansible установлен на управляющем узле.
Доступ по SSH к целевым хостам.
Python установлен на целевых хостах.


Использование

Определите ваши хосты: Укажите целевые хосты в переменной MYHOSTS в вашем инвентарном файле или как дополнительную переменную при запуске плейбука.
Подготовьте учетные данные: Создайте файл credentials.yml с любыми необходимыми учетными данными или деталями конфигурации.
Запустите плейбук: Выполните плейбук с помощью следующей команды:
ansible-playbook deploy_sdk_linux.yml -i inventory.ini
Замените inventory.ini на путь к вашему инвентарному файлу.


Настройка

Пользовательские пакеты: Измените переменную packages, чтобы включить любые дополнительные пакеты, которые вам нужно установить.
Пользовательские сервисы: Обновите переменную services, чтобы включить любые конкретные сервисы, которые вам нужно управлять.
Управление SSH-ключами: Настройте задачи управления SSH-ключами в соответствии с вашими требованиями, включая путь к файлу SSH-ключа и URL GitHub.


Примечания

Плейбук использует директиву become для выполнения задач с повышенными привилегиями. Убедитесь, что пользователь, указанный в инвентарном файле, имеет необходимые привилегии sudo на целевых хостах.
Плейбук предполагает, что целевые хосты доступны по SSH и что на них установлен Python.


Лицензия

Этот проект лицензирован под лицензией MIT. Смотрите файл LICENSE для деталей.