p@echo off  
IF NOT EXIST C:\printToolV3 GOTO ende

echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs

REM echo sLinkFile = "%HOMEDRIVE%%HOMEPATH%\Desktop\PrintToolV3.lnk" >> CreateShortcut.vbs
echo sLinkFile = "C:\Users\Public\Desktop\PrintToolV3.lnk" >> CreateShortcut.vbs

echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "C:\printToolV3\Print Tool V3.exe" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript CreateShortcut.vbs
del CreateShortcut.vbs

:ende




