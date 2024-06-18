@echo off

setlocal DisableDelayedExpansion
set "SPath=%SystemRoot%\System32"
if exist "%SystemRoot%\Sysnative\reg.exe" (set "SPath=%SystemRoot%\Sysnative")
set "Path=%SPath%;%SystemRoot%;%SPath%\Wbem;%SPath%\WindowsPowerShell\v1.0\"
set "_err====== ERROR ====="
set "_work=%~dp0"
if "%_work:~-1%"=="\" set "_work=%_work:~0,-1%"

for /f "tokens=4-5 delims=. " %%i in ('ver') do set version=%%i.%%j
if "%version%" == "10.0" goto :Check_Admin
if "%version%" == "6.3" goto :Check_Admin
if "%version%" == "6.2" goto :Check_Admin
goto :E_Win

:Check_Admin
reg query HKU\S-1-5-19 >nul 2>&1 || goto :E_Admin

echo.
echo Install package VPNCredentialsHelper
powershell -command "Install-Module -Name VPNCredentialsHelper -Force"

title L2TP Configuration Import Helper Script
setlocal EnableDelayedExpansion
cd /d "!_work!"
@cls
echo ===================================================================
echo Welcome^^! Use this helper script to import an L2TP configuration
echo into a PC running Windows 8, 10 or 11.
echo.
echo ===================================================================

echo.
echo Enter the IP address (or DNS name) of the VPN server.
echo Note: This must exactly match the VPN server address in the output
echo of the L2TP helper script on your server.
set server_addr=
set /p server_addr="VPN server address: "
if not defined server_addr goto :Abort
set "server_addr=%server_addr:"=%"
set "server_addr=%server_addr: =%"

echo.
echo Enter the secret key of the L2TP VPN connection.
set secret_key=
set /p username="VPN server secret_key: "
if not defined secret_key goto :Abort
set "secret_key=%secret_key:"=%"
set "secret_key=%secret_key: =%"

echo.
echo Enter your username and password for the IKEv2 VPN connection.
set user_login=
set user_pw=
set /p username="VPN server username: "
set /p password="VPN server password: "
if not defined username || not defined password goto :Abort
set "user_login=%user_login:"=%"
set "user_login=%user_login: =%"
set "user_pw=%user_pw:"=%"
set "user_pw=%user_pw: =%"

set "conn_name_gen=L2TP %server_addr%"
powershell -command "Get-VpnConnection -Name '%conn_name_gen%'" >nul 2>&1
if !errorlevel! neq 0 (
  goto :Enter_Conn_Name
)
set "conn_name_gen=L2TP 2 %server_addr%"
powershell -command "Get-VpnConnection -Name '%conn_name_gen%'" >nul 2>&1
if !errorlevel! neq 0 (
  goto :Enter_Conn_Name
)
set "conn_name_gen=L2TP 3 %server_addr%"
powershell -command "Get-VpnConnection -Name '%conn_name_gen%'" >nul 2>&1
if !errorlevel! equ 0 (
  set conn_name_gen=
)

:Enter_Conn_Name
echo.
echo Provide a name for the new L2TP connection.
set conn_name=
if defined conn_name_gen (
  echo To accept the suggested connection name, press Enter.
  set /p conn_name="L2TP connection name: [%conn_name_gen%] "
  if not defined conn_name set "conn_name=%conn_name_gen%"
) else (
  set /p conn_name="L2TP connection name: "
  if not defined conn_name goto :Abort
)
set "conn_name=%conn_name:"=%"
powershell -command "Get-VpnConnection -Name '%conn_name%'" >nul 2>&1
if !errorlevel! equ 0 (
  echo.
  echo ERROR: A connection with this name already exists.
  goto :Enter_Conn_Name
)

:Create_Conn
echo.
echo Creating VPN connection...
powershell -command "Add-VpnConnection -ServerAddress '%server_addr%' -Name '%conn_name%' -TunnelType L2TP -L2tpPsk '%secret_key%' -Force -EncryptionLevel Required -AuthenticationMethod MSChapv2 -UseWinlogonCredential -RememberCredential -AllUserConnection -PassThru"
powershell -command "Set-VpnConnectionUsernamePassword -connectionname '%conn_name%' -username '%user_login%' -password '%user_pw%'"
if !errorlevel! neq 0 (
  echo ERROR: Could not create the L2TP VPN connection.
  goto :Done
)

echo Setting IPsec configuration...
powershell -command "Set-VpnConnectionIPsecConfiguration -ConnectionName '%conn_name%' -AuthenticationTransformConstants AES256GCM16 -CipherTransformConstants AES256GCM16 -EncryptionMethod AES256 -IntegrityCheckMethod SHA256 -PfsGroup None -PassThru -Force"
if !errorlevel! neq 0 (
  echo ERROR: Could not set IPsec configuration for the L2TP VPN connection.
  goto :Done
)

:E_Admin
echo %_err%
echo This script requires administrator privileges.
echo Right-click on the script and select 'Run as administrator'.
goto :Done

:E_Win
echo %_err%
echo This script requires Windows 8, 10 or 11.
goto :Done

:E_Ps
echo %_err%
echo This script requires 'powershell', which is not detected.
goto :Done

:Abort
echo.
echo Abort. No changes were made.

:Done
echo.
echo Press any key to exit.
pause >nul
goto :eof
