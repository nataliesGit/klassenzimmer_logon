#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
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
#include <GUIConstants.au3>
#include <WinAPISys.au3>
#include <NetShare.au3>
#include <GuiComboBox.au3>


#Region ### START Koda GUI section ### Form=c:\_natalie_eigene\klassenraum_logon\data\guis_forms\classlogon.kxf
$Form2 = GUICreate("Scan", 565, 962, -1, -1)
GUISetBkColor(0xE3E3E3)

Local $idPic = GUICtrlCreatePic(@ScriptDir & "\data\guiElements\bg.jpg", 0, 0, 580, 1000)
GUICtrlSetState(-1, $GUI_DISABLE) ; If a picture is set as a background picture the other controls will overlap, so it is important to disable the pic control: GUICtrlSetState(-1, $GUI_DISABLE).

$labStatischClassroom = GUICtrlCreateLabel("  Klassenraum  ", 32, 64, 76, 17)
$Combo1 = GUICtrlCreateCombo("Auswahl", 112, 61, 81, 25,$CBS_DROPDOWNLIST + $WS_VSCROLL)

$butDB = GUICtrlCreateButton("Show DB", 32, 136, 91, 25)
$butResetDB = GUICtrlCreateButton("Reset DB", 32, 168, 91, 25)
$butResetVlan = GUICtrlCreateButton("Reset VLAN", 144, 136, 83, 25)

$butWol = GUICtrlCreateButton("WOL all", 240, 136, 91, 25)
$butShutdown = GUICtrlCreateButton("Shutdown all", 240, 168, 91, 25)
$butLogon = GUICtrlCreateButton("Log PCs on", 343, 136, 91, 25)
$butRemoveLogon = GUICtrlCreateButton("Remove Logon", 343, 168, 91, 25)

$butTest = GUICtrlCreateButton("Test", 446, 136, 91, 25)
$butLoggedOn = GUICtrlCreateButton("logged on?", 449, 168, 91, 25)

;~ GUICtrlSetColor(-1, 0x800000)
;~ GUICtrlSetBkColor(-1, 0xC0DCC0)
;~ $Button1 = GUICtrlCreateButton("W000000 |  000.000.000.000  | Status", 32, 223, 315, 17)
$butRefresh = GUICtrlCreateButton("butRefresh", 504, 216, 25, 22, $BS_BITMAP)
GUICtrlSetImage(-1, @ScriptDir & "\data\guiElements\reload1k.bmp", -1)
$butScan = GUICtrlCreateButton("Scan", 339, 61, 30, 20, $BS_BITMAP)
GUICtrlSetImage(-1, @ScriptDir & "\data\guiElements\scank.bmp", -1)
$labStatischVlan = GUICtrlCreateLabel("VLAN: ", 224, 64, 38, 17)
$labVlan = GUICtrlCreateLabel("00.00.00", 264, 64, 62, 17)
$labScanStatus = GUICtrlCreateLabel("scan status", 384, 64, 138, 17)
$labMyIP = GUICtrlCreateLabel("meine IP", 88, 16, 69, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$labStatischMyIP = GUICtrlCreateLabel("meine IP:", 40, 16, 48, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT) ;transparenter Hintergrund des Labels
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###



GUICtrlSetState($butScan, $GUI_HIDE)
;~ GUICtrlSetState($butRefresh, $GUI_HIDE)
GUICtrlSetState($labScanStatus, $GUI_HIDE)
;~ FileDelete(@ScriptDir & "\data\pingResults\*")

Global $idMenuPing,$idMenuWOL,$idMenuDeplayVNC,$idMenuConnectVNC
Global $butPressed

Global $lastPressed
Global $vlan
Global $agentRechner
Global $raeume[0]
Global $pc_in_chosenRoom[0]
Global $allButtons[100] ;bei zu geringer Anzahl (z.B nur 45 -l mehr wird nicht gebraucht - funktioniert Anzeige Button id im switch case nur bis Nr. 23 ???? warum auch immer)
Global $anzahlRechner = 0
;~ createLabels()
;~ HotKeySet ("{ESC}" ,"testhot" )


;~ _GUICtrlComboBox_SelectString($Combo2, '10.96.97')   ;~  vorausgewählter Wert in Dropdown
resetDB()
RaeumeVonDBEinlesen()
populateComboClassroom()

;~ $name=@ComputerName

;~ Vorauswahl des Klassenzimmers - während Entwicklung
 _GUICtrlComboBox_SelectString ($Combo1, "D403")
 roomChosen()


Global $myIP = _GetIP()
GUICtrlSetData($labMyIP,$myIP)


Func populateComboClassroom()
	$cData = ""
	For $i = 1 To Ubound($raeume)-1
		$cData &= "|" & $raeume[$i]
	Next
	GUICtrlSetData($Combo1, $cData)
	GUICtrlSendMsg($Combo1, $CB_SETMINVISIBLE, 15, 0)
EndFunc

Func RaeumeVonDBEinlesen()
	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
	Local $aResult, $iRows, $iColumns, $iRval
   _SQLite_Startup()
   If @error Then
	  MsgBox($MB_SYSTEMMODAL, "SQLite Error", "SQLite3.dll Can't be Loaded!")
	  Exit -1
   EndIf

   Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
   If @error Then
	  MsgBox($MB_SYSTEMMODAL, "SQLite Error", "Can't open or create a permanent Database!")
	  Exit -1
   EndIf
  ; Query
	$iRval = _SQLite_GetTable(-1, "select distinct Raum from raumpc order by Raum;", $aResult, $iRows, $iColumns)
	If $iRval = $SQLITE_OK Then
		; $aResult sieht so aus:
		; [0]    = 8
		; [1]    = field2
		; [2]    = D401
		; [3]    = F215
		; d.h. die eigentlichen Daten sind ab $aResult[2]  - [0] ist die Anzahl Datensätze, [1] ist der Spaltenname
;~ 		_ArrayDisplay($aResult, "Query Result")
	Else
		MsgBox($MB_SYSTEMMODAL, "SQLite Error: " & $iRval, _SQLite_ErrMsg())
	EndIf
	For $i = 2 To UBound($aResult) - 1
		_ArrayAdd($raeume,$aResult[$i])
   Next

	_SQLite_Close()
	_SQLite_Shutdown()
;~ 	_ArrayDisplay($raeume)
EndFunc


;~ func testhot()
;~ 	MsgBox($MB_SYSTEMMODAL, "test hotkey" ,"test hotkey")

;~ EndFunc

func todo() ;*************************************** labels mit farbe******************
	$aCInfo = GUIGetCursorInfo($Form2)
    If $aCInfo[4] = $allButtons[0] Then
        GUICtrlSetBkColor($allButtons[0], 0x00FF00)
    Else
        GUICtrlSetBkColor($allButtons[0], 0xFF0000)
    EndIf

	;************************* hotkey mit get cursor info für contextmenu

	;    mstsc /v:w402667 und 2x tab schicken öffnet remote desktop
EndFunc

func roomChosen()
;~ 	Opt("GUIOnEventMode", 1)
	removeButtons($anzahlRechner)
	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
	Local $aResult, $iRows, $iColumns, $iRval
   _SQLite_Startup()
     Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
	 local $room = GUICtrlRead($combo1)
   ; Query 1
	local $aRow
	_SQLite_QuerySingleRow(-1, "select vlan from raumpc where Raum = '" & $room & "';", $aRow) ; Select single row and single field !
	$vlan = $aRow[0]
	GUICtrlSetData($labVlan,$vlan)
   ; Query 2
;~ 	$iRval = _SQLite_GetTable(-1, "select Rechner,IP,Status from raumpc where Raum = 'F221'", $aResult, $iRows, $iColumns)
	$iRval = _SQLite_GetTable(-1, "select Rechner,IP,Status from raumpc where Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
	If $iRval = $SQLITE_OK Then
		; $aResult sieht so aus:
		; [0]    = 8
		; [1]    = field2
		; [2]    = D401
		; [3]    = F215
		; d.h. die eigentlichen Daten sind ab $aResult[2]  - [0] ist die Anzahl Datensätze, [1] ist der Spaltenname
;~ 		_ArrayDisplay($aResult, "Query Result")
		local $anzahlRows = $aResult[0] -3
		$anzahlRechner = $anzahlRows/3
;~ 		ReDim $allLables[$allLables[0] + $anzahlRechner]  ;die Größe des Arrays an die Anzahl der Rechner anpassen
		createButtons($anzahlRechner)
		local $resultPosition = 4
		local $topPix = 136
		For $i = 0 to $anzahlRechner -1
			$rechner = $aResult[$resultPosition]
			$resultPosition += 1
			$IP = $aResult[$resultPosition]
			$resultPosition += 1
			$status = $aResult[$resultPosition]
			$resultPosition += 1
			$buttonText = $rechner &"    |    "&$IP & "    |   "&$status
			_ArrayAdd($pc_in_chosenRoom, $rechner)
			GUICtrlSetData($allButtons[$i],$buttonText)
;~ 				Local $idLabelContext = GUICtrlCreateContextMenu($allButtons[$i])
;~ 				$idMenuAbout = GUICtrlCreateMenuItem(GUICtrlRead($allButtons[$i]), $idLabelContext)
;~ 			GUICtrlSetOnEvent($allLables[$i], "KontextmenueLabel") ; When right click label
		next
	Else
		MsgBox($MB_SYSTEMMODAL, "SQLite Error: " & $iRval, _SQLite_ErrMsg())
	EndIf


	_SQLite_Close()
	_SQLite_Shutdown()

;~ 	$aWin = _WinAPI_EnumChildWindows($Form2)  ; cool: eine Liste aller Controls im formular - benötigt #include <WinAPISys.au3>
;~ 	_ArrayDisplay($aWin)

	GUICtrlSetState($butScan, $GUI_Show)
;~ 	GUICtrlSetState($butRefresh, $GUI_Show)
	GUICtrlSetState($labScanStatus, $GUI_Show)
EndFunc


func createButtons($anzahl)
	local $topPix = 223
	local $ButtonText ="unbesetzt"
	For $i = 0 to $anzahl - 1
		$allButtons[$i] = GUICtrlCreateButton($ButtonText, 32,$topPix, 411, 17,$BS_LEFT) ;text ,32 left, 223 top, 411 width, 17 height)
		$topPix = $topPix +17
	next
;~ 	_ArrayDisplay($allButtons)
EndFunc

func removeButtons($anzahl)
	For $i = 0 to $anzahl -1
		GUICtrlDelete($allButtons[$i])
	next
EndFunc


func resetDB()
	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
   _SQLite_Startup()
    Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
    _SQLite_Exec($pcdb, "UPDATE raumpc SET IP = 'IP'")
	_SQLite_Exec($pcdb, "UPDATE raumpc SET Status = '-------'")
	_SQLite_Close()
	_SQLite_Shutdown()
endFunc

func resetVLAN()
	local $chosenVlan = GUICtrlRead($labVlan)
	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
   _SQLite_Startup()
    Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
;~ 	$iRval0 = _SQLite_GetTable(-1, "select IP from raumpc where IP not like 'IP' and VLAN = '" & $chosenVlan & "';", $aResult0, $iRows0, $iColumns0)
    _SQLite_Exec($pcdb, "UPDATE raumpc SET IP = 'IP' where VLAN = '" & $chosenVlan & "'")
	_SQLite_Exec($pcdb, "UPDATE raumpc SET Status = '-------' where VLAN = '" & $chosenVlan & "'")
	_SQLite_Close()
	_SQLite_Shutdown()
	MsgBox($MB_SYSTEMMODAL, "VLAN Reset","VLAN "& $chosenVlan & " zurückgesetzt")
endFunc


func vlanScannen()
	GUICtrlSetData($labScanStatus,"Scan läuft")
;~ 	MsgBox($MB_SYSTEMMODAL, "Vlan",$Vlan)
;~ 	For $i = 160 To 162
;~ 	For $i = 40 To 47
;~ 	For $i = 33 To 115
	For $i = 2 To 254
		$ip = $Vlan &$i
;~ 		MsgBox($MB_SYSTEMMODAL, "ip",$ip)
		run(@ScriptDir & "\data\ipVlans.exe"&" "&$ip)
		Sleep(30)
	Next
	GUICtrlSetData($labScanStatus,"Scan abgeschlossen")
EndFunc


func wolVorbereitung()   ;teste ob Ziel-VLAN identisch ist mit Rechner, von dem aus WOL aufgerufen wird. Falls nicht, Nutzung eines Agent-Rechners im Ziel-VLAN zur Ausführung von WOL
	local $myIP_Split = StringSplit ($myIP, ".")
	local $myVlan = $myIP_Split[1]&"."&$myIP_Split[2]&"."&$myIP_Split[3]&"."
;~ 	MsgBox($MB_SYSTEMMODAL, "","my Vlan "&$myVlan)
	local $chosenVlan = GUICtrlRead($labVlan)
;~ 	MsgBox($MB_SYSTEMMODAL, "","chosen Vlan "&$chosenVlan)
	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
	Local $aResult, $iRows, $iColumns, $iRval
	Local $aResult0, $iRows0, $iColumns0, $iRval0
   _SQLite_Startup()
	Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
	local $room = GUICtrlRead($Combo1)

	if Not($chosenVlan = $myVlan) then  ;suche ersten Rechner in DB, der online ist und als Wol Agent fungieren kann
;~ 		MsgBox($MB_SYSTEMMODAL, "Vlan test","Vlans ungleich")
			$iRval0 = _SQLite_GetTable(-1, "select IP from raumpc where IP not like 'IP' and Raum = '" & $room & "' and VLAN = '" & $chosenVlan & "';", $aResult0, $iRows0, $iColumns0)
;~ 			_ArrayDisplay($aResult0, "Query Result")
			If $iRval0 = $SQLITE_OK Then
				if UBound($aResult0)> 2 then
					$agentRechner = $aResult0[2]   ;funktioniert ploetzlich nicht mehr - test rechner im selben Raum
;~ 					$agentRechner = "10.86.5.62"  ;DSM Server
;~ 					MsgBox($MB_SYSTEMMODAL, "agent Rechner",$agentRechner)
;~ 					MsgBox($MB_SYSTEMMODAL, "result array laenge",UBound($aResult0))
					wolRechnerFremdesVLan($agentRechner)
				Else
;~ 	****************** UWE TO DO *********Lizenserver Verbindung zu allen VLANS *******************************
;~ 					MsgBox($MB_SYSTEMMODAL, "kein Online Rechner","derzeit kein Rechner im gewählten VLAN online - Lizenserver als Agent-Rechner")
					MsgBox($MB_SYSTEMMODAL, "kein Online Rechner","derzeit kein Rechner im gewählten VLAN online - sc029902 als Agent-Rechner")
;~ 					$agentRechner = "10.86.5.30"  ;Lizenserver
					$agentRechner = "10.86.5.62"  ;DSM Server
					wolRechnerFremdesVLan($agentRechner)
				EndIf

			EndIf
	Else
		wolRechnerGleichesVLan()
	EndIf

;~ 	MsgBox($MB_SYSTEMMODAL, "Raum ",$room)
	 ; Query Mac Adressen

EndFunc



func wolRechnerFremdesVLan($agent)
	local $chosenVlan = GUICtrlRead($labVlan)
	Global $wolUebergabeString = $chosenVlan&"255"

	if $chosenVlan = "10.96.97." Or $chosenVlan = "10.96.140." Then
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan client2020")
		$cedentials ="-u mschool-ad\n.scheuble_adm -p test12345"
	Else
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan VHD")
		$cedentials ="-u nimda -p m14EU-g"
	EndIf

	MsgBox($MB_SYSTEMMODAL, "agent Rechner",$agent)
	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
	Local $aResult, $iRows, $iColumns, $iRval
	Local $aResult0, $iRows0, $iColumns0, $iRval0
   _SQLite_Startup()
	Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
	local $room = GUICtrlRead($Combo1)
		$iRval = _SQLite_GetTable(-1, "select MAC from raumpc where Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
			If $iRval = $SQLITE_OK Then
				; $aResult sieht so aus:
				; [0]    = 8
				; [1]    = field2
				; [2]    = D401
				; [3]    = F215
				; d.h. die eigentlichen Daten sind ab $aResult[2]  - [0] ist die Anzahl Datensätze, [1] ist der Spaltenname
;~ 				_ArrayDisplay($aResult, "Query Result")
				local $anzahlRows = $aResult[0]
		;~ 		MsgBox($MB_SYSTEMMODAL, "",$anzahlRows)

				For $i = 2 to $anzahlRows
					local $mac = $aResult[$i]
;~ 					MsgBox($MB_SYSTEMMODAL, "Mac aus DB",$mac)
					local $macSplit = StringSplit ($mac, ":")
					local $macKorrigiert = $macSplit[1]&$macSplit[2]&$macSplit[3]&$macSplit[4]&$macSplit[5]&$macSplit[6]
;~ 					MsgBox($MB_SYSTEMMODAL, "Mac ohne :",$macKorrigiert)
					$wolUebergabeString = $wolUebergabeString & " " & $macKorrigiert
				next
			Else
				MsgBox($MB_SYSTEMMODAL, "SQLite Error: " & $iRval, _SQLite_ErrMsg())
			EndIf
			MsgBox($MB_SYSTEMMODAL, "$wolUebergabeString",$wolUebergabeString)
			MsgBox($MB_SYSTEMMODAL, "","Wol FremdVlan Prozess gestartet")
;~ 			run(@ScriptDir & "\data\wolFremdVLAN.exe"&" "&$wolUebergabeString)
			run("psexec.exe -accepteula \\"&$agent&" "&$cedentials&"  -s -f -c "&@ScriptDir & "\data\wolFremdVLAN.exe"&" "&$wolUebergabeString)
;~ 			run("psexec.exe -accepteula \\"&$agent&" "&$cedentials&"  -s -f -c "&@ScriptDir & "\data\test.bat")  ;funktioniert
	_SQLite_Close()
	_SQLite_Shutdown()
EndFunc


;~ 			run("psexec.exe -accepteula \\10.96.97.113 -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\logon.bat")
;~ 			run("psexec.exe -accepteula \\"&$agent&" "&$cedentials&"  -s -f -c "&@ScriptDir & "\logon.bat")
;~ 			MsgBox($MB_SYSTEMMODAL, "psexec Befehl","psexec.exe -accepteula \\"&$agent&" "&$cedentials&"  -s -f -c "&@ScriptDir & "\logon.bat")
;~ 			psexec -u nimda -p m14EU-g \\w4026894 -s -f -c xy.bat
;~ 			run(@ScriptDir & "\data\wolRechner.exe"&" "&$macKorrigiert&" "&$chosenVlan&"255")


func wolRechnerGleichesVLan()
	local $chosenVlan = GUICtrlRead($labVlan)
	Global $wolUebergabeString = $chosenVlan&"255"
;~ 	MsgBox($MB_SYSTEMMODAL,"wolUebergabestring mit chosenVlan",$wolUebergabeString)
;~ 	MsgBox($MB_SYSTEMMODAL, "","chosen Vlan "&$chosenVlan)
	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
	Local $aResult, $iRows, $iColumns, $iRval
	Local $aResult0, $iRows0, $iColumns0, $iRval0
   _SQLite_Startup()
	Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
	local $room = GUICtrlRead($Combo1)
		$iRval = _SQLite_GetTable(-1, "select MAC from raumpc where Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
			If $iRval = $SQLITE_OK Then
				; $aResult sieht so aus:
				; [0]    = 8
				; [1]    = field2
				; [2]    = D401
				; [3]    = F215
				; d.h. die eigentlichen Daten sind ab $aResult[2]  - [0] ist die Anzahl Datensätze, [1] ist der Spaltenname
;~ 				_ArrayDisplay($aResult, "Query Result")
				local $anzahlRows = $aResult[0]
		;~ 		MsgBox($MB_SYSTEMMODAL, "",$anzahlRows)

				For $i = 2 to $anzahlRows
					local $mac = $aResult[$i]
;~ 					MsgBox($MB_SYSTEMMODAL, "Mac aus DB",$mac)
					local $macSplit = StringSplit ($mac, ":")
					local $macKorrigiert = $macSplit[1]&$macSplit[2]&$macSplit[3]&$macSplit[4]&$macSplit[5]&$macSplit[6]
;~ 					MsgBox($MB_SYSTEMMODAL, "Mac ohne :",$macKorrigiert)
					$wolUebergabeString = $wolUebergabeString & " " & $macKorrigiert
				next
			Else
				MsgBox($MB_SYSTEMMODAL, "SQLite Error: " & $iRval, _SQLite_ErrMsg())
			EndIf
;~ 			MsgBox($MB_SYSTEMMODAL, "$wolUebergabeString",$wolUebergabeString)
			MsgBox($MB_SYSTEMMODAL, "","Wol Prozess gestartet")
			run(@ScriptDir & "\data\wolRechner.exe"&" "&$wolUebergabeString)

	_SQLite_Close()
	_SQLite_Shutdown()
EndFunc

;~ $iRval = _SQLite_GetTable(-1, "select MAC from raumpc where Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
;~ local $room = GUICtrlRead($Combo1)
;~ $iRval0 = _SQLite_GetTable(-1, "select IP from raumpc where IP not like 'IP' and VLAN = '" & $chosenVlan & "';", $aResult0, $iRows0, $iColumns0)

func shutdownRechner()
	local $chosenVlan = GUICtrlRead($labVlan)

	if $chosenVlan = "10.96.97." Or $chosenVlan = "10.96.140." Then
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan client2020")
		$cedentials ="-u mschool-ad\n.scheuble_adm -p test12345"
	Else
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan VHD")
		$cedentials ="-u nimda -p m14EU-g"
	EndIf

	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
	Local $aResult, $iRows, $iColumns, $iRval
	 _SQLite_Startup()
	 Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
	 local $room = GUICtrlRead($combo1)
   ; Query
	$iRval = _SQLite_GetTable(-1, "select IP from raumpc where IP not like 'IP' and Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
	If $iRval = $SQLITE_OK Then
;~ 		_ArrayDisplay($aResult, "Query Result")
		For $i = 2 to $aResult[0]
			local $ipPC = $aResult[$i]
;~ 			MsgBox($MB_SYSTEMMODAL, "",$ipPC)
			run("psexec.exe -accepteula \\"&$ipPC&" "&$cedentials&"  -s -f -c "&@ScriptDir & "\data\shutdown.bat")
			sleep(100)  ;wird nicht ganz zuverlässig ausgeführt

		next
	Else
		MsgBox($MB_SYSTEMMODAL, "SQLite Error: " & $iRval, _SQLite_ErrMsg())
	EndIf

	_SQLite_Close()
	_SQLite_Shutdown()
	MsgBox($MB_SYSTEMMODAL, "","Shutdowns ausgeführt")
EndFunc

func removeLogonRechner()
	local $chosenVlan = GUICtrlRead($labVlan)
	if $chosenVlan = "10.96.97." Or $chosenVlan = "10.96.140." Then
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan client2020")
		$cedentials ="-u mschool-ad\n.scheuble_adm -p test12345"
	Else
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan VHD")
		$cedentials ="-u nimda -p m14EU-g"
	EndIf
	$removeLogonBat = @ScriptDir & "\data\removeLogon.bat"

	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
	Local $aResult, $iRows, $iColumns, $iRval
	 _SQLite_Startup()
	 Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
	 local $room = GUICtrlRead($combo1)
   ; Query
	$iRval = _SQLite_GetTable(-1, "select IP from raumpc where IP not like 'IP' and Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
	If $iRval = $SQLITE_OK Then
;~ 		_ArrayDisplay($aResult, "Query Result")
		For $i = 2 to $aResult[0]
			local $ipPC = $aResult[$i]
;~ 			MsgBox($MB_SYSTEMMODAL, "",$ipPC)
;~ 			run(@ScriptDir & "\data\logon.exe"&" "&$ipPC)
			run("psexec.exe -accepteula \\"&$ipPC&" "&$cedentials&"  -s -f -c "&$removeLogonBat)
			sleep(50)
		next
	Else
		MsgBox($MB_SYSTEMMODAL, "SQLite Error: " & $iRval, _SQLite_ErrMsg())
	EndIf

	_SQLite_Close()
	_SQLite_Shutdown()
	MsgBox($MB_SYSTEMMODAL, "","Logon aus Registry entfernt")
EndFunc

func logonRechner()
	local $chosenVlan = GUICtrlRead($labVlan)
	if $chosenVlan = "10.96.97." Or $chosenVlan = "10.96.140." Then
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan client2020")
		$cedentials ="-u mschool-ad\n.scheuble_adm -p test12345"
		$logonBat = @ScriptDir & "\data\logon.bat"
	Else
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan VHD")
		$cedentials ="-u nimda -p m14EU-g"
		$logonBat = @ScriptDir & "\data\logonVHD.bat"
	EndIf


	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
	Local $aResult, $iRows, $iColumns, $iRval
	 _SQLite_Startup()
	 Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
	 local $room = GUICtrlRead($combo1)
   ; Query
	$iRval = _SQLite_GetTable(-1, "select IP from raumpc where IP not like 'IP' and Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
	If $iRval = $SQLITE_OK Then
;~ 		_ArrayDisplay($aResult, "Query Result")
		For $i = 2 to $aResult[0]
			local $ipPC = $aResult[$i]
;~ 			MsgBox($MB_SYSTEMMODAL, "",$ipPC)
;~ 			run(@ScriptDir & "\data\logon.exe"&" "&$ipPC)
			run("psexec.exe -accepteula \\"&$ipPC&" "&$cedentials&"  -s -f -c "&$logonBat)
			sleep(50)
		next
	Else
		MsgBox($MB_SYSTEMMODAL, "SQLite Error: " & $iRval, _SQLite_ErrMsg())
	EndIf

	_SQLite_Close()
	_SQLite_Shutdown()
	MsgBox($MB_SYSTEMMODAL, "","Logons in Registry geschrieben")
EndFunc

func whoIsLoggedOn()
	#RequireAdmin
	$autoitShare = "C:\tempAutoit\"
	if FileExists($autoitShare) Then
		FileDelete($autoitShare&"\*.txt")
	EndIf

 	run(@ScriptDir & "\data\createShare.bat")
	sleep(50)
;~ 	MsgBox($MB_SYSTEMMODAL, "INFO","share erstellt")
	local $chosenVlan = GUICtrlRead($labVlan)
	if $chosenVlan = "10.96.97." Or $chosenVlan = "10.96.140." Then
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan client2020")
		$cedentials ="-u mschool-ad\n.scheuble_adm -p test12345"
	Else
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan VHD")
		$cedentials ="-u nimda -p m14EU-g"
	EndIf
	$queryUser = @ScriptDir & "\data\queryUser.bat"
	_ReplaceStringInFile($queryUser,"localhost",$myIP)
;~ 	zeigeBatch()

	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
	Local $aResult, $iRows, $iColumns, $iRval
	 _SQLite_Startup()
	 Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
	 local $room = GUICtrlRead($combo1)
   ; Query
	$iRval = _SQLite_GetTable(-1, "select IP from raumpc where IP not like 'IP' and Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
	If $iRval = $SQLITE_OK Then
;~ 		_ArrayDisplay($aResult, "Query Result")
		For $i = 2 to $aResult[0]
			local $ipPC = $aResult[$i]
			run("psexec.exe -accepteula \\"&$ipPC&" "&$cedentials&"  -s -f -c "&$queryUser)
			sleep(2000)
		next
	Else
		MsgBox($MB_SYSTEMMODAL, "SQLite Error: " & $iRval, _SQLite_ErrMsg())
	EndIf

	_SQLite_Close()
	_SQLite_Shutdown()

	_ReplaceStringInFile($queryUser,$myIP,"localhost")
	sleep(4000)
	AuswertungShare()

EndFunc

func AuswertungShare()
	$autoitShare = "C:\tempAutoit\"
;~ 	MsgBox(0, "i", "schau ob tempAutoit da ist " & $autoitShare)
	$fileSize = DirGetSize($autoitShare, 1)
	If Not @error Then
		If Not $fileSize[1] And Not $fileSize[2] Then
			MsgBox(0,"i","keine Auswertungsdaten vorhanden")
		Else
;~ 			MsgBox(0, "i", "Not empty: " &$autoitShare)
			local $fileList = _FileListToArray ($autoitShare,"*")
		;~ 	_ArrayDisplay($fileList, "Query Result")
			local $chosenVlan = GUICtrlRead($labVlan)
				For $i = 1 to $fileList[0]
					 Local $file = $autoitShare&$fileList[$i]

					 $string = $fileList[$i]
					 $array = StringSplit($string, ".")
					 Global $ipInFilename = $array[1]&"."&$array[2]&"."&$array[3]&"."&$array[4]

		;~ 			 MsgBox($MB_SYSTEMMODAL, "ip in filename",$ipInFilename)
					 Local $hFileOpen = FileOpen($file, $FO_READ)
					 Local $sFileReadUser = FileReadLine($hFileOpen, 2)
		;~ 			 Local $sFileReadComputer = FileReadLine($hFileOpen, 3)
					 FileClose($hFileOpen)
		;~ 			 MsgBox($MB_SYSTEMMODAL, "file content",$sFileReadUser&" auf "&$sFileReadComputer)
					 if StringInStr( $sFileReadUser, "console") then
		;~ 				 MsgBox($MB_SYSTEMMODAL, "Anmeldung","lehrer ist angemeldet")
						Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
						Local $aResult, $iRows, $iColumns, $iRval
						_SQLite_Startup()
						Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
						local $room = GUICtrlRead($combo1)
						If $iRval = $SQLITE_OK Then
							_SQLite_Exec(-1, "Update raumpc SET Status = 'Anmeldung ok' where IP = '"& $ipInFilename &"';")
						Else
							MsgBox($MB_SYSTEMMODAL, "SQLite Error: " & $iRval, _SQLite_ErrMsg())
						EndIf

						_SQLite_Close()
						_SQLite_Shutdown()
					EndIf

				Next
		roomChosen()

		EndIf
	Else
		MsgBox(0, "i", "Does not exist: " & $autoitShare)
	EndIf

EndFunc





While 1  ;Case Buttons
        Global $iMsg = GUIGetMsg()
        Switch $iMsg
		Case $GUI_EVENT_CLOSE
			#RequireAdmin
			$autoitShare = "C:\tempAutoit\"
			if FileExists($autoitShare) Then
				run(@ScriptDir & "\data\deleteShare.bat")
			EndIf
			Exit

        Case $allButtons[0] To UBound($allButtons) - 1   ;COOOOOOOOOOOOOOOOOOOOOOL  *************************************************
                Global $iIndex = $iMsg - $allButtons[0]
;~                 ConsoleWrite($iIndex & @CRLF)
				local $chosenVlan = GUICtrlRead($labVlan)
				$butPressed = GUICtrlRead($allButtons[$iIndex])
;~ 				MsgBox($MB_SYSTEMMODAL, "inhalt button",$butPressed)
				$butPressed = StringMid ($butPressed,1,8)
;~ 				MsgBox($MB_SYSTEMMODAL, "button nur wnummer",$butPressed)
				run(@ScriptDir & "\data\kontext.exe"&" "&$butPressed&" "&$chosenVlan)

		Case $Combo1
;~ 			$Label5 = GUICtrlCreateLabel("W000000,901b0e657812,000.000.000.000,Status des Rechners", 32, 136, 312, 17) text - left - top width height
;~ 			$Label6 = GUICtrlCreateLabel("W000000,901b0e657812,000.000.000.000,Status des Rechners", 32, 159, 312, 17)
			roomChosen()
		Case $butResetDB
			resetDB()
		Case $butResetVlan
			resetVLAN()
		Case $butDB
			Run (@ScriptDir & "\data\anzeigeDB.exe")
		Case $butWol
			wolVorbereitung()
		Case $butShutdown
			shutdownRechner()
		Case $butLogon
			logonRechner()
		Case $butRemoveLogon
			removeLogonRechner()
		Case $butRefresh
			roomChosen()
		Case $butScan
;~ 			resetDB()
			vlanScannen()
			roomChosen()
		Case $butLoggedOn
			whoIsLoggedOn()


		Case $butTest

;~ 			test_mapShare()
;~ 			test_removeShare()

;~ 			run(@ScriptDir & "\data\wolRechner.exe")
;~ 			labelsInvisible()
;~ 			removeButtons($anzahlRechner)

	EndSwitch
WEnd

;~ **************************************** not needed here *********************



;~ func createLabels($anzahl)
;~ 	local $topPix = 223
;~ 	local $labelText ="w000000 | 000.000.000  | status"
;~ 	For $i = 0 to $anzahl - 1
;~ 		$allLables[$i] = GUICtrlCreateLabel($labelText, 32,$topPix, 312, 17) ;text ,32 left, 223 top, 312 width, 17 height)
;~ 		$topPix = $topPix +15
;~ 	next
;~ EndFunc

;~ Func createKontextMenu($buttonID)

;~     Local $idContextmenu = GUICtrlCreateContextMenu()
;~     $idMenuPing = GUICtrlCreateMenuItem("Ping", $idContextmenu)
;~     $idMenuWOL = GUICtrlCreateMenuItem("WOL", $idContextmenu)
;~     GUICtrlCreateMenuItem("", $idContextmenu) ; separator

;~     $idMenuDeplayVNC = GUICtrlCreateMenuItem("deplay VNC", $idContextmenu)
;~ 	$idMenuConnectVNC = GUICtrlCreateMenuItem("connect VNC", $idContextmenu)
;~ 	$idButtoncontext = GUICtrlCreateContextMenu($buttonID)

;~ EndFunc

;~ func labelsInvisible()
;~ 	For $i = 0 to 20
;~ 		GUICtrlSetState($allLables[$i],$GUI_HIDE)
;~ 	next
;~ EndFunc

;~ func removeLabels($anzahl)
;~ 	For $i = 0 to $anzahl -1
;~ 		GUICtrlDelete($allLables[$i])
;~ 	next
;~ EndFunc


;~ Func zeigeBatch()
;~ 	$_Run = "notepad.exe " & "data\queryUser.bat"
;~ 	ConsoleWrite ( "$_Run : " & $_Run & @Crlf )   zu testzwecken
;~ 	Run ( $_Run, @ScriptDir, @SW_SHOWDEFAULT )
;~ EndFunc


;~ func test_mapShare()
;~ 	$mapShare = @ScriptDir & "\data\mapShare.exe"
;~ 	local $chosenVlan = GUICtrlRead($labVlan)
;~ 	if $chosenVlan = "10.96.97." Or $chosenVlan = "10.96.140." Then
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan client2020")
;~ 		$cedentials ="-u mschool-ad\n.scheuble_adm -p test12345"
;~ 	Else
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan VHD")
;~ 		$cedentials ="-u nimda -p m14EU-g"
;~ 	EndIf
;~ 	local $ipPC = "10.96.21.33"

;~ 	run("psexec.exe -accepteula \\"&$ipPC&" "&$cedentials&"  -s -f -c "&$mapShare)

;~ EndFunc

;~ func test_removeShare()
;~ 	$removeShare = @ScriptDir & "\data\removeShare.exe"
;~ 	local $chosenVlan = GUICtrlRead($labVlan)
;~ 	if $chosenVlan = "10.96.97." Or $chosenVlan = "10.96.140." Then
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan client2020")
;~ 		$cedentials ="-u mschool-ad\n.scheuble_adm -p test12345"
;~ 	Else
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan VHD")
;~ 		$cedentials ="-u nimda -p m14EU-g"
;~ 	EndIf
;~ 	local $ipPC = "10.96.21.33"

;~ 	run("psexec.exe -accepteula \\"&$ipPC&" "&$cedentials&"  -s -f -c "&$removeShare)

;~ EndFunc


