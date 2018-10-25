@echo off

if not exist "C:\tempAutoit\" mkdir C:\tempAutoit
REM ntfs Berechtigungen setzen
icacls "C:\tempAutoit" /grant:r Jeder:F

REM share freigabe und Berechtigung
net share autoit="C:\tempAutoit" /grant:Jeder,Full







