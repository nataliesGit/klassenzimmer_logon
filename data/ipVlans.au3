#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ico\ip.ico
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
#include <String.au3>

;~ MsgBox($MB_SYSTEMMODAL, "", "ipVlans aufgerufen")

;~ If $CmdLine[0] Then
;~ 	For $i = 1 To $CmdLine[0]
;~ 		MsgBox(64, "Passed Parameters", "Parameter " & $i & ": " & $CmdLine[$i])
;~ 	Next
;~ EndIf
Global $Wnummer
Global $ip
Global $iPing

If $CmdLine[0] Then
	$ip = $CmdLine[1]
;~ _ArrayDisplay($CmdLine)
	TCPStartup()


	$iPing = Ping($ip)
;~ 	MsgBox($MB_SYSTEMMODAL, "ip",$ip)
;~ 	MsgBox($MB_SYSTEMMODAL, "ping erfolgreich? ",$iPing)

	if $iPing = 1 then
		$Wnummer = StringLeft ( _TCPIpToName ($ip),8)
		$Wnummer =_StringTitleCase ( $Wnummer )
;~ 		MsgBox($MB_SYSTEMMODAL, "",$Wnummer)
		insertIPs()
	EndIf
	TCPShutdown()
EndIf

func insertIPs()
	Local $Database = @ScriptDir & "\raumpc.db"
	_SQLite_Startup()
	If @error Then
		MsgBox($MB_SYSTEMMODAL, "SQLite Error", "SQLite3.dll Can't be Loaded!")
		Exit -1
	EndIf

	Local $pcdb = _SQLite_Open($Database) ;wenn nicht existent, wird db erstellt
	If @error Then
		MsgBox($MB_SYSTEMMODAL, "SQLite Error", "Can't open or create a permanent Database!")
		Exit -1
	EndIf

   ;Insert
;~    MsgBox($MB_SYSTEMMODAL, "",$Wnummer)
;~    MsgBox($MB_SYSTEMMODAL, "",$ip)
	_SQLite_Exec(-1, "Update raumpc SET IP = '" & $ip & "' where Upper(Rechner) = Upper('"&$Wnummer&"');")
;~ 	_SQLite_Exec(-1, "Update raumpc SET Status = 'ON' where Rechner = '"&$Wnummer&"';")

	_SQLite_Close()
	_SQLite_Shutdown()
EndFunc

;~ func insertIPs()
;~ 	MsgBox($MB_SYSTEMMODAL, "in insertIPs",$iPing)
;~ 	local $status ="ON"
;~ 	MsgBox($MB_SYSTEMMODAL, "@ScriptDir",@ScriptDir)
;~ 	Local $Database = @ScriptDir & "\raumpc.db"
;~ 	_SQLite_Startup()
;~ 	If @error Then
;~ 		MsgBox($MB_SYSTEMMODAL, "SQLite Error", "SQLite3.dll Can't be Loaded!")
;~ 		Exit -1
;~ 	EndIf

;~ 	Local $pcdb = _SQLite_Open($Database) ;wenn nicht existent, wird db erstellt
;~ 	If @error Then
;~ 		MsgBox($MB_SYSTEMMODAL, "SQLite Error", "Can't open or create a permanent Database!")
;~ 		Exit -1
;~ 	EndIf

;~    ;Insert
;~    MsgBox($MB_SYSTEMMODAL, "",$Wnummer)
;~    MsgBox($MB_SYSTEMMODAL, "",$ip)
;~ 	_SQLite_Exec(-1, "Update raumpc SET IP = '" & $ip & "' where upper(Rechner) = '"&$Wnummer&"';")
;~ 	_SQLite_Exec(-1, "Update raumpc SET Status = '" & $status & "' where upper(Rechner) = '"&$Wnummer&"';")
;~ 	_SQLite_Exec(-1, "Update raumpc SET IP = '10.20.30' where Rechner = 'w4047754';")

;~ 	_SQLite_Close()
;~ 	_SQLite_Shutdown()
;~ EndFunc