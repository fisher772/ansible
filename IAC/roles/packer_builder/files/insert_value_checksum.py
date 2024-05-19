# Имя файла, из которого считывается контрольная сумма
checksum_file = 'iso_checksum.txt'
# Имя файла конфигурации Packer, который нужно обновить
packer_vars_file = 'vars.pkr.auto.pkrvars.hcl'

# Читаем значение контрольной суммы из файла
with open(checksum_file, 'r') as file:
    iso_checksum = file.read().strip()

# Читаем текущее содержимое файла vars.pkr.auto.pkrvars.hcl
with open(packer_vars_file, 'r') as file:
    content = file.read()

# Обновляем значение переменной iso_checksum в содержимом файла
content = content.replace("iso_value_checksum = ''", f"iso_value_checksum = '{iso_checksum}'")

# Записываем обновленное содержимое обратно в файл vars.pkr.auto.pkrvars.hcl
with open(packer_vars_file, 'w') as file:
    file.write(content)

print(f'Переменная iso_checksum обновлена в файле {packer_vars_file}')