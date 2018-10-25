@echo off
REM ntfs Berechtigungen setzen
icacls "C:\tempAutoitAllplan" /grant:r Jeder:F

REM share freigabe und Berechtigung
net share tempAutoitAllplan="C:\tempAutoitAllplan" /grant:Jeder,Full






