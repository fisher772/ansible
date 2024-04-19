import pwd
import os
import requests
from requests.exceptions import HTTPError
from bs4 import BeautifulSoup

# Куда будет импортирован дата файл со списком
dest_path = '/home/ansible/ansible/projects/IAC/playbooks/roles/deploy_sdk_linux/vars/vers_distribs.yml'

# Ранжируем список в перемнных
centos = list(range(7, 10))
rhel = list(range(7, 10))
fedora = list(range(24, 41))

# Создаем пустой словарь для хранения значений
versions = {
    "centos_vers": centos,
    "rhel_vers": rhel,
    "fedora_vers": fedora
}

debian = 'https://download.docker.com/linux/debian/dists/'
ubuntu = 'https://download.docker.com/linux/ubuntu/dists/'

for url, key in [(debian, 'debian_vers'), (ubuntu, 'ubuntu_vers')]:
    try:
        response = requests.get(url)
        response.raise_for_status()
    except HTTPError as http_err:
        print(f'HTTP error occurred: {http_err}') # Python 3.6
    except Exception as err:
        print(f'Other error occurred: {err}') # Python 3.6
    else:
        # Создаем объект BeautifulSoup для парсинга HTML
        soup = BeautifulSoup(response.text, 'html.parser')
        # Находим все теги <a> внутри тега <body>
        a_tags = soup.find_all('a')
        # Создаем пустой список для хранения значений для текущего URL
        values = []
        # Извлекаем текст каждого тега <a> и добавляем в список, если он не содержит символов '/' и одинарные кавычки, и не ведет к родительскому каталогу
        for a in a_tags:
            href = a.get('href')
            if href and not href.startswith('../'):
                # Удаляем лишние символы '/' и одинарные кавычки
                cleaned_href = href.replace('/', '').replace("'", "")
                values.append(cleaned_href)
        # Добавляем список значений в словарь с ключом, соответствующим текущему URL
        versions[key] = values

# Форматируем данные вручную для сохранения в файл .yml
formatted_data = ""
for key, values in versions.items():
    formatted_data += f"{key}: {values}\n"

# Сохраняем форматированные данные в файл .yml
with open(dest_path, 'w') as file:
    file.write(formatted_data)

# Устанавливаем гранты и владельца дата файла 
uid = pwd.getpwnam('ansible').pw_uid
gid = pwd.getpwnam('ansible').pw_gid

os.chown(dest_path, uid, gid)
os.chmod(dest_path, 0o755)
