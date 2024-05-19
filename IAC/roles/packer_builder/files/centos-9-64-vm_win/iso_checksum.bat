@echo off
chcp 65001
setlocal

:: Запрашиваем путь к ISO-файлу, если аргумент не передан
if "%~1"=="" (
    set /p "ISO_IMAGE_PATH=Введите путь к ISO-файлу: "
) else (
    set "ISO_IMAGE_PATH=%~1"
)

:: Генерируем контрольную сумму с использованием CertUtil и записываем её в плоский файл
certUtil -hashfile "%ISO_IMAGE_PATH%" SHA256 | findstr /V ":" > ./iso_checksum.txt

echo Контрольная сумма успешно сохранена в iso_checksum.txt.

endlocal
