@echo off
net use z: \\localhost\autoit /user:mschool-ad\n.scheuble_adm test12345

for /f "tokens=1-2 delims=:" %%a in ('ipconfig^|find "IPv4"') do set ip=%%b
set ip=%ip:~1%
echo %ip%
query user > z:\%ip%.txt

FOR /F "usebackq" %%i IN (`hostname`) DO SET MYVAR=%%i
ECHO %MYVAR% >> z:\%ip%.txt

net use z: /Delete /yes




