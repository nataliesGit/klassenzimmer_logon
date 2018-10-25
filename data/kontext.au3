#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ico\comp4.ico
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


#Region ### START Koda GUI section ### Form=c:\_natalie_eigene\klassenraum_logon\data\guis_forms\kontext.kxf
$kontext_1 = GUICreate("Kontext", 329, 498, 579, 178)
GUISetBkColor(0xBAB5AC)

Local $idPic = GUICtrlCreatePic(@ScriptDir & "\guiElements\kontext.jpg", 0, 0, 329, 498)
GUICtrlSetState(-1, $GUI_DISABLE) ; If a picture is set as a background picture the other controls will overlap, so it is important to disable the pic control: GUICtrlSetState(-1, $GUI_DISABLE).


$butDeploy = GUICtrlCreateButton("VNC deploy/ start", 24, 128, 99, 25)
$butConnectVNC = GUICtrlCreateButton("VNC connect", 24, 160, 99, 25)
$butRdp = GUICtrlCreateButton("RDP", 24, 72, 99, 25)
;~ $labRechner = GUICtrlCreateLabel("Rechner", 24, 24, 52, 17)
$labRechner = GUICtrlCreateLabel("Rechner", 24, 24, 276, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x800000)
$Label1 = GUICtrlCreateLabel("Batch Datei auf Zielrechner ausführen (psexec)", 24, 237, 227, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$butChooseBatch = GUICtrlCreateButton(" .... ", 24, 256, 27, 25)
$labBatchChosen = GUICtrlCreateLabel("keine Datei ausgewählt", 56, 264, 227, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$butGO = GUICtrlCreateButton("Execute", 24, 283, 91, 25)
$Label2 = GUICtrlCreateLabel("Starte Applikation auf Zielrechner (psexec)", 24, 324, 204, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$comboApplikation = GUICtrlCreateCombo("", 24, 344, 201, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$butGO2 = GUICtrlCreateButton("Execute", 24, 368, 91, 25)
$butStopVNC = GUICtrlCreateButton("VNC stop", 24, 193, 99, 25)
$butVerteiler = GUICtrlCreateButton(" ... ", 24, 432, 27, 25)
$Label3 = GUICtrlCreateLabel("Verteile Inhalt des gewählten Ordners auf Zielrechner", 24, 411, 254, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$labVerteiler = GUICtrlCreateLabel("", 56, 440, 215, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$labExecuteVerteiler = GUICtrlCreateLabel("Ordner auf Zielrechner: ", 24, 464, 116, 17)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$inputOrdner = GUICtrlCreateInput("", 144, 464, 169, 21)
$butG = GUICtrlCreateButton("Go", 278, 432, 35, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

GUICtrlSetData($comboApplikation,"clt2020_desktopticker")
GUICtrlSetData($comboApplikation,"clt2020_word")
GUICtrlSetData($comboApplikation,"clt2020_autocad")
GUICtrlSetData($comboApplikation,"clt2020_Photoshop2017")
GUICtrlSetData($comboApplikation,"clt2020_Photoshop_CS5")
GUICtrlSetData($comboApplikation,"clt2020_illlustrator2017")
GUICtrlSetData($comboApplikation,"clt2020_illlustrator_CS5")
GUICtrlSetData($comboApplikation,"clt2020_CorelDraw_X7")
GUICtrlSetData($comboApplikation,"Client2020_psexec_cmd")
GUICtrlSetData($comboApplikation,"VHD_psexec_cmd")
GUICtrlSetData($comboApplikation,"VHD_copyAllplanFolder")
;~ GUICtrlSetData($comboApplikation,"VHD_start_allplan")     ------ fkt nicht --- erzeugt Fehlermeldung beim Zielrechner


;~ If $CmdLine[0] Then
;~ 	For $i = 1 To $CmdLine[0]
;~ 		MsgBox(64, "Passed Parameters", "Parameter " & $i & ": " & $CmdLine[$i])
;~ 	Next
;~ EndIf

Global $rdpCreds
Global $RechnerIP
Global $rechner

Global $chosenVlan
Global $cedentials

Global $autoitShare
Global $myIP
Global $BooleanVnc = false
Global $selectedBatch
Global $selectedFolder

eigeneIPauslesen()
init()
prepareVNC()
prepareAllplan()

func eigeneIPauslesen()
	$DOS = Run(@ComSpec & ' /c ipconfig | find "IPv4"', "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	ProcessWaitClose($DOS)
	$Message = StdoutRead($DOS)
	;~ MsgBox($MB_SYSTEMMODAL, "cmd output", $Message)
	local $temp = StringSplit($Message,":")
	$myIP=$temp[2]
	$myIP = StringStripWS($myIP, $STR_STRIPLEADING + $STR_STRIPTRAILING)
	;~ MsgBox($MB_SYSTEMMODAL, "my ip", $myIP)
EndFunc

func prepareAllplan()
	#RequireAdmin
	if not FileExists("C:\tempAutoitAllplan\") Then
		local $AllplanDir = @ScriptDir & "\deployAllplan"
		MsgBox($MB_SYSTEMMODAL, "$AllplanDir",$AllplanDir)
		sleep(200)
		DirCopy($AllplanDir, "C:\tempAutoitAllplan")
		local $bat = @ScriptDir & "\createAllplanShare.bat"
		run($bat)
	EndIf
EndFunc

func prepareVNC()  ;erstellt ein share c:\vnc und kopiert vnc deploy daten
;~ $vncBatch =  @ScriptDir & "\vncStart.bat"  ;kopiert und installiert ultraVNC.msi zum Remoterechner
;~ $vncShare = "C:\vnc\"
	if not FileExists("C:\vnc\") Then
		run(@ScriptDir & "\createVNCShare.bat")
		sleep(1000)
		local $vncExecutable = @ScriptDir & "\deployVNC\*"
;~ 		MsgBox($MB_SYSTEMMODAL, "vnc Executable",$vncExecutable)
		FileCopy ($vncExecutable, "C:\vnc\")
	EndIf


;~ 			run("psexec.exe -accepteula \\10.96.97.171 -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\vnc_start.bat")
;~
;~ 			run("psexec.exe -accepteula \\"&$agent&" "&$cedentials&"  -s -f -c "&@ScriptDir & "\logon.bat")
;~ 			MsgBox($MB_SYSTEMMODAL, "psexec Befehl","psexec.exe -accepteula \\"&$agent&" "&$cedentials&"  -s -f -c "&@ScriptDir & "\logon.bat")
;~ 			psexec -u nimda -p m14EU-g \\w4026894 -s -f -c xy.bat
;~ 			run(@ScriptDir & "\data\wolRechner.exe"&" "&$macKorrigiert&" "&$chosenVlan&"255")
EndFunc


;~ MsgBox(0, "ip:", $RechnerIP)
;~ MsgBox($MB_SYSTEMMODAL, "vlan",$chosenVlan)
;~ MsgBox($MB_SYSTEMMODAL, "rdp pfad",$rdpBatch)
_ReplaceStringInFile(@ScriptDir & "\vncStart.bat","localhost",$myIP)


func init()

	If $CmdLine[0] Then
		$rechner = $CmdLine[1]
		$chosenVlan = $CmdLine[2]
		$RechnerIP =  $CmdLine[3]
		GUICtrlSetData($labRechner,$rechner&" "&$RechnerIP)
	Else
		$rechner = "W4047754"  ;Rechner auf D401 - zu Testzwecken
		GUICtrlSetData($labRechner,$rechner)
		$RechnerIP ="10.96.97.171"
		$chosenVlan = "10.96.97."
	EndIf

	if $chosenVlan = "10.96.97." Or $chosenVlan = "10.96.140." Then
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan client2020")
		$cedentials ="-u mschool-ad\n.scheuble_adm -p test12345"
	Else
;~ 		MsgBox($MB_SYSTEMMODAL, "vlan","vlan VHD")
		$cedentials ="-u nimda -p m14EU-g"
	EndIf

EndFunc

Func selectFolder($labelToShowSelection,$TextToDisplay)
	$selectedFolder = FileSelectFolder($TextToDisplay,"H:\")  ;---------------- nur während entwicklung

	If @error Then
        MsgBox($MB_SYSTEMMODAL, "", "Kein Ordner ausgewählt.")
	EndIf
;~ 	MsgBox($MB_SYSTEMMODAL, "StringLen($selectedFolder)", StringLen($selectedFolder))
	if StringLen($selectedFolder) > 28 then
		GUICtrlSetData($labelToShowSelection, "..... "&StringRight($selectedFolder, 28))
	Else
		GUICtrlSetData($labelToShowSelection,$selectedFolder)
	EndIf
EndFunc

func testeOrdnerGroesse($dir)  ; teste erst ob Ordner ausgewählt ist und dann ob Inhalt leer oder über 40 MB enthält
;~ 	if $dir = "" or $dir = "Ordnerauswahl" Then
	if $dir = "" Then
		MsgBox($MB_SYSTEMMODAL, "Hinweis", "kein Ordner ausgewählt")
		return false
	EndIf
	$gewaehlterOrdner = _FileListToArray ( $dir)
		if IsArray($gewaehlterOrdner) then
		Local $iSizeByte = DirGetSize($dir)
;~ 		MsgBox($MB_SYSTEMMODAL, "Kontrolle $iSizeByte", $iSizeByte)
		Local $iSizeMB = DirGetSize($dir) / 1024 / 1024
	;~ 	MsgBox($MB_SYSTEMMODAL, "Kontrolle $iSizeByte", $iSizeByte)
	;~ 	MsgBox($MB_SYSTEMMODAL, "Kontrolle $iSizeMB", $iSizeMB)

	;~ 	if $iSizeByte = 0 Then   ;nicht zuverlässig wenn kleine Datei unter ein byte
	;~ 		MsgBox($MB_SYSTEMMODAL, "Hinweis", "Ordner ist leer")
	;~ 		return false
	;~ 	EndIf
		if $iSizeMB > 40 then
			MsgBox($MB_SYSTEMMODAL, "Hinweis", "Der Ordner enthält mehr als 40MB")
			return false
		EndIf
	EndIf
	return True
EndFunc

func Verteilung()
		$ordnerToCreate = GUICtrlRead($inputOrdner)
;~ 		MsgBox($MB_SYSTEMMODAL, "Kontrolle $selectedFolder", $selectedFolder)
;~ 		MsgBox($MB_SYSTEMMODAL, "Kontrolle $ordnerToCreate", $ordnerToCreate)
		if testeOrdnerGroesse($selectedFolder) > 0 then
			if $ordnerToCreate = "" Then
				MsgBox($MB_SYSTEMMODAL, "Kontrolle $ordnerToCreate", "kein Ordner für Zielsystem angegeben")
			Else

				$copyFrom = $selectedFolder

				$copyFrom = StringTrimLeft ( $copyFrom, 3 )


				$copyFrom = "\\10.86.28.64\support$\home_support\n.scheuble_adm\"&$copyFrom
				$copyFrom = '"'&$copyFrom&'"'
				MsgBox($MB_SYSTEMMODAL, "Kontrolle $copyFrom", $copyFrom)


;~ 				-------------- Erstellen der Batch Datei ------------------------------
				Local $sFilePath = @ScriptDir & "\kopiereDaten.bat"
				Local $hFileOpen = FileOpen($sFilePath, $FO_APPEND)
				FileWrite($hFileOpen, "@echo off" & @CRLF)
;~ 				FileWrite($hFileOpen, ''& @CRLF)
				FileWrite($hFileOpen, "IF EXIST "&$ordnerToCreate&" GOTO kopiere"& @CRLF)
				FileWrite($hFileOpen, "mkdir " &$ordnerToCreate&"" & @CRLF)
				FileWrite($hFileOpen, ':kopiere'& @CRLF)
				FileWrite($hFileOpen, "net use x: "&$copyFrom&"" & @CRLF)
				FileWrite($hFileOpen, 'xcopy /e /v /y x:\ '&$ordnerToCreate&"" & @CRLF)
				FileWrite($hFileOpen, "net use x: /delete"& @CRLF)
				FileWrite($hFileOpen, 'pause'& @CRLF)

				FileClose($hFileOpen)
				Sleep(1000)
;~ 				-------------- psecec ------------------------------
;~ 		 		MsgBox($MB_SYSTEMMODAL, "Nachfrage", "Batchfile ausführen")

				$DOS = Run("psexec.exe -accepteula \\"&$RechnerIP&" "&$cedentials&"  -s -f -c "&$sFilePath, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
				ProcessWaitClose($DOS)
				$Message = StdoutRead($DOS)
				MsgBox(0, "Stdout Read:", $Message)
;~ 				run("psexec.exe -accepteula \\"&$RechnerIP&" "&$cedentials&"  -s -f -c "&$sFilePath)


			EndIf
		EndIf
delBatchIfExists(@ScriptDir & "\kopiereDaten.bat")
EndFunc

func delBatchIfExists($sFilePath)
    Local $iFileExists = FileExists($sFilePath)
    If $iFileExists Then
        FileDelete($sFilePath)
    EndIf
EndFunc

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			cleanup()
			Exit
		case $butVerteiler
			selectFolder($labVerteiler,"Ordner auswählen")
		case $butG
			if(jaNeinButton("sicher Inhalt des gew. Ordners auf Zielsystem kopieren?")) then
				Verteilung()
			EndIf
		Case $butRDP
;~ 			Run(@ComSpec & " /C " & $rdpBatch , "")
			Run("mstsc"&" "&"/v:"&$RechnerIP)

		Case $butDeploy
			run("psexec.exe -accepteula \\"&$RechnerIP&" "&$cedentials&"  -s -f -c "&@ScriptDir & "\vncStart.bat")
;~ 			run("psexec.exe -accepteula \\10.96.97.171 -u mschool-ad\n.scheuble_adm -p test12345  -s -f -c "&@ScriptDir & "\vnctart.bat")
			$BooleanVnc = true
		Case $butConnectVNC
			Run("vncviewer.exe"&" "& $RechnerIP)
			$BooleanVnc = true
		Case $butStopVNC
			if $BooleanVnc Then
				run("psexec.exe -accepteula \\"&$RechnerIP&" "&$cedentials&"  -s -f -c "&@ScriptDir & "\vncStop.bat")
				$BooleanVnc = false
			EndIf

		Case $butChooseBatch
			selectFile()
		Case $butGO
			if Not $selectedBatch Then
				MsgBox(0, "Info", "kein Batch File ausgewählt")
			Else
				if(jaNeinButton("sicher diese Batch Datei auf allen Rechnern ausführen")) then
					run("psexec.exe -accepteula \\"&$RechnerIP&" "&$cedentials&"  -s -f -c "&$selectedBatch)
				EndIf
			EndIf

		Case $butGO2
			if(jaNeinButton("sicher ausführen")) then
				local $startApp = GUICtrlRead($comboApplikation)
				MsgBox(0, "Kontrolle $startApp", $startApp)
				execApplications($startApp)
			EndIf
	EndSwitch
WEnd


func execApplications($app)
	Switch $app
;~ 		Case "clt2020_desktopticker"                                          --------------- benötigt leider net framework 3.5 --------------------------------------
;~ 			replaceStringsStart("clt2020_desktopticker.bat",$RechnerIP)
;~ 			run(@ScriptDir & "\batchFiles\clt2020_desktopticker.bat")
;~ 			sleep(1000)
;~ 			replaceStringsEnde("clt2020_desktopticker.bat",$RechnerIP)
		Case "Client2020_psexec_cmd"
			replaceStringsStart("openCMD_client2020.bat",$RechnerIP)
			run(@ScriptDir & "\batchFiles\openCMD_client2020.bat")
			sleep(1000)
			replaceStringsEnde("openCMD_client2020.bat",$RechnerIP)
		Case "VHD_psexec_cmd"
			replaceStringsStart("openCMD_VHD.bat",$RechnerIP)
			run(@ScriptDir & "\batchFiles\openCMD_VHD.bat")
			sleep(1000)
			replaceStringsEnde("openCMD_VHD.bat",$RechnerIP)
		Case "clt2020_word"
			replaceStringsStart("clt2020_word.bat",$RechnerIP)
;~ 			MsgBox(0, "Info", "nach replaceString word")
			run(@ScriptDir & "\batchFiles\clt2020_word.bat","", @SW_HIDE)
			sleep(1000)
			replaceStringsEnde("clt2020_word.bat",$RechnerIP)
		Case "clt2020_autocad"
			replaceStringsStart("clt2020_autocad.bat",$RechnerIP)
			run(@ScriptDir & "\batchFiles\clt2020_autocad.bat","", @SW_HIDE)
			sleep(1000)
			replaceStringsEnde("clt2020_autocad.bat",$RechnerIP)
		Case "clt2020_photoshop2017"
			replaceStringsStart("clt2020_photoshop2017.bat",$RechnerIP)
			run(@ScriptDir & "\batchFiles\clt2020_photoshop2017.bat","", @SW_HIDE)
			sleep(1000)
			replaceStringsEnde("clt2020_photoshop2017.bat",$RechnerIP)
		Case "clt2020_photoshop_CS5"
			replaceStringsStart("clt2020_photoshop_CS5.bat",$RechnerIP)
			run(@ScriptDir & "\batchFiles\clt2020_photoshop_CS5.bat","", @SW_HIDE)
			sleep(1000)
			replaceStringsEnde("clt2020_photoshop_CS5.bat",$RechnerIP)
		Case "clt2020_illlustrator2017"
			replaceStringsStart("clt2020_illlustrator2017.bat",$RechnerIP)
			run(@ScriptDir & "\batchFiles\clt2020_illlustrator2017.bat","", @SW_HIDE)
			sleep(1000)
			replaceStringsEnde("clt2020_illlustrator2017.bat",$RechnerIP)
		Case "clt2020_illlustrator_CS5"
			replaceStringsStart("clt2020_illlustrator_CS5.bat",$RechnerIP)
			run(@ScriptDir & "\batchFiles\clt2020_illlustrator_CS5.bat","", @SW_HIDE)
			sleep(1000)
			replaceStringsEnde("clt2020_illlustrator_CS5.bat",$RechnerIP)
		Case "clt2020_CorelDraw_X7"
			replaceStringsStart("clt2020_CorelDraw_X7.bat",$RechnerIP)
			run(@ScriptDir & "\batchFiles\clt2020_CorelDraw_X7.bat","", @SW_HIDE)
			sleep(1000)
			replaceStringsEnde("clt2020_CorelDraw_X7.bat",$RechnerIP)
		Case "VHD_copyAllplanFolder"
			replaceStringsStart("VHD_copyAllplanFolder.bat",$myIP)
			local $selBat = @ScriptDir & "\batchFiles\VHD_copyAllplanFolder.bat"
			run("psexec.exe -accepteula \\"&$RechnerIP&" "&$cedentials&"  -s -f -c "&$selBat)
			sleep(10000)
			replaceStringsEnde("VHD_copyAllplanFolder.bat",$myIP)
	EndSwitch

EndFunc

func replaceStringsStart($fileToChange,$whichIP)
	$path = @ScriptDir &"\batchfiles\"&$fileToChange
;~ 	MsgBox($MB_SYSTEMMODAL, "Info","replace string in "&$path)
	_ReplaceStringInFile($path,"localhost",$whichIP)
EndFunc

func replaceStringsEnde($fileToChange,$whichIP)
	$path = @ScriptDir &"\batchfiles\"&$fileToChange
	_ReplaceStringInFile($path,$whichIP,"localhost")
EndFunc


Func selectFile()
	Local Const $sMessage = "Auswahl der Batch Datei"
;~ 	Local $sFileOpenDialog = FileOpenDialog($sMessage, @WindowsDir & "\", "CSV Datei (*.csv)", $FD_FILEMUSTEXIST)
	$selectedBatch = FileOpenDialog($sMessage,@ScriptDir & "\", "Batch Datei (*.bat)", $FD_FILEMUSTEXIST)
	if StringLen($selectedBatch) > 30 then
		GUICtrlSetData($labBatchChosen, "..... "&StringRight($selectedBatch, 30))
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


func cleanup()
;~ 	MsgBox($MB_SYSTEMMODAL, "cleanup","cleanup")
	_ReplaceStringInFile(@ScriptDir & "\vncStart.bat",$myIP,"localhost")
;~ 	if $BooleanVnc Then
;~ 		MsgBox($MB_SYSTEMMODAL, "booeanVnc","vnc was launched") ;dann vnc Dienst auf Rechner beenden
;~ 		run("psexec.exe -accepteula \\"&$RechnerIP&" "&$cedentials&"  -s -f -c "&@ScriptDir & "\vncStop.bat")
;~ 	EndIf

EndFunc



