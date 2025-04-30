@set @_cmd=1 /*
@echo ON
setlocal EnableExtensions

whoami /groups | findstr "S-1-16-12288" >nul && goto :admin
if "%~1"=="RunAsAdmin" goto :error
cscript /nologo /e:javascript "%~f0" || goto :error
exit /b

:error
echo.
echo Error: Administrator privileges elevation failed,
echo        please manually run this script as administrator.
echo.
goto :end

:admin
pushd "%~dp0"
sc stop dnscrypt-proxy-direct
sc delete dnscrypt-proxy-direct
.\dnscrypt-proxy\nssm.exe install dnscrypt-proxy-direct dnscrypt-proxy.exe "-config dnscrypt-proxy-direct.toml"
.\dnscrypt-proxy\nssm.exe set dnscrypt-proxy-direct AppDirectory %~dp0%dnscrypt-proxy
sc start dnscrypt-proxy-direct

sc stop dnscrypt-proxy-proxy
sc delete dnscrypt-proxy-proxy
.\dnscrypt-proxy\nssm.exe install dnscrypt-proxy-proxy dnscrypt-proxy.exe "-config dnscrypt-proxy-proxy.toml"
.\dnscrypt-proxy\nssm.exe set dnscrypt-proxy-proxy AppDirectory %~dp0%dnscrypt-proxy
sc start dnscrypt-proxy-proxy

sc stop dnscrypt-proxy-backup
sc delete dnscrypt-proxy-backup
.\dnscrypt-proxy\nssm.exe install dnscrypt-proxy-backup dnscrypt-proxy.exe "-config dnscrypt-proxy-backup.toml"
.\dnscrypt-proxy\nssm.exe set dnscrypt-proxy-backup AppDirectory %~dp0%dnscrypt-proxy
sc start dnscrypt-proxy-backup

.\mosdns\mosdns.exe service stop
.\mosdns\mosdns.exe service uninstall
.\mosdns\mosdns.exe service install
.\mosdns\mosdns.exe service start

.\AdGuardHome\AdGuardHome.exe -s stop
.\AdGuardHome\AdGuardHome.exe -s uninstall
.\AdGuardHome\AdGuardHome.exe --no-check-update --web-addr 127.0.0.1:3123 -s install
.\AdGuardHome\AdGuardHome.exe -s start
popd
echo.
echo install over!

:end
set /p =Press [Enter] to exit . . .
exit /b */

// JScript, restart batch script as administrator
var objShell = WScript.CreateObject('Shell.Application');
var ComSpec = WScript.CreateObject('WScript.Shell').ExpandEnvironmentStrings('%ComSpec%');
objShell.ShellExecute(ComSpec, '/c ""' + WScript.ScriptFullName + '" RunAsAdmin"', '', 'runas', 1);
