﻿#NoEnv
SetBatchLines -1
ListLines Off

sendmode input ;schnelligkeit erhöhen
SetWinDelay -1
SetControlDelay -1
SetMouseDelay -1
SetDefaultMouseSpeed, 0

#SingleInstance, force

settingsread()
check_program_availability()
return

check_program_availability(){
	global
	
	; CONEMU	
	if (A_Is64bitOS=1) {
		conemuexe := "conemu64.exe"
		;conemupathexe := "e:\Programme\Tools\Toolbox_programs\ConEmu\ConEmu64.exe" 
		conemupathexe := "C:\Program Files\ConEmu\ConEmu64.exe"
			IfnotExist, %conemupathexe% 
				InputBox, conemupathexe , type in your conemu64.exe path it wasnt found in \program files `n(with conemu64.exe at the end), , , 400, 120, , , , , %conemupathexe% 
			; STABILE LÖSUNG NÖTIG
	} else {
		msgbox 32-bit not supported contact peter.holz@hotmail.de for support reqeust`n`nProgram will exit now
		exitapp

	}

	;atom
	
	;npp

	;sumatra

	sumatraexe := "SumatraPDF.exe"
	sumatrapathexe := "e:\Programme\Tools\Toolbox_programs\SumatraPDF\SumatraPDF.exe"
	sumatrapathexe := "C:\Program Files\SumatraPDF\SumatraPDF.exe"
	IfnotExist, %sumatrapathexe% 
		InputBox, sumatrapathexe , type in your sumatra path it wasnt found in \program files `n(with conemu64.exe at the end), , , 200, 120, , , , , %sumatrapathexe%

}
;PATH SPEICHERN


^4::
ListVars
return

^f6::
MsgBox, 4, , Close program?
IfMsgBox, Yes
	exitapp
return

; SHORTCUT UM PDF ZU ÖFFNEN / entsprechende pdf
^5:: ;GEHT NICHT
open_c("sumatra",0)
return

~f5:: ;f5 nicht blockieren
	if ( !winactive("ahk_exe atom.exe") and !winactive("ahk_exe notepad++.exe") ) 
		return
	
	;mehrere texteditoren durchgehen dementsprechend filepath getten modifizieren
	;die entsprechende methode uma alle paramater zu bekommen abhängig vom texteditor machen

	keys_save_texteditor()
	
	run_line()

return





run_line() {
	global
	;MAKE BENUTZEN
	iniread, shortcut_ms, options.ini,settings , shortcut_waittime
	
	WinGetTitle, title, A
	
	;atom oder notepad?
	
	;FoundPos := InStr(Haystack, Needle [, CaseSensitive = false, StartingPos = 1, Occurrence = 1])
	if (winactive("ahk_exe atom.exe")!=0) {
		;msgbox 3
		len_a := InStr(title, " — " )
		
		;NewStr := SubStr(String, StartingPos [, Length])
		scriptname := SubStr(title, 1 , Len_a-1)
	}
	else if (winactive("ahk_exe notepad++.exe")!=0) {
		;msgbox 12
		keys_close_run_npp()
		;ControlSend, Edit1, {Alt down}f{Alt up}, Untitled - Notepad
		
		;sleep 500
		t1 := title
		while (title<=20) 
			WinGetTitle, title, A
		;C:\Users\m7fel\CloudStation\C++ & AHK Projekte\Autohotkey\Skripte und Programme\sonstige Projekte\atom comemu atom\atom_latex_autorun.ahk - Notepad++
		len_a := InStr(title, " - " )
		len_b := InStr(title, "\" ,,StartingPos = 0)
		scriptname := SubStr(title, len_b+1 , Len_a-3)
		msgbox, % scriptname 
	} else {
		msgbox, % title
		ExitApp
	}
	
	if (InStr(scriptname, ".tex"))
		scripttype := "lualatex"
	else if (InStr(scriptname, ".py"))
		scripttype := "python"
	else {
		msgbox script type not supported!
		return
	}
	
	clip := Clipboard
	
	clipboard = ; Empty the clipboard
	keys_get_filedest()
	ClipWait, 1
	if ErrorLevel
	{
		MsgBox, clipboard error
		return
	}
	scriptfullpath := Clipboard
	
	Clipboard := clip


	
	
	StringReplace, scriptfullpath, scriptfullpath, \,/ , All
	
	len_c := InStr(scriptfullpath, scriptname)
	
	scriptpath := SubStr(scriptfullpath, 1 , Len_c-2)
	open_c("conemu",scriptpath)
	
	
	WinGetTitle, title, A
	len_a := InStr(title, scriptpath)
	
	SendInput cd "%scriptpath%"{enter} ;nur wenn im title von conemu nicht ath steht ; CONEMU MIT STARTPARAM ÖFFNEN
	
	SendInput %scripttype% %scriptname%{enter}
	
	
}

open_c(program,path) {
	
	global ;programme starparam übergeben : path 
	
	if (program = "conemu") {
		programexe := conemuexe
		programpathexe := conemupathexe
	} else if (program = "sumatra") {
		programexe := sumatraexe
		programpathexe := sumatrapathexe
	}

	process, exist, %programexe%
	if (errorlevel=0) {
		run, %programpathexe%
		WinWaitActive, ahk_exe %programexe%
		if (program = "conemu") 
			sleep conemu_ms ;warten bis command line da ist
	} else {
		WinActivate, ahk_exe %programexe% ;TIMEOUTS
		WinWaitActive, ahk_exe %programexe%
	}
	
	
}

keys_close_run_npp() {
	
	sendinput {tab down}
	sendinput {tab up}
	
	sendinput {tab down}
	sendinput {tab up}
	
	sendinput {tab down}
	sendinput {tab up}
	
	Sendinput {enter down}
	Sendinput {enter up}
}

keys_save_texteditor() {
	global
	sendinput {Lcontrol down}
	sendinput {s down}
	sleep shortcut_ms
	sendinput {s up}
	sendinput {lcontrol up}
}

keys_get_filedest(){
	global
	sendinput {Lcontrol down}
	sendinput {shift down}
	sendinput {c down}
	sleep shortcut_ms
	sendinput {c up}
	sendinput {shift up}
	sendinput {lcontrol up}
}

settingsread() {
	global
	IfNotExist, options.ini 
		iniwrite, 100, options.ini, settings, shortcut_waittime
	IfNotExist, options.ini 
		iniwrite, 3000, options.ini, settings, conemu_waittime
	
	iniread, shortcut_ms, options.ini ,settings , shortcut_waittime
	iniread, conemu_ms, options.ini ,settings , conemu_waittime
}
