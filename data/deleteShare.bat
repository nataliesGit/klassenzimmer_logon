@echo off
if exist "C:\tempAutoit\" RD c:\tempAutoit /S /Q
net share autoit /Delete

if exist "C:\vnc\" RD c:\vnc /S /Q
net share vnc /Delete




