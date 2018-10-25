#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ico\light3.ico
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

;~ https://www.autoitscript.com/forum/topic/29772-copyright-free-wake-on-lan-script/
;~ Global $IPAddress = "10.96.97.255"; This is the broadcast address !
;~ uebergeben wird  "10.96.97.255 7b1b0e657812 901b0e6333812 901b0e657912" etc.
Global $MACAddress
Global $broadcast


If $CmdLine[0] Then
;~ 	For $i = 1 To $CmdLine[0]
;~ 		MsgBox(64, "Passed Parameters", "Parameter " & $i & ": " & $CmdLine[$i])
;~ 	Next
	$broadcast = $CmdLine[1]
	UDPStartUp()
	$connexion = UDPOpen($broadcast, 7)

	for $i = 2 to $CmdLine[0]
		$MACAddress = $CmdLine[$i]
		$res = UDPSend($connexion, GenerateMagicPacket($MACAddress))
		sleep(500)
;~ 		MsgBox($MB_SYSTEMMODAL, "wol für Mac: ",$MACAddress)
	Next
	UDPCloseSocket($connexion)
	UDPShutdown()
;~ 	MsgBox($MB_SYSTEMMODAL, "Wol ausgeführt","WOL ausgeführt für "&($CmdLine[0]-1)&" Rechner")
Else
	$broadcast = "10.96.97.255"
	Global $MACAddress = "901b0e657812"  ;~ zu Testzwecken Raum D401 Rechner w4047754
;~ 	MsgBox($MB_SYSTEMMODAL, "",$MACAddress)

	UDPStartUp()
	$connexion = UDPOpen($broadcast, 7)
	$res = UDPSend($connexion, GenerateMagicPacket($MACAddress))
	;~ MsgBox(0, "", $res)

	UDPCloseSocket($connexion)
	UDPShutdown()

EndIf



; ===================================================================
; Functions
; ===================================================================

; This function convert a MAC Address Byte (e.g. "1f") to a char
Func HexToChar($strHex)

    Return Chr(Dec($strHex))

EndFunc

; This function generate the "Magic Packet"
Func GenerateMagicPacket($strMACAddress)

    $MagicPacket = ""
    $MACData = ""

    For $p = 1 To 11 Step 2
        $MACData = $MACData & HexToChar(StringMid($strMACAddress, $p, 2))
    Next

    For $p = 1 To 6
        $MagicPacket = HexToChar("ff") & $MagicPacket
    Next

    For $p = 1 To 16
        $MagicPacket = $MagicPacket & $MACData
    Next

    Return $MagicPacket

EndFunc