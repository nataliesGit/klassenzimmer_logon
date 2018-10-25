@echo off
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v SoftwareSASGeneration /t REG_DWORD /d 1 /f
