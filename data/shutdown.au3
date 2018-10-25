#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ico\shutdown.ico
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
		shutdownPc()
	EndIf
EndIf

Func shutdownPc()
;~ 	MsgBox($MB_SYSTEMMODAL, "ip in shutdown  function",$ip)
;~ 	run("psexec.exe -accepteula \\"&$ip&" -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\shutdown.bat", @SW_HIDE)
	local $command1 = "psexec.exe -accepteula \\"&$ip&" -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\shutdown.bat"

	local $command2 = "psexec.exe -accepteula \\10.96.97.113 -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\shutdown.bat"
;~ 	MsgBox($MB_SYSTEMMODAL, "commands","command 1 mit var" & @CRLF & _
;~ 	$command1 & @CRLF & _
;~ 	"command 2 funktioniert ohne var:"& @CRLF & _
;~ 	$command2)
	run($command1)
;~ Consolewrite("psexec.exe -accepteula \\10.96.97.113 -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\shutdown.bat")


;~ 	Consolewrite("psexec.exe -accepteula \\"&$ip&" -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\shutdown.bat")
EndFunc
;~ run("psexec.exe -accepteula \\10.96.97.113 -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\logon.bat")


