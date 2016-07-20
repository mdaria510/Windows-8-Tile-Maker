#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <InetConstants.au3>
#include <WinAPIShPath.au3>
#include <Clipboard.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <File.au3>
#include <Date.au3>
#include <FileConstants.au3>
#include <ListViewConstants.au3>
#include <GuiListView.au3>
#include <GDIPlus.au3>
#include <WinAPI.au3>
#include <ComboConstants.au3>


_GDIPlus_Startup()

Global $PreCache = 0
Global $PreCacheDir = 0
Global $NoBanner = 0
Global $iCustomWideBanner = 0
Global $iCustomSquareBanner = 0
Global $SteamFolder = 0
Global $OriginFolder = 0
Global $UplayFolder = 0
Global $BattleNetFolder = 0
Global $GameDirSize = 0
Global $GameType = 0
Global $GameFolder = 0
Global $SteamURLPreTrim = 0
Global $DefaultIcon = 0
Global $GameIcon = 0
Global $GameNameNoExt = 0
Global $GameDrive = 0
Global $GameExtension = 0
Global $GameDir = 0
Global $SteamGameID = 0
Global $FolderIndex
Global $sImagesFolder
Global $SteamURL
Global $ShortcutFullPath
Global $GameFullPath
Global $FolderFound
Global $iSteamWideBanner = 0
Global $iCustomWideBanner = 0
Global $iCustomSquareBanner = 0

Global $aImageType[4]
$aImageType[0] = ".jpg"
$aImageType[1] = ".png"
$aImageType[2] = ".jpeg"
$aImageType[3] = ".bmp"

$sImagesFolder = @ScriptDir & "\Tile Images"

Global $aGameServices[10]
Global $aGameFolders[10]
Global $aGameServicesANDFolders[10][10]

$hGUI = GUICreate("Win 8 Tile Maker", 550, 600, -1, -1)

;Game Services Controls
Global $hLabelGameFolders = GUICtrlCreateLabel("Game Services", 440, 21, 148, 13)
Global $hListGameServices = GUICtrlCreateList("", 440, 40, 100, 120)
Global $hButtonAddGameService = GUICtrlCreateButton("Add", 440, 155, 40, 20)
Global $hButtonRemoveGameService = GUICtrlCreateButton("Delete", 485, 155, 40, 20)

;Wide Image Controls
Global $hLabelWide = GUICtrlCreateLabel("Wide", 20, 17, 30, 15)
Global $hInputWide = GUICtrlCreateInput("", 20, 190, 240, 20)
Global $hButtonChooseWide = GUICtrlCreateButton("Choose", 263, 189, 50, 22)
Global $hButtonSearchWide = GUICtrlCreateButton("Search", 313, 189, 50, 22)

;Square Image Controls
Global $hLabelLargeSquare = GUICtrlCreateLabel("Large", 20, 234, 30, 15)
Global $hLabelMediumSquare = GUICtrlCreateLabel("Medium", 291, 237, 48, 16)
Global $hLabelSmallSquare = GUICtrlCreateLabel("Small", 296, 397, 48, 16)
Global $hInputSquare = GUICtrlCreateInput("", 20, 516, 240, 20)
Global $hButtonChooseSquare = GUICtrlCreateButton("Choose", 263, 515, 50, 22)
Global $hButtonSearchSquare = GUICtrlCreateButton("Search", 313, 515, 50, 22)


;Precache controls
Global $hCheckboxPrecache = GUICtrlCreateCheckbox("Precache", 440, 200, 100, 20)
Global $hLabelGameDirSizeLabel = GUICtrlCreateLabel("Game Folder Size:", 440, 225, 90, 16)
Global $hLabelGameDirSizeData = GUICtrlCreateLabel("", 440, 240, 90, 16)

;Default Tile Size Controls
Global $hLabelDefaultTileSize = GUICtrlCreateLabel("Default Tile Size",440, 270)
Global $hComboDefaultTileSize = GUICtrlCreateCombo("Wide",440, 290, "", "", $CBS_DROPDOWNLIST)
GUICtrlSetData($hComboDefaultTileSize,"Large|Square|Tiny")

;Custom Resolution Controls
Global $hCheckboxCustomRes = GUICtrlCreateCheckbox("Custom Resolution", 440, 340, 110, 20)
Global $hInputCustomResX = GUICtrlCreateInput("",440,378,40,20)
Global $hInputCustomResY = GUICtrlCreateInput("",490,378,40,20)
Global $hInputCustomResRR = GUICtrlCreateInput("",440,422,90,20)
Global $hLabelCustomResX = GUICtrlCreateLabel("X",443,360,40,15)
Global $hLabelCustomResY = GUICtrlCreateLabel("Y",493,360,40,15)
Global $hLabelCustomResRR = GUICtrlCreateLabel("Refresh Rate",440,405,100,15)

;Game Path Controls
Global $hLabelGamePath = GUICtrlCreateLabel("Path to Game", 20, 550, 90, 16)
Global $hInputGamePath = GUICtrlCreateInput("", 20, 570, 367, 20)
Global $hButtonInputGamePath = GUICtrlCreateButton("...", 391, 570, 32, 21)



Global $hButtonMakeTile = GUICtrlCreateButton("Make Tile", 440, 550, 90, 40)

GUISetState()

ReadFolderLocsFromINI()
UpdateGameFoldersList()
GetGameInfoFromShortcut()
SetGameFolder()
GetExistingWideBanner()
GetExistingSquareBanner()



While 1
	$hMsg = GUIGetMsg()
	Switch $hMsg

		Case $GUI_EVENT_CLOSE
			Exit

		Case $GUI_EVENT_RESTORE
			DrawWideBanner($iCustomWideBanner)
			DrawSquareBanner($iCustomSquareBanner)

		Case $hButtonAddGameService ; Adds new entry to the game folders list
			AddGameService()

		Case $hButtonRemoveGameService
			RemoveGameService()

		Case $hButtonChooseWide
			$iCustomWideBanner = FileOpenDialog("Choose custom wide image", $sImagesFolder & "\Wide", "Images (*.jpg;*.bmp;*.png;*.jpeg)")
			DrawWideBanner($iCustomWideBanner)

		Case $hButtonSearchWide
			SearchforWideImage()

		Case $hButtonChooseSquare
			$iCustomSquareBanner = FileOpenDialog("Choose custom square image", $sImagesFolder & "\Square", "Images (*.jpg;*.bmp;*.png;*.jpeg)")
			DrawSquareBanner($iCustomSquareBanner)

		Case $hButtonSearchSquare
			SearchforSquareImage()

		Case $hButtonMakeTile
			MakeTile()

		Case $hButtonInputGamePath
			SetGameFolder()

	EndSwitch
WEnd


Func ReadFolderLocsFromINI()

Global $aGameServices[10]
Global $aGameFolders[10]

	$aGameServicesANDFolders[0][0] = ""
	$aGameServicesANDFolders = IniReadSection("Win8 Game Tile Maker.ini", "Folders")

	If $aGameServicesANDFolders[0][0] = "" Then AddGameService()

	For $i = $aGameServicesANDFolders[0][0] to 1 Step -1
		If $aGameServicesANDFolders[$i][0] <> "" Then
			$aGameServices[$i] = $aGameServicesANDFolders[$i][0]
			$aGameFolders[$i] = $aGameServicesANDFolders[$i][1]
		EndIf
	Next
EndFunc   ;==>ReadFolderLocsFromINI

Func UpdateGameFoldersList()
	GUICtrlSetData($hListGameServices,"")
	For $i = $aGameServicesANDFolders[0][0] to 1 Step -1
		If $aGameServicesANDFolders[$i][0] <> "" Then GUICtrlSetData($hListGameServices, $aGameServicesANDFolders[$i][0] & "|")
	Next
EndFunc

Func GetGameInfoFromShortcut()
	$ShortcutFullPath = $CmdLine[1]
	$SteamURLPreTrim = FileReadLine($ShortcutFullPath, 6)

	If StringInStr($SteamURLPreTrim, "steam") Then
		$GameType = "Steam"
		_PathSplit($ShortcutFullPath, $GameDrive, $GameDir, $GameNameNoExt, $GameExtension)
		$GameFileName = $GameNameNoExt & $GameExtension
		$SteamURLPreTrim = FileReadLine($ShortcutFullPath, 6)
		$SteamIconPathPreTrim = FileReadLine($ShortcutFullPath, 7)
		$SteamURL = StringTrimLeft($SteamURLPreTrim, 4)
		$GameIcon = StringTrimLeft($SteamIconPathPreTrim, 9)
		$SlashPosInString = StringInStr($SteamURL, "/", "", -1)
		$SteamGameID = StringTrimLeft($SteamURL, $SlashPosInString)


		For $i = 0 To 9 Step 1
			If StringInStr($aGameFolders[$i], "Steam" ) Then $FolderIndex = $i
		Next

	Else
		$GameType = "Nonsteam"
		$aShortcutDetails = FileGetShortcut($ShortcutFullPath)
		$GameFullPath = $aShortcutDetails[0]
		$GameDir = $aShortcutDetails[1]

		$GameDesc = $aShortcutDetails[3]
		$GameIcon = $aShortcutDetails[0]
		$SlashPosInString = StringInStr($GameFullPath, "\", "", -1)
		$GameNameNoExt = StringTrimRight($GameFullPath, 4)
		$GameNameNoExt = StringTrimLeft($GameNameNoExt, $SlashPosInString)

		For $i = 0 To 9 Step 1
			If StringInStr($GameFullPath,$aGameFolders[$i]) Then $FolderIndex = $i
		Next
	EndIf

EndFunc

Func AddGameService()
	$sSelectedGameService = InputBox("Name","Enter name of Service")
	$sSelectedGameFolder = FileSelectFolder( "Add Game Folder", "")
	IniWrite("Win8 Game Tile Maker.ini", "Folders", $sSelectedGameService, $sSelectedGameFolder)
	ReadFolderLocsFromINI()
	UpdateGameFoldersList()
EndFunc

Func RemoveGameService()
	$sSelectedGameService = GUICtrlRead($hListGameServices,"")
	$aGameServicesANDFolders = IniReadSection("Win8 Game Tile Maker.ini", "Folders")
	For $i = $aGameServicesANDFolders[0][0] to 1 Step -1

		If $aGameServicesANDFolders[$i][0] = $sSelectedGameService Then IniDelete("Win8 Game Tile Maker.ini", "Folders", $aGameServicesANDFolders[$i][0])

	Next
	ReadFolderLocsFromINI()
	UpdateGameFoldersList()
EndFunc

Func DrawWideBanner($image)
	$g_hWideGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
	$g_hWideImage = _GDIPlus_ImageLoadFromFile($image)
	$g_hWideImage = _GDIPlus_ImageResize($g_hWideImage, 340, 150)
	_GDIPlus_GraphicsDrawImage($g_hWideGraphic, $g_hWideImage, 20, 35)
	GuiCtrlSetData($hInputWide, $image)
EndFunc

Func DrawSquareBanner($image)
	$g_hSquareGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
	$g_hSquareImage = _GDIPlus_ImageLoadFromFile($image)
	$g_hSquareImageLarge = _GDIPlus_ImageResize($g_hSquareImage, 256, 256)
	$g_hSquareImageMedium = _GDIPlus_ImageResize($g_hSquareImage, 128, 128)
	$g_hSquareImageSmall = _GDIPlus_ImageResize($g_hSquareImage, 64, 64)
	_GDIPlus_GraphicsDrawImage($g_hSquareGraphic, $g_hSquareImageLarge, 20, 254)
	_GDIPlus_GraphicsDrawImage($g_hSquareGraphic, $g_hSquareImageMedium, 291, 258)
	_GDIPlus_GraphicsDrawImage($g_hSquareGraphic, $g_hSquareImageSmall, 296, 418)
	GuiCtrlSetData($hInputSquare, $image)
EndFunc

Func GetExistingWideBanner()

	For $vElement In $aImageType
			If FileExists($sImagesFolder & "\Wide\" & $GameNameNoExt & $vElement) = 1 Then
				$iCustomWideBanner = $sImagesFolder & "\Wide\" & $GameNameNoExt & $vElement
				DrawWideBanner($iCustomWideBanner)
				return
			EndIf
	Next


	If $GameType = "Steam" Then
		If FetchSteamWideBanner() = 1 Then
			DrawWideBanner($iCustomWideBanner)
			return
		EndIf
	EndIf

EndFunc

Func FetchSteamWideBanner()

	If FileExists($sImagesFolder & "\Steam\" & $SteamGameID & ".jpg") = 1 Then
		$iCustomWideBanner = $sImagesFolder & "\Steam\" & $SteamGameID & ".jpg"
		return 1
	Else
		InetGet("http://cdn.highwinds.steamstatic.com/steam/apps/" & $SteamGameID & "/header_292x136.jpg", $sImagesFolder & "\Steam\" & $SteamGameID & ".jpg", 0, $INET_DOWNLOADWAIT)
		If @error = 0 Then
			$iCustomWideBanner = $sImagesFolder & "\Steam\" & $SteamGameID & ".jpg"
		Else
			InetGet("http://cdn.steampowered.com/v/gfx/apps/" & $SteamGameID & "/header_292x136.jpg", $sImagesFolder & "\Steam\" & $SteamGameID & ".jpg", 0, $INET_DOWNLOADWAIT)
			If @error = 0 Then
				$iCustomWideBanner = $sImagesFolder & "\Steam\" & $SteamGameID & ".jpg"
			Else
				return 0
			EndIf
		EndIf
	EndIf

	return 1

EndFunc

Func GetExistingSquareBanner()

	; Check if the custom square image already exists
	For $vElement In $aImageType
		If FileExists($sImagesFolder & "\Square\" & $GameNameNoExt & $vElement) = 1 Then
			$iCustomSquareBanner = $sImagesFolder & "\Square\" & $GameNameNoExt & $vElement
			DrawSquareBanner($iCustomSquareBanner)
			ExitLoop
		EndIf
	Next

		DrawSquareBanner($iCustomSquareBanner)

EndFunc

Func SearchforWideImage()
	$PlusInsteadofSpaceGameName = StringReplace($GameNameNoExt, " ", "+")

	ShellExecute("http://steambanners.booru.org/index.php?page=post&s=list&tags=" & $PlusInsteadofSpaceGameName)

	$MsgboxResult = MsgBox(0x11001, "Pick Image", "Left click image to enlarge, then right click and 'Copy Image URL' on image you want to choose. Click OK when done.", 60)

	If $MsgboxResult = $IDOK Then
		$ImageURL = _ClipBoard_GetData()
		$ImageType = StringRight($ImageURL, 4)

		InetGet($ImageURL, $sImagesFolder & "\Wide\" & $GameNameNoExt & $ImageType)

		If @error <> 0 Then
			MsgBox(0, "", "Image Download Error")
			return
		EndIf

		$iCustomWideBanner = $sImagesFolder & "\Wide\" & $GameNameNoExt & $ImageType

		DrawWideBanner($iCustomWideBanner)
	EndIf
EndFunc

Func SearchforSquareImage()
	$PlusInsteadofSpaceGameName = StringReplace($GameNameNoExt, " ", "+")

	$BrowserPID = ShellExecute("https://google.com/search?q=" & $PlusInsteadofSpaceGameName & "&tbm=isch&tbs=imgo:1%2Cisz:ex%2Ciszw:256%2Ciszh:256")
	ShellExecute("https://google.com/search?q=" & $PlusInsteadofSpaceGameName & "&tbm=isch&tbs=imgo:1%2Cisz:ex%2Ciszw:512%2Ciszh:512")

	$MsgboxResult = MsgBox(0x11001, "Pick Image", "Left click image to enlarge, then right click and 'Copy Shortcut' on image you want to choose. Click OK when done.", 60)

	If $MsgboxResult = $IDOK Then
		$ImageURL = _ClipBoard_GetData()
		$ImageType = StringRight($ImageURL, 4)

		InetGet($ImageURL, $sImagesFolder & "\Square\" & $GameNameNoExt & $ImageType)

		If @error <> 0 Then
			MsgBox(0, "", "Image Download Error")
			return
		EndIf

		$iCustomSquareBanner = $sImagesFolder & "\Square\" & $GameNameNoExt & $ImageType

		DrawSquareBanner($iCustomSquareBanner)
	EndIf
EndFunc

Func SetGameFolder()
	If $FolderFound = 0 Then
		For $vElement In $aGameFolders
			If FileExists($vElement & "\" & $GameNameNoExt) = 1 Then
				$GameFolder = $vElement & "\" & $GameNameNoExt
				ExitLoop
			EndIf
		Next
	EndIf

	If $GameFolder = "" Then
		$GameFolder = FileSelectFolder("Select Game Folder", $aGameFolders[$FolderIndex])
	ElseIf $FolderFound = 1 Then
		$GameFolder = FileSelectFolder("Select Game Folder", $aGameFolders[$FolderIndex])
	EndIf

	$FolderFound = 1
	$GameDirSize = DirGetSize($GameFolder)
	$GameDirSize /= 1048576 ; Convert to megabytes
	$GameDirSize = Int($GameDirSize) ;Convert to integer
	GUICtrlSetData($hLabelGameDirSizeData, $GameDirSize & "MB")
	GUICtrlSetData($hInputGamePath,$GameFolder)

EndFunc

Func MakeTile()

	;create vbscript launcher
	If FileExists(@ScriptDir & "\LaunchScripts\" & $GameNameNoExt & ".vbs") = 1 Then
		FileDelete(@ScriptDir & "\LaunchScripts\" & $GameNameNoExt & ".vbs")
	EndIf

	$hShortcutScript = FileOpen(@ScriptDir & "\LaunchScripts\" & $GameNameNoExt & ".vbs", $FO_APPEND)
	FileWrite($hShortcutScript, "Set objShell = CreateObject(""Shell.Application"")" & @CRLF)

	$sQuote = """"

	If GUICtrlRead($hCheckboxCustomRes) = $GUI_CHECKED Then
		$sCustomResX = GUICtrlRead($hInputCustomResX)
		$sCustomResY = GUICtrlRead($hInputCustomResY)
		$sCustomResRR = GUICtrlRead($hInputCustomResRR)
		FileWrite($hShortcutScript, "objShell.ShellExecute """ & @ScriptDir & "\Qres.exe"", ""/x:" & $sCustomResX & " /y:" & $sCustomResY & " /r:" & $sCustomResRR & """" & @CRLF)
	EndIf

	;"Upon launch, the entire game folder will be preloaded into the windows memory cache in the background, using low priority I/O. This will dramatically reduce load times, more than even the fastest SSD. Recommended if you have more free memory than the folder size:  " & @CRLF & @CRLF & $GameDirSize & "MB")
	If GUICtrlRead($hCheckboxPrecache) = $GUI_CHECKED Then
		FileWrite($hShortcutScript, "objShell.ShellExecute """ & @ScriptDir & "\CacheFolder101.exe"", "" " & $sQuote & $sQuote & $GameFolder & "\" & $sQuote & $sQuote & " /m /b" & $sQuote & "  , , , 1" & @CRLF)
	EndIf

	If $GameType = "Steam" Then
		FileWrite($hShortcutScript, "objShell.ShellExecute """ & $SteamURL & """, , , , 1" & @CRLF)
	Else
		FileWrite($hShortcutScript, "objShell.ShellExecute """ & $GameFullPath & """, , """ & $GameDir & """ , , 1" & @CRLF)
	EndIf

	FileClose($hShortcutScript)


	$TileSize = GUICtrlRead($hComboDefaultTileSize)

	FileCreateShortcut(@ScriptDir & "\LaunchScripts\" & $GameNameNoExt & ".vbs", @ScriptDir & "\LaunchShortcuts\" & $GameNameNoExt & ".lnk","","","",$GameIcon)

	;FileCreateShortcut(@ScriptDir & "\LaunchScripts\" & $GameNameNoExt & ".vbs", "::{48e7caab-b918-4e58-a94d-505519c795dc}" & $GameNameNoExt & ".lnk","","","",$GameIcon)
	;FileCreateShortcut(@ScriptDir & "\LaunchScripts\" & $GameNameNoExt & ".vbs", "C:\Users\Mark\AppData\Roaming\Microsoft\Windows\Start Menu\" & $GameNameNoExt & ".lnk","","","",$GameIcon)





	;If $GameType = "Steam" Then
	;	ShellExecute(@ScriptDir & "\oblytile.exe", '"' & $GameNameNoExt & '" "' & @ScriptDir & '\LaunchScripts\' & $GameNameNoExt & '.vbs" "" "' & $iCustomSquareBanner & '" "" "" "' & $sImagesFolder & "\Steam\" & $SteamGameID & '.jpg" "" #000000 #000000 hide normal no no no ' & $TileSize & "")
	;Else
		;ShellExecute(@ScriptDir & "\oblytile.exe", '"' & $GameNameNoExt & '" "' & @ScriptDir & '\LaunchScripts\' & $GameNameNoExt & '.vbs" "" "' & $iCustomSquareBanner & '" "" "" "' & $iCustomWideBanner & '" "" #000000 #000000 hide normal no no no ' & $TileSize & "")
	;EndIf

	;~ $Oblytest = FileOpen("obly.txt", $FO_APPEND)

	;~ FileWriteLine($Oblytest, 'oblytile "' & $GameNameNoExt & '" "' & @ScriptDir & '\' & $GameNameNoExt & '.vbs" "" "' & $iCustomSquareBanner & '" "" "" "' & $sImagesFolder & "\Steam\" & $SteamGameID & '.jpg" "" #000000 #000000 hide normal no no no')
	;~ FileClose($Oblytest)
EndFunc

;~ _GDIPlus_GraphicsDispose($g_hWideGraphic)
;~ _GDIPlus_GraphicsDispose($g_hSquareGraphic)
;~ _GDIPlus_ImageDispose($g_hWideImage)
;~ _GDIPlus_ImageDispose($g_hSquareImage)
;~ _GDIPlus_ImageDispose($g_hSquareImageLarge)
;~ _GDIPlus_ImageDispose($g_hSquareImageMedium)
;~ _GDIPlus_ImageDispose($g_hSquareImageSmall)
;_GDIPlus_Shutdown()
