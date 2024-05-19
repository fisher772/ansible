#!/bin/bash

# Запрашиваем путь к ISO-файлу, если аргумент не передан
if [ -z "$1" ]; then
    echo "Введите путь к ISO-файлу:"
    read ISO_IMAGE_PATH
else
    ISO_IMAGE_PATH="$1"
fi

# Генерируем контрольную сумму с использованием sha256sum и записываем её в плоский файл
sha256sum "$ISO_IMAGE_PATH" | awk '{print $1}' >> /home/ansible/ansible/projects/IAC/roles/packer_builder/files/Centos_9_vb/iso_checksum.txt

echo "Контрольная сумма успешно сохранена в iso_checksum.txt."
