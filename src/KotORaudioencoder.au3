#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=KotORAudioEncoder.ico
#AutoIt3Wrapper_Outfile=KotORaudioencoder.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Comment=Программа для преобразования аудиофайлов игр серии «Star Wars: Knights of the Old Republic»
#AutoIt3Wrapper_Res_Description=KotOR audio encoder
#AutoIt3Wrapper_Res_Fileversion=2.0.5
#AutoIt3Wrapper_Res_LegalCopyright=Loran A. Rendel <loran@xpor.org>
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_Language=1049
#AutoIt3Wrapper_Res_Field=CompanyName|XPOR
#AutoIt3Wrapper_Res_Field=ProductName|KotOR audio encoder
#AutoIt3Wrapper_Res_Field=OriginalFilename|KotORaudioencoder.exe
#AutoIt3Wrapper_Res_File_Add=KotORaudioencoder.Button.wav, sound, button
#AutoIt3Wrapper_Res_File_Add=KotORaudioencoder.Message.wav, sound, message
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <File.au3>
#include <Array.au3>
#include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "Functions.au3"
#include "Resources.au3"

; Файлы игр KotOR содержат лишние байты (заголовок) в начале файла, поэтому могут не воспроизводиться плеером.
; Заголовки аудиофайлов KotOR:
$HeaderWAV = Binary('0xFFF360C40000000348000000004C414D45332E39335555555555555555555555555555555555555555555555554C414D45332E393355555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555FFF362C48F00000348000000005555555555555555555555555555555555555555555555555555555555555555554C414D45332E393355555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555FFF362C4FF0000034800000000555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555')
$HeaderMP3 = Binary('0x524946463200000057415645666D7420120000000100010022560000225600000100080000006661637404000000000000006461746100000000')
$HeaderWAV_Length = 470
$HeaderMP3_Length = 58
Global $Title = 'KotOR audio encoder v. 2.0.5'
_Singleton($Title)
$hGUI = GUICreate($Title, 618, 168)
GUISetFont(12, 400, 0, "Cambria")
GUICtrlCreateGroup("Выберите папку с файлами для обработки:", 8, 8, 601, 53)
$hBrowse = GUICtrlCreateButton("Обзор…", 528, 28, 75, 25)
$hFolder = GUICtrlCreateInput(@ScriptDir, 16, 28, 510, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("Выберите режим работы:", 8, 62, 601, 97)
$hInGeneric = GUICtrlCreateRadio("Преобразовать файлы из формата KotOR в стандартные wav/mp3", 16, 86, 508, 17)
$hInKotOR = GUICtrlCreateRadio("Преобразовать файлы из стандартных wav/mp3 в формат KotOR", 16, 110, 508, 17)
$hDelete = GUICtrlCreateCheckbox("Удалить оригиналы файлов", 16, 134, 508, 17)
$hGo = GUICtrlCreateButton("Запуск", 528, 78, 75, 49, 1)
$hCancel = GUICtrlCreateButton("Отмена", 528, 128, 75, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState($hInGeneric, $GUI_CHECKED)
GUICtrlSetState($hDelete, $GUI_CHECKED)
GUICtrlSetState($hFolder, $GUI_FOCUS)
Send('{right}')
GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $hBrowse
			_ResourcePlaySound("button", 1)
			$Folder = FileSelectFolder('Выберите папку', '', 0, @ScriptDir, $hGUI)
			$error = @error
			_ResourcePlaySound("button", 1)
			If $error Then ContinueLoop
			GUICtrlSetData($hFolder, $Folder)
		Case $hGo
			_ResourcePlaySound("button")
			$Folder = GUICtrlRead($hFolder)
			If StringStripWS($Folder, 8) = '' Then
				_ResourcePlaySound("message")
				MsgBox(0, $Title, 'Папка не выбрана.' & @CRLF & "Укажите папку с файлами для преобразования.", -1, $hGUI)
				_ResourcePlaySound("button", 1)
			ElseIf Not StringInStr(FileGetAttrib($Folder), 'D') Then
				_ResourcePlaySound("message")
				MsgBox(0, $Title, '"' & $Folder & '" не существует или не является папкой.' & @CRLF & "Укажите папку с файлами для преобразования.", -1, $hGUI)
				_ResourcePlaySound("button", 1)
			Else
				FileChangeDir($Folder)
				$Delete = Bool(Not (GUICtrlRead($hDelete) - 1))
				If GUICtrlRead($hInGeneric) = 1 Then
					KotOR_Decode($Folder)
				Else
					KotOR_Encode($Folder)
				EndIf
				Exit
			EndIf
		Case $GUI_EVENT_CLOSE, $hCancel
			GUIDelete()
			_ResourcePlaySound("button")
			Exit
		Case $hDelete, $hInGeneric, $hInKotOR
			_ResourcePlaySound("button", 1)
	EndSwitch
WEnd

Func KotOR_Encode($Folder)
	Local $List, $i, $a, $Success, $Skipped
	$List = KotOR_GetList($Folder)
	If $List[0] Then ProgressOn($Title, 'Преобразование файлов', "0 из " & $List[0] & ' обработано.')
	GUIDelete()
	For $i = 1 To $List[0]
		FileSetAttrib($List[$i], '-R')
		$Content = FileRead($List[$i])
		Select
			Case StringLeft($Content, $HeaderWAV_Length) = $HeaderWAV
				ContinueCase
			Case StringLeft($Content, $HeaderMP3_Length) = $HeaderMP3
				If $Delete Then
					If FileMove($List[$i], 'InKotOR\skipped\' & FileGetName($List[$i] & '.wav'), 9) Then $Skipped += 1
				Else
					If FileCopy($List[$i], 'InKotOR\skipped\' & FileGetName($List[$i] & '.wav'), 9) Then $Skipped += 1
				EndIf
			Case Else
				DirCreate('InKotOR')
				FileDelete('InKotOR\' & FileGetName($List[$i]) & '.wav')
				If FileGetExtension($List[$i]) = 'wav' Then
					If FileWrite('InKotOR\' & FileGetName($List[$i]) & '.wav', $HeaderWAV) And FileWrite('InKotOR\' & FileGetName($List[$i]) & '.wav', $Content) Then
						$Success += 1
						If $Delete Then FileDelete($List[$i])
					EndIf
				Else
					If FileWrite('InKotOR\' & FileGetName($List[$i]) & '.wav', $HeaderMP3) And FileWrite('InKotOR\' & FileGetName($List[$i]) & '.wav', $Content) Then
						$Success += 1
						If $Delete Then FileDelete($List[$i])
					EndIf
				EndIf
		EndSelect
		ProgressSet(Percent($i, $List[0]), $i & " из " & $List[0] & ' обработано.')
	Next
	Sleep(500)
	ProgressOff()
	KotOR_Msg($Success, $Skipped, $List[0])
	If $List[0] And FileExists('InKotOR') Then ShellExecute('InKotOR')
EndFunc   ;==>KotOR_Encode

Func KotOR_Decode($Folder)
	Local $List, $i, $a, $Success, $Skipped
	$List = KotOR_GetList($Folder)
	If $List[0] Then ProgressOn($Title, 'Преобразование файлов', "0 из " & $List[0] & ' обработано.')
	GUIDelete()
	For $i = 1 To $List[0]
		FileSetAttrib($List[$i], '-R')
		$Content = FileRead($List[$i])
		Select
			Case StringLeft($Content, $HeaderWAV_Length) = $HeaderWAV
				$Content = StringTrimLeft($Content, $HeaderWAV_Length)
				DirCreate('InGeneric')
				FileDelete('InGeneric\' & FileGetName($List[$i]) & '.wav')
				If FileWrite('InGeneric\' & FileGetName($List[$i]) & '.wav', $Content) Then
					$Success += 1
					If $Delete Then FileDelete($List[$i])
				EndIf
			Case StringLeft($Content, $HeaderMP3_Length) = $HeaderMP3
				$Content = StringTrimLeft($Content, $HeaderMP3_Length)
				DirCreate('InGeneric')
				FileDelete('InGeneric\' & FileGetName($List[$i]) & '.mp3')
				If FileWrite('InGeneric\' & FileGetName($List[$i]) & '.mp3', $Content) Then
					$Success += 1
					If $Delete Then FileDelete($List[$i])
				EndIf
			Case Else
				DirCreate('InGeneric\skipped')
				If $Delete Then
					If FileMove($List[$i], 'InGeneric\skipped', 1) Then $Skipped += 1
				Else
					If FileCopy($List[$i], 'InGeneric\skipped', 1) Then $Skipped += 1
				EndIf
		EndSelect
		ProgressSet(Percent($i, $List[0]), $i & " из " & $List[0] & ' обработано.')
	Next
	Sleep(500)
	ProgressOff()
	KotOR_Msg($Success, $Skipped, $List[0])
	If $List[0] And FileExists('InGeneric') Then ShellExecute('InGeneric')
EndFunc   ;==>KotOR_Decode

Func KotOR_Msg($Success, $Skipped, $Total)
	If $Success Then
		$String = 'Успешно преобразовано файлов: ' & $Success
	Else
		$String = 'Нет преобразованных файлов.'
	EndIf
	If $Skipped Then $String &= @CRLF & 'Не требующих преобразования файлов: ' & $Skipped
	If $Success + $Skipped < $Total Then $String &= @CRLF & 'Ошибок обработки: ' & $Total - $Success - $Skipped
	_ResourcePlaySound("message", 1)
	MsgBox(0, $Title, $String)
	_ResourcePlaySound("button")
EndFunc   ;==>KotOR_Msg

Func KotOR_GetList($Folder)
	Local $mp3, $wav, $return
	$mp3 = _FileListToArray($Folder, '*.mp3', 1)
	If @error Then
		Dim $mp3[1]
		$mp3[0] = 0
	EndIf
	$wav = _FileListToArray($Folder, '*.wav', 1)
	If @error Then
		Dim $wav[1]
		$wav[0] = 0
	EndIf
	_ArrayConcatenate($mp3, $wav, 1)
	$mp3[0] = UBound($mp3) - 1
	Return $mp3
EndFunc   ;==>KotOR_GetList
