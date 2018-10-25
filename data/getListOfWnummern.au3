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

#Region ### START Koda GUI section ### Form=C:\_natalie_eigene\Klassenraum_Logon\data\guis_forms\pingVlans.kxf
$Form1 = GUICreate("scan", 249, 102, 258, 124)
$Button1 = GUICtrlCreateButton("ping all VLANs", 48, 48, 115, 25)
$Label1 = GUICtrlCreateLabel("Scanning VLAN: ", 48, 16, 86, 17)
$labVLAN = GUICtrlCreateLabel("000.000.000", 136, 16, 64, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global $ergebnis = ""

if FileExists(@ScriptDir & "\ScanErgebnis.txt") Then
	FileDelete (@ScriptDir & "\ScanErgebnis.txt")
EndIf

TCPStartup()

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			TCPShutdown()
			Exit
		case $Button1
			scanVlan("10.96.140.")
;~ 			MsgBox($MB_SYSTEMMODAL, "Kontrolle Ende scan","Kontrolle Ende scan")
			Local $sFilePath = @ScriptDir & "\ScanErgebnis.txt"
			Local $hFileOpen = FileOpen($sFilePath, $FO_APPEND)
			FileWrite($hFileOpen, $ergebnis)
			FileClose($hFileOpen)

			$_Run = "notepad.exe " & "ScanErgebnis.txt"
			Run ( $_Run, @ScriptDir, @SW_SHOWDEFAULT )
	EndSwitch
WEnd

;~ 10.96.19.
;~ 10.96.20.
;~ 10.96.21.

;~ 10.96.97.
;~ 10.96.140.



func scanVlan($vlan)
	GUICtrlSetData($labVLAN,$vlan)

	ProgressOn("scanne VLAN: "&$vlan, "")
	$ProzentSchritte = 100 / 250
	$ProzentFortschritt = $ProzentSchritte
	for $i = 5 to 254
		ProgressSet ($ProzentFortschritt,Round($ProzentFortschritt) & "%")
		$ip = $vlan&$i
;~ 		MsgBox($MB_SYSTEMMODAL, "Kontrolle ip",$ip)

		$iPing1 = Ping($ip)
		$iPing2 = Ping($ip)

		if $iPing1 = 1 or $iPing2 = 1 then
			$Wnummer = StringLeft ( _TCPIpToName ($ip),8)
			$Wnummer =_StringTitleCase ( $Wnummer )
;~ 			MsgBox($MB_SYSTEMMODAL, "",$Wnummer)
			$ergebnis = $ergebnis & " "&$ip& " " &$Wnummer&@CRLF
		EndIf
	$ProzentFortschritt = $ProzentFortschritt + $ProzentSchritte
	Next
	ProgressSet(100, "Ende VLAN:", $vlan)
	ProgressOff()

EndFunc

