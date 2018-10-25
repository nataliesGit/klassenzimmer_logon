#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=data\ico\comp4.ico
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
$Form2 = GUICreate("Scan", 565, 908, -1, -1)
GUISetBkColor(0xE3E3E3)
Local $idPic = GUICtrlCreatePic(@ScriptDir & "\data\guiElements\bg.jpg", 0, 0, 580, 908)
GUICtrlSetState(-1, $GUI_DISABLE) ; If a picture is set as a background picture the other controls will overlap, so it is important to disable the pic control: GUICtrlSetState(-1, $GUI_DISABLE).

$labStatischClassroom = GUICtrlCreateLabel("  Klassenraum  ", 32, 64, 76, 17)
$Combo1 = GUICtrlCreateCombo("Auswahl", 112, 61, 81, 25, $CBS_DROPDOWNLIST + $WS_VSCROLL)
$butWol = GUICtrlCreateButton("WOL all", 112, 112, 67, 25)
$butResetDB = GUICtrlCreateButton("Reset DB", 32, 144, 75, 25)
$butDB = GUICtrlCreateButton("Show DB", 32, 112, 75, 25)
;~ $Button1 = GUICtrlCreateButton("W000000 |  000.000.000.000  | Status", 32, 223, 411, 17)
$butRefresh = GUICtrlCreateButton("butRefresh", 448, 223, 25, 22, $BS_BITMAP)
GUICtrlSetImage(-1,@ScriptDir & "\data\guiElements\reload1k.bmp", -1)
$butScan = GUICtrlCreateButton("Scan", 339, 61, 30, 20, $BS_BITMAP)
GUICtrlSetImage(-1, @ScriptDir & "\data\guiElements\scank.bmp", -1)

$labStatischVlan = GUICtrlCreateLabel("VLAN: ", 208, 64, 38, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT) ;transparenter Hintergrund des Labels
$labVlan = GUICtrlCreateLabel("00.00.00", 248, 64, 70, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT) ;transparenter Hintergrund des Labels

$labScanStatus = GUICtrlCreateLabel("scan status", 384, 64, 154, 17)
$labMyIP = GUICtrlCreateLabel("meine IP", 88, 16, 173, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT) ;transparenter Hintergrund des Labels
$labStatischMyIP = GUICtrlCreateLabel("meine IP:", 40, 16, 48, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT) ;transparenter Hintergrund des Labels
$butLoggedOn = GUICtrlCreateButton("logged on?", 113, 144, 67, 25)
$butExec2 = GUICtrlCreateButton("exec bat mit IP Kontext", 392, 145, 147, 25)
$comboApp2 = GUICtrlCreateCombo("", 192, 145, 177, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$butExec1 = GUICtrlCreateButton("exec bat ohne IP Kontext", 392, 112, 147, 25)
$comboApp1 = GUICtrlCreateCombo("", 192, 112, 177, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


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
Global $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
Global $pcdb
Global $room



;~ resetDB()
RaeumeVonDBEinlesen()
populateComboClassroom()
populateComboBatchIPKontext()
eigeneIPauslesen()
populateComboBatchOhneIPKontext()

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

func populateComboBatchOhneIPKontext()
	local $batFileList = @ScriptDir & "\data\batchFilesChoice\"
	local $fileList = _FileListToArray ($batFileList,"*")
;~ 	_ArrayDisplay($fileList, "file list")
	For $i = 1 to $fileList[0]
		GUICtrlSetData($comboApp1,$fileList[$i])
	Next
EndFunc

func populateComboBatchIPKontext()
	local $batFileList = @ScriptDir & "\data\batchFiles\"
	local $fileList = _FileListToArray ($batFileList,"*")
;~ 	_ArrayDisplay($fileList, "file list")
	For $i = 1 to $fileList[0]
		if $fileList[$i] <> "PsExec.exe" then
			GUICtrlSetData($comboApp2,$fileList[$i])
		EndIf
	Next
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
	startDB()
    _SQLite_Exec($pcdb, "UPDATE raumpc SET IP = 'IP'")
	_SQLite_Exec($pcdb, "UPDATE raumpc SET Status = '-------'")
	closeDB()
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

func wolVorbereitung()
	local $myIpSplit = StringSplit ($myIP, ".")
	local $myVLAN = $myIpSplit[1]&"."&$myIpSplit[2]&"."&$myIpSplit[3]&"."
	local $chosenVlan = GUICtrlRead($labVlan)
;~ 	MsgBox($MB_SYSTEMMODAL,"Kontrolle chosen vlan",$chosenVlan)
;~ 	MsgBox($MB_SYSTEMMODAL,"Kontrolle my vlan",$myVLAN)
	if $myVLAN = $chosenVlan then
		wolGleichesVLan($chosenVlan&"255")
	Else
;~ 		MsgBox($MB_SYSTEMMODAL, "WOL FremdVLan","to be implemented")
		wolFremdVLan()
	EndIf
EndFunc


func wolGleichesVLan($vlan)
		local $wolUebergabeString = $vlan
		local $aResult = databaseQuery("5")
		local $anzahlRows = $aResult[0]
		For $i = 2 to $anzahlRows
			local $mac = $aResult[$i]
	;~ 		MsgBox($MB_SYSTEMMODAL, "Mac aus DB",$mac)
			local $macSplit = StringSplit ($mac, ":")
			local $macKorrigiert = $macSplit[1]&$macSplit[2]&$macSplit[3]&$macSplit[4]&$macSplit[5]&$macSplit[6]
	;~ 		MsgBox($MB_SYSTEMMODAL, "Mac ohne :",$macKorrigiert)
			$wolUebergabeString = $wolUebergabeString & " " & $macKorrigiert
		next
;~ 		MsgBox($MB_SYSTEMMODAL, "Uebergabestring",$wolUebergabeString)
		MsgBox($MB_SYSTEMMODAL, "","Wol Prozess gestartet")
		run(@ScriptDir & "\data\wolRechner.exe"&" "&$wolUebergabeString)
EndFunc

func wolFremdVLan()  ;Unterschied zu "wolGleichesVLan": Agentrechner wird benötigt; evtl noch protokollieren
	setCredentials()
	local $chosenVlan = GUICtrlRead($labVlan)
	local $wolUebergabeString = $chosenVlan&"255"
	local $aResult, $iRows, $iColumns
	 ;suche ersten Rechner in DB, der online ist und als Wol Agent im gesuchten VLAN fungieren kann
	 startDB()
	 _SQLite_GetTable(-1, "select IP from raumpc where IP not like 'IP' and VLAN = '" & $chosenVlan & "';", $aResult, $iRows, $iColumns)
	 closeDB()
;~ 		_ArrayDisplay($aResult, "Query Result")
		if UBound($aResult)> 2 then
			$agentRechner = $aResult[2]
			MsgBox($MB_SYSTEMMODAL, "agent Rechner",$agentRechner)
			local $aResult = databaseQuery("5")
			local $anzahlRows = $aResult[0]
			For $i = 2 to $anzahlRows
				local $mac = $aResult[$i]
			;~ 	MsgBox($MB_SYSTEMMODAL, "Mac aus DB",$mac)
				local $macSplit = StringSplit ($mac, ":")
				local $macKorrigiert = $macSplit[1]&$macSplit[2]&$macSplit[3]&$macSplit[4]&$macSplit[5]&$macSplit[6]
			;~ 	MsgBox($MB_SYSTEMMODAL, "Mac ohne :",$macKorrigiert)
				$wolUebergabeString = $wolUebergabeString & " " & $macKorrigiert
			next

				MsgBox($MB_SYSTEMMODAL, "Uebergabestring",$wolUebergabeString)
				MsgBox($MB_SYSTEMMODAL, "$agentRechner",$agentRechner)
				MsgBox($MB_SYSTEMMODAL, "$cedentials",$cedentials)

				run("psexec.exe -accepteula \\"&$agentRechner&" "&$cedentials&" -s -f -c "&@ScriptDir & "\data\wolFremdVLAN.exe"&" "&$wolUebergabeString)
				MsgBox($MB_SYSTEMMODAL, "","Wol Prozess gestartet")

		Else
			MsgBox($MB_SYSTEMMODAL, "kein Online Rechner","derzeit kein Rechner im gewählten VLAN online")
		EndIf

EndFunc

func wolSingleRechner($wnummer)
	setCredentials()
;~ 	MsgBox($MB_SYSTEMMODAL, "wol für",$wnummer)
;~ 	MsgBox($MB_SYSTEMMODAL, "single wol","single wol wird ausgefuehrt")
	local $myIpSplit = StringSplit ($myIP, ".")
	local $myVLAN = $myIpSplit[1]&"."&$myIpSplit[2]&"."&$myIpSplit[3]&"."
	local $chosenVlan = GUICtrlRead($labVlan)
	local $wolUebergabeString = $chosenVlan&"255"
;~ 	MsgBox($MB_SYSTEMMODAL,"Kontrolle chosen vlan",$chosenVlan)
;~ 	MsgBox($MB_SYSTEMMODAL,"Kontrolle my vlan",$myVLAN)
	startDB()
	local $aRow
	_SQLite_QuerySingleRow(-1, "select Mac from raumpc where Rechner = '" & $wnummer & "';", $aRow)
	closeDB()
;~ 	_ArrayDisplay($aRow)
	local $mac = $aRow[0]
	local $macSplit = StringSplit ($mac, ":")
	local $macKorrigiert = $macSplit[1]&$macSplit[2]&$macSplit[3]&$macSplit[4]&$macSplit[5]&$macSplit[6]
;~ 	MsgBox($MB_SYSTEMMODAL, "Mac ohne :",$macKorrigiert)
	$wolUebergabeString = $wolUebergabeString & " " & $macKorrigiert

	if $myVLAN = $chosenVlan then                                             ;---------------- gleiches VLAN -------------------
;~ 		MsgBox($MB_SYSTEMMODAL, "Übergabestring",$wolUebergabeString)
		MsgBox($MB_SYSTEMMODAL, "","Wol Prozess gestartet")
		run(@ScriptDir & "\data\wolRechner.exe"&" "&$wolUebergabeString)
	Else  	 															    ;---------------- Femd VLAN -------------------
;~ 		MsgBox($MB_SYSTEMMODAL, "Übergabestring",$wolUebergabeString)
;~ 		MsgBox($MB_SYSTEMMODAL, "","Wol Prozess gestartet")
		 ;suche ersten Rechner in DB, der online ist und als Wol Agent im gesuchten VLAN fungieren kann
		startDB()
		local $aResult, $iRows, $iColumns
		_SQLite_GetTable(-1, "select IP from raumpc where IP not like 'IP' and VLAN = '" & $chosenVlan & "';", $aResult, $iRows, $iColumns)
		closeDB()
;~ 		_ArrayDisplay($aResult, "Query Result")
		if UBound($aResult)> 2 then
			$agentRechner = $aResult[2]
			MsgBox($MB_SYSTEMMODAL, "agent Rechner",$agentRechner)
			run("psexec.exe -accepteula \\"&$agentRechner&" "&$cedentials&" -s -f -c "&@ScriptDir & "\data\wolFremdVLAN.exe"&" "&$wolUebergabeString)
		else
			MsgBox($MB_SYSTEMMODAL, "kein Online Rechner","derzeit kein Rechner im gewählten VLAN online")
		EndIf

	EndIf
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

						Local $aResult, $iRows, $iColumns, $iRval
						startDB()
						If $iRval = $SQLITE_OK Then
							_SQLite_Exec(-1, "Update raumpc SET Status = '"& $user &"' where IP = '"& $ipInFilename &"';")
						Else
							MsgBox($MB_SYSTEMMODAL, "SQLite Error: " & $iRval, _SQLite_ErrMsg())
						EndIf

						closeDB()
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
					if(jaNeinButton("diesen Rechner aufwecken?")) then
						$butWnummer = StringMid ($butPressed,1,8)
						wolSingleRechner($butWnummer)
					EndIf
;~ 					MsgBox($MB_SYSTEMMODAL, "- Offline - ","Rechner nicht online")
				Else
					$butWnummer = StringMid ($butPressed,1,8)
					$vlanErmitteln = StringSplit($butIP,".")
					local $chosenVlan = $vlanErmitteln[1]&"."&$vlanErmitteln[2]&"."&$vlanErmitteln[3]&"."
	;~ 				MsgBox($MB_SYSTEMMODAL, "button nur wnummer",$butPressed)
;~ 					MsgBox($MB_SYSTEMMODAL, "vlan",$chosenVlan)
					run(@ScriptDir & "\data\kontext.exe"&" "&$butWnummer&" "&$chosenVlan&" "&$butIP)
				EndIf

		Case $Combo1
			roomChosen()
		Case $butResetDB
			resetDB()
		Case $butDB
			Run (@ScriptDir & "\data\anzeigeDB.exe")
		Case $butWol
			if(jaNeinButton("sicher alle Rechner aufwecken?")) then wolVorbereitung()

		Case $butRefresh
			roomChosen()
		Case $butScan
			vlanScannen()
			roomChosen()
		Case $butLoggedOn
			whoIsLoggedOn()

		Case $butExec1
			$selectedBatch =  @ScriptDir & "\data\batchFilesChoice\" & GUICtrlRead($comboApp1)
			if Not $selectedBatch Then
				MsgBox(0, "Info", "keine Auswahl erfolgt")
			else
				if(jaNeinButton("sicher auf allen Rechnern ausführen")) then
					executeSelectedFile()
				EndIf
			EndIf
		Case  $butExec2
			$selectedBatch =  @ScriptDir & "\data\batchFiles\" & GUICtrlRead($comboApp2)
			if Not $selectedBatch Then
				MsgBox(0, "Info", "keine Auswahl erfolgt")
			else
				if(jaNeinButton("sicher auf allen Rechnern ausführen")) then
					executeSelectedFile2()
				EndIf
			EndIf

	EndSwitch
WEnd


func executeSelectedFile()
	setCredentials()
	$aResult = databaseQuery("1")
;~ 	_ArrayDisplay($aResult, "Query Result")
	local $aResult, $iRows, $iColumns

		For $i = 2 to $aResult[0]
			local $ipPC = $aResult[$i]
;~ 			MsgBox($MB_SYSTEMMODAL, "selected batch",$selectedBatch)
;~ 			MsgBox($MB_SYSTEMMODAL, "IP des Rechners",$ipPC)
;~ 			MsgBox($MB_SYSTEMMODAL, "meine IP",$myIP)
			if $ipPC <> $myIP Then
;~ 					MsgBox($MB_SYSTEMMODAL, "meine IP und Rechnerip not gleich","meine IP und Rechnerip not gleich")
					run("psexec.exe -accepteula \\"&$ipPC&" "&$cedentials&"  -s -f -c "&$selectedBatch)
				sleep(50)
			EndIf
		next

	MsgBox($MB_SYSTEMMODAL, "Info","Batch wird ausgeführt")

EndFunc

func executeSelectedFile2()  ; alle Rechner in Schleife aufrufen
	setCredentials()
	local $arrayApps[] = ["VHD_copyAllplanFolder"]
;~ 	_ArrayDisplay($arrayApps)
	local $auswahl = GUICtrlRead($comboApp2)
;~ 	MsgBox($MB_SYSTEMMODAL, "auswahl: ",$auswahl)
	local $inArrayAppsEnthalten = _ArraySearch($arrayApps,$auswahl)  ;wenn das gewählte batch nicht im Array $arrayApps enthalten ist, soll die eigene IP ($myIP) im Batchfile ersetzt werden,
												 ;andernfalls die eigene IP
;~ 	MsgBox($MB_SYSTEMMODAL, "app gewählt: ",$choice)

	$aResult = databaseQuery("1")
;~ 	_ArrayDisplay($aResult, "Query Result")
	local $aResult, $iRows, $iColumns

		For $i = 2 to $aResult[0]
			local $ipPC = $aResult[$i]
;~ 			MsgBox($MB_SYSTEMMODAL, "selected batch",$selectedBatch)
;~ 			MsgBox($MB_SYSTEMMODAL, "IP des Rechners",$ipPC)
;~ 			MsgBox($MB_SYSTEMMODAL, "meine IP",$myIP)
			if $ipPC <> $myIP Then
;~ 					MsgBox($MB_SYSTEMMODAL, "Batch wird ausgeführt","meine IP und Rechnerip not gleich")
				    if $inArrayAppsEnthalten >= 0 Then  ;myIP soll ersetzt werden
						replaceStringsStart($selectedBatch,$myIP)
						run($selectedBatch,"", @SW_HIDE)
						sleep(200)
						replaceStringsEnde($selectedBatch,$myIP)
					Else
						replaceStringsStart($selectedBatch,$ipPC)
						run($selectedBatch,"", @SW_HIDE)
						sleep(200)
						replaceStringsEnde($selectedBatch,$ipPC)
					EndIf
				sleep(50)
			EndIf
		next

	MsgBox($MB_SYSTEMMODAL, "Info","Batch wird ausgeführt")

EndFunc

func replaceStringsStart($fileToChange,$whichIP)
;~ 	MsgBox($MB_SYSTEMMODAL, "Info","Start replace string in "&$fileToChange)
	_ReplaceStringInFile($fileToChange,"localhost",$whichIP)
EndFunc

func replaceStringsEnde($fileToChange,$whichIP)
;~ 	MsgBox($MB_SYSTEMMODAL, "Info","End replace string in "&$fileToChange)
	_ReplaceStringInFile($fileToChange,$whichIP,"localhost")
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

func startDB()
	 _SQLite_Startup()
	 $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
	 $room = GUICtrlRead($combo1)
EndFunc
func closeDB()
	_SQLite_Close()
	_SQLite_Shutdown()
EndFunc

func databaseQuery($abfrageTyp)
;~ 1) $iRval = _SQLite_GetTable(-1, "select IP from raumpc where IP not like 'IP' and Raum = '" & $room & "';", $aResult, $iRows, $iColumns)
;~ 	von shutdownRechner() removeLogonRechner() logonRechner() whoIsLoggedOn()
;~ 2) $iRval = _SQLite_GetTable(-1, "select distinct Raum from raumpc order by Raum;", $aResult, $iRows, $iColumns) von   (RaeumeVonDBEinlesen())
;~ 3) $iRval = _SQLite_GetTable(-1, "select Rechner,IP,Status from raumpc where Raum = '" & $room & "';", $aResult, $iRows, $iColumns) von   (roomChosen())
;~ 4) _SQLite_QuerySingleRow(-1, "select vlan from raumpc where Raum = '" & $room & "';", $aRow)  von   (roomChosen())
;~ 5) $iRval = _SQLite_GetTable(-1, "select MAC from raumpc where Raum = '" & $room & "';", $aResult, $iRows, $iColumns)   von wolRechnerGleichesVLan()

	Local $aResult, $iRows, $iColumns, $iRval
	startDB()

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
		closeDB()
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