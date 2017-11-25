﻿#NoEnv
#SingleInstance force
SetBatchLines -1
ListLines Off
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.


sendmode input ;schnelligkeit erhöhen
SetWinDelay -1
SetControlDelay -1
SetMouseDelay -1
SetDefaultMouseSpeed, 0

version := "v1.0-beta_3"
inipath := A_AppData "\script_helper\"
FileCreateDir, %inipath%
SetWorkingDir, %inipath%
inifile := "optionsv2.ini"
githubversiontxt := "https://raw.githubusercontent.com/Martin-SF/script_helper_by_Peter_Holz/master/version.txt"

settingsread()
check_updates(version)
return

check_updates(ver) {
	global githubversiontxt
	URLDownloadToFile, %githubversiontxt% , %A_Temp%\version.txt 
	IniRead, dwnv , %A_Temp%\version.txt , version, version
	msgbox % ver . "   " . dwnv
	Clipboard =%A_Temp%\version.txt
	if (dwnv != ver) {
			Gui, Add, Link, x22 y9 w410 h160 +Center, New Version is out! (Your version: %ver%  latest: %dwnv%)`n`nDownload:`n <a href="https://github.com/Martin-SF/script_helper_by_Peter_Holz/releases">https://github.com/Martin-SF/script_helper_by_Peter_Holz/releases</a>     `n`nmade by peterholz donate:`n<a href="https://www.paypal.me/peterholz1">https://www.paypal.me/peterholz1</a>
		; Generated using SmartGUI Creator for SciTE
		Gui, Show, w450 h187, Update Notification - Script Helper by Peter Holz
	}
}

GuiClose:
gui, destroy
return

^4::
ListVars
return

^f6::
MsgBox, 4, , Close program?
IfMsgBox, Yes
	exitapp
return

; SHORTCUT UM PDF ZU ÖFFNEN / entsprechende pdf
^5:: 
open_c("sumatra",0)
return

~f5:: ;f5 nicht blockieren
	if ( !winactive("ahk_exe atom.exe") and !winactive("ahk_exe notepad++.exe") ) 
		return
	if (winactive("ahk_exe notepad++.exe")) {
		msgbox, for notepad++ still not stable!
		return
	}
	;mehrere texteditoren durchgehen dementsprechend filepath getten modifizieren
	;die entsprechende methode um alle paramater zu bekommen abhängig vom texteditor machen
	
	if (winactive("ahk_exe "conemuexe))
		open_c("sumatra",0)
	else {
		
		try 
			run_line()
		catch e
			MsgBox % e.message "`n`nError in " e.What ", which was called at line " e.Line "`nPlease contact peter.holz@hotmail.de with this error! (unless you did not configured the program wrong)"
	}

return


run_line() {
	;MAKE BENUTZEN
	;settingsread()
	global shortcut_ms
	
	keys_save_texteditor(shortcut_ms)
	
	scriptname := get_scriptname() ;erkennung für notepad ++ nicht fertig run_line nur für atom ausgelegt
	scriptfullpath := get_scriptfullpath_atom()
	StringReplace, scriptfullpath, scriptfullpath, \,/ , All
	scriptpath := SubStr(scriptfullpath, 1 , InStr(scriptfullpath, scriptname)-2)

	open_c("conemu",scriptpath)
	
	StringReplace, scriptpath, scriptpath, :, , All
	scriptpath := "/" + scriptpath
	;error wenn fenster gewechselt wurde
	if (WinGetActiveTitle() != scriptpath) ;FRAGEN OB WECHSELN ODER NICHT?
		SendInput cd "%scriptpath%"{enter} ;nur wenn im title von conemu nicht ath steht ;scriptname := % """" scriptpath "/" scriptname """"
	
	scripttype := get_scripttype(scriptname)
	SendInput %scripttype% %scriptname%{enter} ;eventl diesen befehl beim starten von conemu als parameter übergeben
}
WinGetActiveTitle() {
	WinGetActiveTitle, out
	return out
}

get_scriptname() {
	WinGetTitle, title, A
	if (winactive("ahk_exe atom.exe")!=0) {
		len_a := InStr(title, " — " )
		
		;NewStr := SubStr(String, StartingPos [, Length])
		scriptname := SubStr(title, 1 , Len_a-1)
	}
	else if (winactive("ahk_exe notepad++.exe")!=0) {
		msgbox notepad++.exe not supported yet!
		return
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
		msgbox notepad++.exe not supported yet!
		return
		ExitApp
	}
	return scriptname
}

get_scripttype(scriptname) {
	if (InStr(scriptname, ".tex"))
		return "lualatex"
	else if (InStr(scriptname, ".py"))
		return "python"
	else 
		throw Exception("script type not supported!`n`nonly .py (python) and .tex (latex)")
}

open_c(program,path) {
	
	;programme starparam übergeben : path 
	global conemuexe, conemupathexe, sumatraexe, sumatrapathexe, conemu_ms
	
	if (program = "conemu") {
		programexe := conemuexe
		
		;programpathexe := % conemupathexe . " -""" . path . """"
		programpathexe := % conemupathexe . " -here /single -run {Bash::Msys2-64}"
		
	} else if (program = "sumatra") {
		programexe := sumatraexe
		programpathexe := sumatrapathexe
	} else 
		throw Exception("unspecified program TRIED TO OPEN", -1)
		
	process, exist, %programexe%
	if (errorlevel=0) {
		run, %programpathexe%, %path%
		WinWaitActive, ahk_exe %programexe%
		
		if (program = "conemu") {
			
			static title := "ConEmu 170910 [64]"
			c := A_TickCount
			while (title = "ConEmu 170910 [64]" or title = "conemu-msys2-64") {
				WinGetTitle, title, A
				;sleep 50
				if (A_TickCount-c>=conemu_ms)  ;if (A_TickCount-c>=conemu_ms) {
					throw Exception("your pc is very slow. increase conemu_waittime! (in optionsv2.ini") ;message wird nicht im enddialog benutzt ändern
			}
		}
	}
	
	WinActivate, ahk_exe %programexe% ;TIMEOUTS
	WinWaitActive, ahk_exe %programexe%
	;sleep 100 ;custom sleep für ini
	;SetWorkingDir %A_ScriptDir%
}

get_scriptfullpath_atom(ms := "-1") {
	clip := Clipboard
	global shortcut_ms
	if (ms = -1)
		ms := shortcut_ms
	
	clipboard = ; Empty the clipboard
	keys_get_filedest(ms)
	ClipWait, 3
	if ErrorLevel
		throw Exception("clipboard error")
	f_scriptfullpath := Clipboard
	
	Clipboard := clip
	return f_scriptfullpath
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

keys_save_texteditor(ms) {
	global shortcut_ms
	if (ms = -1)
		ms := shortcut_ms
	sendinput {Lcontrol down}
	sendinput {s down}
	sleep ms
	sendinput {s up}
	sendinput {lcontrol up}
}

keys_get_filedest(ms) {
	global shortcut_ms
	if (ms = -1)
		ms := shortcut_ms
	sendinput {Lcontrol down}
	sendinput {shift down}
	sendinput {c down}
	sleep ms
	sendinput {c up}
	sendinput {shift up}
	sendinput {lcontrol up}
}

write_std_settings(n) {
	global inifile
	
	std_shortcut_waittime := 100
	std_conemu_waittime := 5000
	std_conemupathexe := "C:\Program Files\ConEmu\ConEmu64.exe"
	std_sumatrapathexe := "C:\Program Files\SumatraPDF\SumatraPDF.exe"

	if (n=1 or n=0)
		iniwrite, %std_shortcut_waittime%, %inifile%, settings, shortcut_waittime
	if (n=2 or n=0)
		iniwrite, %std_conemu_waittime%, %inifile%, settings, conemu_waittime
	
	if (n=3 or n=0)
		iniwrite, %std_conemupathexe%, %inifile%, settings, conemu64_path_exe
	
	if (n=4 or n=0)
		iniwrite, %std_sumatrapathexe%, %inifile%, settings, SumatraPDF_path_exe
}

settingsread() {
	global conemupathexe, sumatrapathexe, shortcut_ms, conemu_ms, inifile
	
	if !FileExist(inifile) 
		write_std_settings(0) 
	
	iniread, conemupathexe, %inifile%, settings, conemu64_path_exe
	iniread, sumatrapathexe, %inifile%, settings, SumatraPDF_path_exe
	
	if (check_program_availability()=false) {
		iniwrite, %conemupathexe%, %inifile%, settings, conemu64_path_exe
		iniwrite, %sumatrapathexe%, %inifile%, settings, SumatraPDF_path_exe
	}
	
	iniread, shortcut_ms, %inifile% ,settings , shortcut_waittime ;generelle funktion ür iniread mit entsprechendem fehler
	if (shortcut_ms = "ERROR")
		write_std_settings(1)

	iniread, conemu_ms, %inifile% ,settings , conemu_waittime
	if (conemu_ms = "ERROR") 
		write_std_settings(2)
	
}

check_program_availability() {
	
	global conemupathexe, sumatrapathexe
	boo := true
	; CONEMU	
	if (A_Is64bitOS=0) 
		throw Exception("32-bit not supported contact peter.holz@hotmail.de for support request`n`nProgram will exit now")
		
	if !FileExist(conemupathexe) { ;TRY benutzen für fehler in general
		boo := false
		;über WinGet, OutputVar [, Cmd, WinTitle, WinText, ExcludeTitle, ExcludeText] mit cmd := processname einfach auffordern conemu und sumatra einmal zu starten (wenn schon aktiv silent den processpath retrieven
		MsgBox, 32, , Please select the conemu64.exe path. `n`n(it will show a window after clicking ok)
		FileSelectFile, conemupathexe, 1,  %conemupathexe% , select your ConEmu64.exe path., Executables (*.exe)
	}
	global conemuexe := SubStr(conemupathexe, InStr(conemupathexe, "\", false, 0, 1)+1 , strlen(conemupathexe))
	
	;DAUERT SEHR LANGE BIS SICH DIE PROMPTS ÖFFNEN 

	;sumatra
	if !FileExist(sumatrapathexe) {
		boo := false
		MsgBox, 32, , Please select the sumatraPDF.exe path. `n`n(it will show a window after clicking ok)
		FileSelectFile, sumatrapathexe, 1, %sumatrapathexe% , select your sumatraPDF.exe path., Executables (*.exe)
	}
	global sumatraexe := SubStr(sumatrapathexe, InStr(sumatrapathexe, "\", false, 0, 1)+1 , strlen(sumatrapathexe))
		
	;atom
	
	;npp
	return boo
}
