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
$labBatchChosen = GUICtrlCreateLabel(" keine Datei ausgewählt", 64, 872, 246, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$butChooseBatch = GUICtrlCreateButton(" .... ", 32, 864, 27, 25)
$butExec1 = GUICtrlCreateButton("Execute Batch", 320, 864, 131, 25)
$comboApp = GUICtrlCreateCombo("", 32, 905, 281, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$butExec2 = GUICtrlCreateButton("start App/ exec Batch", 320, 903, 131, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

GUICtrlSetData($comboApp,"clt2020_word")
GUICtrlSetData($comboApp,"clt2020_autocad")
GUICtrlSetData($comboApp,"clt2020_Photoshop2017")
GUICtrlSetData($comboApp,"clt2020_Photoshop_CS5")
GUICtrlSetData($comboApp,"clt2020_illlustrator2017")
GUICtrlSetData($comboApp,"clt2020_illlustrator_CS5")
GUICtrlSetData($comboApp,"clt2020_CorelDraw_X7")

GUICtrlSetData($comboApp,"VHD_copyAllplanFolder")

GUICtrlSetState($butScan, $GUI_HIDE)
GUICtrlSetState($labScanStatus, $GUI_HIDE)


Global $queryUser
Global $butPressed
Global $myIP
Global $lastPressed
Global $vlan
Global $agentRechner
Global $raeume[0]
Global $pc_in_chosenRoom[0]
Global $allButtons[100] ;bei zu geringer Anzahl (z.B nur 45 -l mehr wird nicht gebraucht - funktioniert Anzeige Button id im switch case nur bis Nr. 23 ???? warum auch immer)
Global $anzahlRechner = 0
Global $selectedBatch
Global $cedentials



;~ resetDB()
RaeumeVonDBEinlesen()
populateComboClassroom()
eigeneIPauslesen()

;~ Vorauswahl des Klassenzimmers - während Entwicklung
 _GUICtrlComboBox_SelectString ($Combo1, "D401")
roomChosen()
$queryUser = @ScriptDir & "\data\queryUser.bat"
_ReplaceStringInFile($queryUser,"localhost",$myIP)


func eigeneIPauslesen()
	;~ Global $myIP = _GetIP()  ;dauert ewig
	$DOS = Run(@ComSpec & ' /c ipconfig | find "IPv4"', "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	ProcessWaitClose($DOS)
	$Message = StdoutRead($DOS)
	;~ MsgBox($MB_SYSTEMMODAL, "cmd output", $Message)
	local $temp = StringSplit($Message,":")
	$myIP=$temp[2]
	$myIP = StringStripWS($myIP, $STR_STRIPLEADING + $STR_STRIPTRAILING)
	GUICtrlSetData($labMyIP,$myIP)
EndFunc

Func populateComboClassroom()
	$cData = ""
	For $i = 1 To Ubound($raeume)-1
		$cData &= "|" & $raeume[$i]
	Next
	GUICtrlSetData($Combo1, $cData)
	GUICtrlSendMsg($Combo1, $CB_SETMINVISIBLE, 15, 0)
EndFunc

Func RaeumeVonDBEinlesen()
	$aResult = databaseQuery("2")
	For $i = 2 To UBound($aResult) - 1
		_ArrayAdd($raeume,$aResult[$i])
   Next
EndFunc

func roomChosen()
	removeButtons($anzahlRechner)
	$aRow = databaseQuery("4")

	$vlan = $aRow[0]
	GUICtrlSetData($labVlan,$vlan)

	$aResult = databaseQuery("3")

	local $anzahlRows = $aResult[0] -3
	$anzahlRechner = $anzahlRows/3

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
	next
	GUICtrlSetState($butScan, $GUI_Show)

	GUICtrlSetState($labScanStatus, $GUI_Show)
	$autoitShare = "C:\tempAutoit\"
	if FileExists($autoitShare) Then
		FileDelete($autoitShare&"\*.txt")
	EndIf
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
;~ 	For $i = 184 To 185
	For $i = 2 To 254
		$ip = $Vlan &$i
;~ 		MsgBox($MB_SYSTEMMODAL, "ip",$ip)
		run(@ScriptDir & "\data\ipVlans.exe"&" "&$ip)
		Sleep(30)
	Next
	GUICtrlSetData($labScanStatus,"Scan abgeschlossen")
EndFunc



func wolRechnerGleichesVLan()
	local $myIpSplit = StringSplit ($myIP, ".")
	local $myVLAN = $myIpSplit[1]&"."&$myIpSplit[2]&"."&$myIpSplit[3]&"."
	local $chosenVlan = GUICtrlRead($labVlan)
;~ 	MsgBox($MB_SYSTEMMODAL,"Kontrolle chosen vlan",$chosenVlan)
;~ 	MsgBox($MB_SYSTEMMODAL,"Kontrolle my vlan",$myVLAN)
	if $myVLAN = $chosenVlan then
		Global $wolUebergabeString = $chosenVlan&"255"
	;~ 	MsgBox($MB_SYSTEMMODAL,"wolUebergabestring mit chosenVlan",$wolUebergabeString)
	;~ 	MsgBox($MB_SYSTEMMODAL, "","chosen Vlan "&$chosenVlan)

		$aResult = databaseQuery("5")
		local $anzahlRows = $aResult[0]
		For $i = 2 to $anzahlRows
			local $mac = $aResult[$i]
	;~ 		MsgBox($MB_SYSTEMMODAL, "Mac aus DB",$mac)
			local $macSplit = StringSplit ($mac, ":")
			local $macKorrigiert = $macSplit[1]&$macSplit[2]&$macSplit[3]&$macSplit[4]&$macSplit[5]&$macSplit[6]
	;~ 		MsgBox($MB_SYSTEMMODAL, "Mac ohne :",$macKorrigiert)
			$wolUebergabeString = $wolUebergabeString & " " & $macKorrigiert
		next

		MsgBox($MB_SYSTEMMODAL, "","Wol Prozess gestartet")
		MsgBox($MB_SYSTEMMODAL, "Uebergabestring",$wolUebergabeString)
;~ 		run(@ScriptDir & "\data\wolRechner.exe"&" "&$wolUebergabeString)
	Else
		MsgBox($MB_SYSTEMMODAL, "WOL","WOL ist nur möglich, wenn sich die Zielrechner im selben VLAN wie diese Applikation befinden")
	EndIf

EndFunc

func shutdownRechner()
	setCredentials()
	$aResult = databaseQuery("1")
	_ArrayDisplay($aResult, "Query Result")
		For $i = 2 to $aResult[0]
			local $ipPC = $aResult[$i]
			MsgBox($MB_SYSTEMMODAL, "ipPC: myIP ",$ipPC&" "&$myIP)
			if NOT $ipPC = $myIP Then
				run("psexec.exe -accepteula \\"&$ipPC&" "&$cedentials&"  -s -f -c "&@ScriptDir & "\data\shutdown.bat")
			EndIf

			sleep(100)  ;wird nicht ganz zuverlässig ausgeführt

		next

	MsgBox($MB_SYSTEMMODAL, "","Shutdowns ausgeführt")
EndFunc

func setCredentials()
	local $chosenVlan = GUICtrlRead($labVlan)
	if $chosenVlan = "10.96.97." Or $chosenVlan = "10.96.140." Then
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan client2020")
		$cedentials ="-u mschool-ad\n.scheuble_adm -p test12345"
	Else
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan VHD")
		$cedentials ="-u nimda -p m14EU-g"
	EndIf
EndFunc





func removeLogonRechner()
	setCredentials()
	$removeLogonBat = @ScriptDir & "\data\removeLogon.bat"
	$aResult = databaseQuery("1")
		For $i = 2 to $aResult[0]
			local $ipPC = $aResult[$i]
			if NOT $ipPC = $myIP Then
				run("psexec.exe -accepteula \\"&$ipPC&" "&$cedentials&"  -s -f -c "&$removeLogonBat)
				sleep(50)
			EndIf
		next
	MsgBox($MB_SYSTEMMODAL, "","Logon aus Registry entfernt")
EndFunc

func logonRechner()
	setCredentials()
	if $cedentials ="-u mschool-ad\n.scheuble_adm -p test12345" Then
		$logonBat = @ScriptDir & "\data\logon.bat"
	Else
		$logonBat = @ScriptDir & "\data\logonVHD.bat"
	EndIf
	$aResult = databaseQuery("1")
		For $i = 2 to $aResult[0]
			local $ipPC = $aResult[$i]
			if NOT $ipPC = $myIP Then
				run("psexec.exe -accepteula \\"&$ipPC&" "&$cedentials&"  -s -f -c "&$logonBat)
				sleep(50)
			EndIf
		next
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
		$aResult = databaseQuery("1")
		For $i = 2 to $aResult[0]
			local $ipPC = $aResult[$i]
			run("psexec.exe -accepteula \\"&$ipPC&" "&$cedentials&"  -s -f -c "&$queryUser)
			sleep(2000)
		next
	sleep(1000)
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
			local $fileList = _FileListToArray ($autoitShare,"*")
		;~ 	_ArrayDisplay($fileList, "Query Result")

				For $i = 1 to $fileList[0]
					 Local $file = $autoitShare&$fileList[$i]

					 $string = $fileList[$i]
					 $array = StringSplit($string, ".")
					 Global $ipInFilename = $array[1]&"."&$array[2]&"."&$array[3]&"."&$array[4]

		;~ 			 MsgBox($MB_SYSTEMMODAL, "ip in filename",$ipInFilename)
					 Local $hFileOpen = FileOpen($file, $FO_READ)
					 Local $firstLine = FileReadLine($hFileOpen, 1)
					 Local $sFileReadUser = FileReadLine($hFileOpen, 2)
		;~ 			 Local $sFileReadComputer = FileReadLine($hFileOpen, 3)
					 FileClose($hFileOpen)
		;~ 			 MsgBox($MB_SYSTEMMODAL, "file content",$sFileReadUser&" auf "&$sFileReadComputer)
					 if StringInStr( $firstLine, "BENUTZERNAME") then
						local $user = StringMid ( $sFileReadUser, 1,20 )
		;~ 				MsgBox($MB_SYSTEMMODAL, "Anmeldung","lehrer ist angemeldet")
						Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
						Local $aResult, $iRows, $iColumns, $iRval
						_SQLite_Startup()
						Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
						local $room = GUICtrlRead($combo1)
						If $iRval = $SQLITE_OK Then
							_SQLite_Exec(-1, "Update raumpc SET Status = '"& $user &"' where IP = '"& $ipInFilename &"';")
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
			cleanup()
			Exit

        Case $allButtons[0] To UBound($allButtons) - 1   ;COOOOOOOOOOOOOOOOOOOOOOL  *************************************************
                Global $iIndex = $iMsg - $allButtons[0]
;~              ConsoleWrite($iIndex & @CRLF)
				$butPressed = GUICtrlRead($allButtons[$iIndex])
				$testIP = StringSplit($butPressed,"|")
				$butIP = $testIP[2]
;~ 				MsgBox($MB_SYSTEMMODAL, "inhaltIP",$butIP)
;~ 				MsgBox($MB_SYSTEMMODAL, "inhalt button",$butPressed)
				if StringInStr ($butIP, "IP") Then
					MsgBox($MB_SYSTEMMODAL, "- Offline - ","Rechner nicht online")
				Else
					$butWnummer = StringMid ($butPressed,1,8)
					$vlanErmitteln = StringSplit($butIP,".")
					local $chosenVlan = $vlanErmitteln[1]&"."&$vlanErmitteln[2]&"."&$vlanErmitteln[3]&"."
	;~ 				MsgBox($MB_SYSTEMMODAL, "button nur wnummer",$butPressed)
;~ 					MsgBox($MB_SYSTEMMODAL, "vlan",$chosenVlan)
					run(@ScriptDir & "\data\kontext.exe"&" "&$butWnummer&" "&$chosenVlan&" "&$butIP)
				EndIf

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
			if(jaNeinButton("sicher alle Rechner aufwecken?")) then wolRechnerGleichesVLan()
		Case $butShutdown
			if(jaNeinButton("sicher alle Rechner herunterfahren?")) then shutdownRechner()
		Case $butLogon
			if(jaNeinButton("sicher alle Rechner einloggen?")) then logonRechner()
		Case $butRemoveLogon
			if(jaNeinButton("sicher bei allen Rechnern Logon entfernen?")) then removeLogonRechner()
		Case $butRefresh
			roomChosen()
		Case $butScan
			vlanScannen()
			roomChosen()
		Case $butLoggedOn
			whoIsLoggedOn()
		Case $butChooseBatch
			selectFile()
		Case $butExec1
			if Not $selectedBatch Then
				MsgBox(0, "Info", "kein Batch File ausgewählt")
			else
				if(jaNeinButton("sicher diese Batch Datei auf allen Rechnern ausführen")) then
					setCredentials()
					$aResult = databaseQuery("1")
					_ArrayDisplay($aResult)
;~ 					executeSelectedFile()
				EndIf
			EndIf

		Case $butTest
;~ 			$verify = jaNeinButton("sicher alle Rechner herunterfahren?")
			if(jaNeinButton("sicher alle Rechner herunterfahren?")) then MsgBox(0, "Answer", "true")

;~ 			MsgBox(0, "Answer", $verify)
	EndSwitch
WEnd


func executeSelectedFile()
;~ 	setCredentials()
;~ 	$aResult = databaseQuery("1")
;~ 		For $i = 2 to $aResult[0]
;~ 			local $ipPC = $resultDB[$i]
;~ 			if NOT $ipPC = $myIP Then
;~ 					MsgBox($MB_SYSTEMMODAL, "IP",$ipPC)
;~ 				sleep(50)
;~ 			EndIf
;~ 		next

	MsgBox($MB_SYSTEMMODAL, "Info","Batch wird ausgeführt")


;~ 	run("psexec.exe -accepteula \\"&$ipPC&" "&$cedentials&"  -s -f -c "&$batFile)
EndFunc

Func selectFile()
	Local Const $sMessage = "Auswahl der Batch Datei"
;~ 	Local $sFileOpenDialog = FileOpenDialog($sMessage, @WindowsDir & "\", "CSV Datei (*.csv)", $FD_FILEMUSTEXIST)
	$selectedBatch = FileOpenDialog($sMessage,@ScriptDir & "\", "Batch Datei (*.bat)", $FD_FILEMUSTEXIST)
	if StringLen($selectedBatch) > 40 then
		GUICtrlSetData($labBatchChosen, "..... "&StringRight($selectedBatch, 40))
	Else
		GUICtrlSetData($labBatchChosen,$selectedBatch)

	EndIf
EndFunc


func jaNeinButton($text)  ;Sicherheitsabfrage bei "shutdown all", "log PCs on", "Remove Logon" and "WOL all"
	$verify = MsgBox(4, $text, "Ja oder Nein?")
	If $verify = 6 Then
;~ 		MsgBox(0, "Yes", "Yes")
		return True
	ElseIf $verify = 7 Then
;~ 		MsgBox(0, "No", "No")
		return False
	EndIf


EndFunc

func databaseQuery($abfrageTyp)
;~ 1) $iRval = _SQLite_GetTable(-1, "select IP from raumpc where IP not like 'IP' and Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
;~ 	von shutdownRechner() removeLogonRechner() logonRechner() whoIsLoggedOn()
;~ 2) $iRval = _SQLite_GetTable(-1, "select distinct Raum from raumpc order by Raum;", $aResult, $iRows, $iColumns) von   (RaeumeVonDBEinlesen())
;~ 3) $iRval = _SQLite_GetTable(-1, "select Rechner,IP,Status from raumpc where Raum = '" & $room & "';", $aResult, $iRows, $iColumns) von   (roomChosen())
;~ 4) _SQLite_QuerySingleRow(-1, "select vlan from raumpc where Raum = '" & $room & "';", $aRow)  von   (roomChosen())
;~ 5) $iRval = _SQLite_GetTable(-1, "select MAC from raumpc where Raum = '" & $room & "';", $aResult, $iRows, $iColumns)   von wolRechnerGleichesVLan()
;~ 	MsgBox($MB_SYSTEMMODAL, "scriptdir ",@ScriptDir)
	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
	Local $aResult, $iRows, $iColumns, $iRval
	 _SQLite_Startup()
	 Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
	 local $room = GUICtrlRead($combo1)


	Switch $abfrageTyp
		Case "1"
			$iRval = _SQLite_GetTable(-1, "select IP from raumpc where IP not like 'IP' and Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
;~ 			_arrayDisplay($aResult)
		Case "2"
			$iRval = _SQLite_GetTable(-1, "select distinct Raum from raumpc order by Raum;", $aResult, $iRows, $iColumns)
;~ 			_arrayDisplay($aResult)
		Case "3"
			$iRval = _SQLite_GetTable(-1, "select Rechner,IP,Status from raumpc where Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
;~ 			_arrayDisplay($aResult)
		Case "4"
			$iRval = _SQLite_QuerySingleRow(-1, "select vlan from raumpc where Raum = '" & $room & "';", $aResult)
;~ 			_arrayDisplay($aResult)
		Case "5"
			$iRval = _SQLite_GetTable(-1, "select MAC from raumpc where Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
;~ 			_arrayDisplay($aResult)
	EndSwitch


	If $iRval = $SQLITE_OK Then
		_SQLite_Close()
		_SQLite_Shutdown()
;~ 		_ArrayDisplay($aResult, "Query Result")
		return $aResult
	EndIf
EndFunc


func cleanup()
	#RequireAdmin
	$autoitShare = "C:\tempAutoit\"
	if FileExists($autoitShare) Then
		run(@ScriptDir & "\data\deleteShare.bat")
	EndIf
	_ReplaceStringInFile($queryUser,$myIP,"localhost")
EndFunc

