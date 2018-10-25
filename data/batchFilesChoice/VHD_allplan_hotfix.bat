@echo off 
net use r: \\srv\bs1590-resources /user:mschool\1590.awb1 test12345
robocopy r:\public\Allplan_Updates\x64\ C:\Daten\Nemetschek\Allplan\Download\x64\ /MIR



