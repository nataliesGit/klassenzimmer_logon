@echo off
if not exist "C:\vnc\" mkdir C:\vnc
REM ntfs Berechtigungen setzen
icacls "C:\vnc" /grant:r Jeder:F



REM share freigabe und Berechtigung
net share vnc="C:\vnc" /grant:Jeder,Full






