#include-once
; #INDEX# =======================================================================================================================
; Title .........: Functions
; AutoIt Version : v3.3.6.0+
; Language ......: English, Russian
; Description ...: Various useful functions.
; Author(s) .....: xrewndel
; Last modified..: 2011.09.092
; ===============================================================================================================================

; *** File management ***
; FileGetAttribEx($Path)
; FileIsFile($Path)
; FileIsFolder($Path)
; FileIsReparse($Path)
; FileReadOffset($FileName, $Offset, $Size = Default)
; FileGetName($String)
; FileGetExtension($String)
; FileGetFolder($String)
;
; *** String / variables management ***
; StringBegins($String, $Substring)
; StringEnds($String, $Substring)
; VarTrim(ByRef $String, $Value)
; VarTrimMid(ByRef $String, $Start, $Count)
; VarInsert(ByRef $String, $Value, $Point)
;
; Declension($Number); возвращает номер элемента массива; массив должен содержать словоформы в виде ['год', 'года', 'лет']
; RunOnce($Title, $Code = 0); предотвращает повторный запуск одной и той же программы, требуется уникальный идентификатор $Title, можно указать код выхода $Code.
; NumberFillZeros($Number, $Length); заполняет целое число начальными нулями до указанной длины.
; Percent($Value, $Full); вычисляет процентное знчение величины.
; IsCompiled(); возвращает информацию о формате программы
; Bool($Value); Converts a string or variable to Boolean.
; StringIsAnsi($String); True if ANSI, False if Unicode
; IniReadWrite($File, $Section, $Key, $Default); Sets @extended to 1 if value was not exist, sets @error to 1 if cannot write value
; RegDeleteIfEmpty($Key)
; Copy($Source, $Destination, $Overwrite = False)
; Move($Source, $Destination, $Overwrite = False)
; DelSelf($Terminate = True)
; Terminate()

#region - File management
Func FileGetAttribEx($Path); WinAPI, получить атрибуты файловой записи в виде hex-числа.
	If Not FileExists($Path) Then Return SetError(1, 0, '')
	Local $Attrib = DllCall('kernel32.dll', 'Int', 'GetFileAttributes', 'str', $Path)
	If IsArray($Attrib) Then Return $Attrib[0]
EndFunc   ;==>FileGetAttribEx

Func FileIsFile($Path); указывает, является ли указанный объект файлом
	If Not FileExists($Path) Then Return SetError(1, 0, 0)
	If StringInStr(FileGetAttrib($Path), 'D') Then Return 0
	Return 1
EndFunc   ;==>FileIsFile

Func FileIsFolder($Path); указывает, является ли указанный объект папкой
	If Not FileExists($Path) Then Return SetError(1, 0, 0)
	If StringInStr(FileGetAttrib($Path), 'D') Then Return 1
	Return 0
EndFunc   ;==>FileIsFolder

Func FileIsReparse($Path); указывает, является ли указанный объект связью / символической ссылкой
	If Not FileExists($Path) Then Return SetError(1, 0, 0)
	If BitAND(FileGetAttribEx($Path), 0x400) = 0x400 Then Return 1
	Return 0
EndFunc   ;==>FileIsReparse

Func FileReadOffset($FileName, $Offset, $Size = Default); прочитать произвольный фрагмент файла
	Local $hFile, $Switch
	$hFile = FileOpen($FileName)
	If @error Then Return SetError(1, 0, '')
	$Offset = Round($Offset)
	$Size = Round($Size)
	If $Offset < 0 Then $Switch = 1
	FileSetPos($hFile, Abs($Offset), $Switch)
	Return FileRead($hFile, $Size)
EndFunc   ;==>FileReadOffset

Func FileGetName($String)
	Local $a
	$String = StringTrimLeft($String, StringInStr($String, '\', '', -1))
	$a = StringInStr($String, '.', '', -1)
	If Not $a Then
		Return $String
	Else
		Return StringLeft($String, $a - 1)
	EndIf
EndFunc   ;==>FileGetName

Func FileGetExtension($String)
	Local $a
	$a = StringInStr($String, '.', -1, -1)
	If Not $a Then Return ''
	Return StringTrimLeft($String, $a)
EndFunc   ;==>FileGetExtension

Func FileGetFolder($String)
	Return StringLeft($String, StringInStr($String, '\', '', -1))
EndFunc   ;==>FileGetFolder
#endregion - File management

#region - String / variables management
Func StringBegins($String, $Substring)
	If StringLeft($String, StringLen($Substring)) = $Substring And Not ($Substring = "") Then Return True
	Return False
EndFunc   ;==>StringBegins

Func StringEnds($String, $Substring)
	If StringRight($String, StringLen($Substring)) = $Substring And Not ($Substring = "") Then Return True
	Return False
EndFunc   ;==>StringEnds

Func VarTrim(ByRef $String, $Len)
	Local $Return
	If $Len = Default Then $Len = 0
	$Len = Round($Len)
	If $Len > 0 Then
		$Return = StringLeft($String, $Len)
		$String = StringTrimLeft($String, $Len)
	Else
		$Return = StringRight($String, Abs($Len))
		$String = StringTrimRight($String, Abs($Len))
	EndIf
	If StringLen($Return) < Abs($Len) Then SetError(1)
	Return SetError(@error, '', $Return)
EndFunc   ;==>VarTrim

Func VarTrimMid(ByRef $String, $Start, $Count)
	Local $Return, $Length
	$Start = Round($Start)
	$Count = Round($Count)
	$Return = StringMid($String, $Start, $Count)
	$String = StringLeft($String, $Start - 1) & StringTrimLeft($String, $Start + StringLen($Return) - 1)
	Return $Return
EndFunc   ;==>VarTrimMid

Func VarInsert(ByRef $String, $Value, $Point)
	$Point = Round($Point)
	$String = StringLeft($String, $Point - 1) & $Value & StringTrimLeft($String, $Point - 1)
EndFunc   ;==>VarInsert
#endregion - String / variables management

Func Declension($Number); возвращает номер элемента массива; массив должен содержать словоформы в виде ['год', 'года', 'лет']
	If Not (Round($Number) = Number($Number)) Then Return SetError(1, '', -1); Ошибка 1, если не целое
	$Number = Round($Number)
	If Abs(Mod($Number, 10)) = 1 And Abs(Mod($Number, 100)) <> 11 Then Return 0
	If Abs(Mod($Number, 10)) > 1 And Abs(Mod($Number, 10)) < 5 And Floor(Abs(Mod($Number, 100)) / 10) <> 1 Then Return 1
	Return 2
EndFunc   ;==>Declension

Func RunOnce($Title, $Code = 0); предотвращает повторный запуск одной и той же программы, требуется уникальный идентификатор $Title, можно указать код выхода $Code.
	If $Code = Default Then $Code = 0
	$Code = Round($Code)
	Local $Mode = AutoItSetOption('WinTitleMatchMode', 3)
	If WinExists($Title) Then Exit $Code
	AutoItWinSetTitle($Title)
	AutoItSetOption('WinTitleMatchMode', $Mode)
EndFunc   ;==>RunOnce

Func NumberFillZeros($Number, $Length); заполняет целое число начальными нулями до указанной длины.
	Local $i
	$Length = Round($Length)
	$Number = Round($Number)
	For $i = 1 To $Length - StringLen(Round($Number))
		$Number = '0' & $Number
	Next
	Return $Number
EndFunc   ;==>NumberFillZeros

Func Percent($Value, $Full); вычисляет процентное знчение величины.
	If Not Number($Full) Then Return SetError(1, 0, '')
	Return ($Value / $Full) * 100
EndFunc   ;==>Percent

Func IsCompiled(); возвращает информацию о формате программы
	If Not @Compiled Then
		Return 0; нескомпилированный (au3)
	ElseIf @ScriptFullPath = @AutoItExe Then
		Return 1; скомпилированный (exe)
	Else
		Return 2; скомпилированный (a3x)
	EndIf
EndFunc   ;==>IsCompiled

Func Bool($Value); Converts a string or variable to Boolean.
	Return Not Not Int($Value)
EndFunc   ;==>Bool

Func StringIsAnsi($String); True if ANSI (current CP), False if Unicode
	If BinaryToString(StringToBinary($String)) == $String Then Return True
	Return False
EndFunc   ;==>StringIsAnsi

Func IniReadWrite($File, $Section, $Key, $Default); Sets @extended to 1 if value was not exist, sets @error to 1 if cannot write value
	Local $Value
	$Value = IniRead($File, $Section, $Key, 'False')
	If $Value = 'False' And IniRead($File, $Section, $Key, 'True') = 'True' Then
		FileClose(FileOpen($File, 0x21)); create UTF-16 LE $File if not exist
		If Not IniWrite($File, $Section, $Key, $Default) Then Return SetError(1, '', '')
		SetExtended(1)
	Else
		Return $Value
	EndIf
EndFunc   ;==>IniReadWrite

Func RegDeleteIfEmpty($Key)
	Local Static $Count
	RegEnumVal($Key, 1)
	If @error <> -1 Then Return SetError(0, Bool(@error), Bool(@error))
	Local $i, $extended, $SubKey, $a
	While True
		$i += 1
		$SubKey = RegEnumKey($Key, $i)
		If @error = -1 Then ExitLoop
		$Count += 1
		$a = RegDeleteIfEmpty($Key & '\' & $SubKey)
		$extended = @extended
		$Count -= 1
		If Not $a Then Return SetError(0, $extended, 0)
	WEnd
	If Not $Count Then RegDelete($Key)
	Return 1
EndFunc   ;==>RegDeleteIfEmpty

Func Copy($Source, $Destination, $Overwrite = False)
	If Not FileExists($Source) Then Return SetError(1, 0, 0)
	$Overwrite = Bool($Overwrite)
	DirCopy($Source, $Destination, $Overwrite)
	FileCopy($Source, $Destination, 8 + $Overwrite)
EndFunc   ;==>Copy

Func Move($Source, $Destination, $Overwrite = False)
	If Not FileExists($Source) Then Return SetError(1, 0, 0)
	$Overwrite = Bool($Overwrite)
	DirMove($Source, $Destination, $Overwrite)
	FileMove($Source, $Destination, 8 + $Overwrite)
EndFunc   ;==>Move

Func DelSelf($Terminate = True)
	Local $Delete, $hFile
	$Terminate = Bool($Terminate)
	If IsCompiled() = 1 Then
		$Delete = _TempFile('', '~', '.bat')
		EnvSet('program', @ScriptFullPath)
		$hFile = FileOpen($Delete, 2)
		FileWriteLine($hFile, ':loop')
		FileWriteLine($hFile, 'ping 127.0.0.1')
		FileWriteLine($hFile, 'del "%program%"')
		FileWriteLine($hFile, 'if exist "%program%" goto loop')
		FileWriteLine($hFile, 'del %0')
		FileClose($hFile)
		Run($Delete, @TempDir, @SW_HIDE)
	Else
		FileDelete(@ScriptFullPath)
	EndIf
	If $Terminate Then
		OnAutoItExitRegister('Terminate')
		Exit
	EndIf
EndFunc   ;==>DelSelf

Func Terminate()
	Exit
EndFunc   ;==>Terminate
