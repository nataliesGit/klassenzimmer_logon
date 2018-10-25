@echo off

if not exist "C:\Program Files (x86)\UltraVNC\" GOTO installvnc
net start ultravnc
exit


:installvnc
if not exist C:\temp\ mkdir C:\temp\
net use z: \\localhost\vnc /user:mschool-ad\n.scheuble_adm test12345
robocopy z:\ C:\temp\ /MIR 

REM Run install
REM msiexec /i C:\temp\UltraVNC_64bit.msi /quiet /qn /norestart /log c:\temp\install.log
msiexec /i C:\temp\UltraVNC_64bit.msi /quiet /qn /norestart

net use z: /Delete /yes
pause


