#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ico\key.ico
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <File.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>
#Include <Array.au3>
#include <GuiComboBox.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <StringConstants.au3>
#include <Inet.au3>
#include <array.au3>


Global $ip

If $CmdLine[0] Then
	$ip = $CmdLine[1]
;~ 	_ArrayDisplay($CmdLine)
	TCPStartup()
	Global $iPing = Ping($ip)
;~ 	MsgBox($MB_SYSTEMMODAL, "",$iPing)
	TCPShutdown()
	if $iPing = 1 then
		runLogonBAT()
	EndIf
EndIf

Func runLogonBAT()
;~ 	MsgBox($MB_SYSTEMMODAL, "ip in shutdown  function",$ip)
;~ 	run("psexec.exe -accepteula \\"&$ip&" -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\shutdown.bat", @SW_HIDE)
	local $command1 = "psexec.exe -accepteula \\"&$ip&" -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\logon.bat"

	local $command2 = "psexec.exe -accepteula \\10.96.97.113 -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\logon.bat"
;~ 	MsgBox($MB_SYSTEMMODAL, "commands","command 1 mit var" & @CRLF & _
;~ 	$command1 & @CRLF & _
;~ 	"command 2 funktioniert ohne var:"& @CRLF & _
;~ 	$command2)
	run($command1)
;~ Consolewrite("psexec.exe -accepteula \\10.96.97.113 -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\shutdown.bat")


;~ 	Consolewrite("psexec.exe -accepteula \\"&$ip&" -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\shutdown.bat")
EndFunc
;~ run("psexec.exe -accepteula \\10.96.97.113 -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\logon.bat")

;~ For the record,
;~ the following single line local script ran existing remote script  "C:\WIP-GUI.au3" fine:
;~ Run('psexec \\remotemachine -u admin -p password -i -d "C:\Program Files\Autoit3\AutoIt3.exe" C:\WIP-GUI.au3', '', @SW_HIDE)

;~ I'm trying to run autoit script on remote machine (with psexec from SysInternals\PCTools). Here is how I do it:
;~ 1. On local machine, I run the following code (local.bat):
;~ psexec.exe \\remotecomp -u remoteuser -p password -i c:\windows\remote.bat
;~ 2. The content of remote.bat located on remote machine:
;~ "C:\Program Files\AutoIt3\autoit3.exe" C:\work\remotetest.au3
;~ 3. The content of remotetest.au3:
;~ run ('cmd /c "compmgmt.msc"', @SystemDir, @SW_HIDE)
;~ oder
;~ run(@COMSPEC & " /c " & @WindowsDir & "\system32\mmc.exe compmgnt.msc", "", @SW_HIDE)


;~ ************** CAVE x64 kompilieren !!!******************************
;~ Are you compiling it as a x86 or x64 bit? If you are compiling it as x86, and trying to run
;~ it with PsExec on a remote x64 system, it will not run due to PsExec copying the file to
;~ admin$/temp. This directory is actually C:\windows\system32\temp on the remote system,
;~ which is for x64 executable only. To get around this, compile as x64 or copy the file
;~ to another directory with AutoIt and use PsExec to execute from there without the -c option.
;~ Adam


;~ ************** schoenes Beispiel fileinstall ********************************
;~ use the FileInstall to check arch and then use the appropriate script :graduated:
;~ My example when I installed printers

;~ If @OSArch = "X86" Then
;~ _RunDOS("if not exist C:\temp\ mkdir C:\temp\")
;~ FileInstall("C:\Installationwizard\Printer.exe", "C:\temp\Printer.exe")
;~ _RunDOS("start C:\temp\Printer.exe")
;~ ElseIf @OSArch = "X64" Then
;~ _RunDOS("if not exist C:\temp\ mkdir C:\temp\")
;~ FileInstall("C:\Installationwizard\Printer64.exe", "C:\temp\Printer64.exe")
;~ _RunDOS("start C:\temp\Printer64.exe")
;~ Else
;~ MsgBox(0, "Error", 'Setup cannot determine your OS architechture,' & @CRLF & ' please contact edb@kjemi.uio.no')
;~ EndIf
;~ Exit


