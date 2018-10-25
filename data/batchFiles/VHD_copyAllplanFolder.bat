@echo off
IF EXIST C:\temp\Allplan2015\ GOTO ende
net use z: \\localhost\tempAutoitAllplan /user:mschool-ad\n.scheuble_adm test12345
robocopy z:\ C:\temp\ /MIR 

net use z: /Delete /yes
:ende
pause