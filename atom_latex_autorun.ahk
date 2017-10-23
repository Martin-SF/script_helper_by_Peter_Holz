#NoEnv
#SingleInstance, force
SetBatchLines -1
ListLines Off
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


sendmode input ;schnelligkeit erhöhen
SetWinDelay -1
SetControlDelay -1
SetMouseDelay -1
SetDefaultMouseSpeed, 0

settingsread()
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
	;die entsprechende methode uma alle paramater zu bekommen abhängig vom texteditor machen

	
	try 
		run_line()
	catch e
		MsgBox % "Error in " e.What ", which was called at line " e.Line "`n`nPlease contact peter.holz@hotmail.de with this error! (unless you did not configured the program wrong)"

return


run_line() {
	global
	;MAKE BENUTZEN
	;settingsread()
	
	keys_save_texteditor(shortcut_ms)
	
	WinGetTitle, title, A
	
	;atom oder notepad?
	
	if (winactive("ahk_exe atom.exe")!=0) {
		;msgbox 3
		len_a := InStr(title, " — " )
		
		;NewStr := SubStr(String, StartingPos [, Length])
		scriptname := SubStr(title, 1 , Len_a-1)
	}
	else if (winactive("ahk_exe notepad++.exe")!=0) {
		msgbox notepad++.exe not supported yet!
		return
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
		msgbox notepad++.exe not supported yet!
		return
		ExitApp
	}
	

	
	
	scriptfullpath := get_scriptfullpath_for_atom()
	StringReplace, scriptfullpath, scriptfullpath, \,/ , All
		
	scriptpath := SubStr(scriptfullpath, 1 , InStr(scriptfullpath, scriptname)-2)

	open_c("conemu",scriptpath)
	
	StringReplace, scriptpath, scriptpath, :, , All
	scriptpath := "/" + scriptpath
	
	WinGetTitle, title, A
	if (title != scriptpath) ;FRAGEN OB WECHSELN ODER NICHT?
		 SendInput cd "%scriptpath%"{enter} ;nur wenn im title von conemu nicht ath steht ;scriptname := % """" scriptpath "/" scriptname """"
	
	scripttype := get_scripttype(scriptname)
	SendInput %scripttype% %scriptname%{enter}
}

get_scripttype(scriptname) {
	if (InStr(scriptname, ".tex"))
		return "lualatex"
	else if (InStr(scriptname, ".py"))
		return "python"
	else {
		msgbox script type not supported!`n`nonly .py (python) and .tex (latex)
		throw Exception("script type not supported!", -1)
	}
}

open_c(program,path) {
	
	global ;programme starparam übergeben : path 
	
	SetWorkingDir, %path%
	
	if (program = "conemu") {
		programexe := conemuexe
		
		;programpathexe := % conemupathexe . " -""" . path . """"
		programpathexe := % conemupathexe . " -here /single -run {Bash::Msys2-64}"

	} else if (program = "sumatra") {
		programexe := sumatraexe
		programpathexe := sumatrapathexe
	} else 
		throw Exception("unspecified program used in variable", -1)

	process, exist, %programexe%
	if (errorlevel=0) {
		run, %programpathexe%
		WinWaitActive, ahk_exe %programexe%
		
		if (program = "conemu") {
			
			title := "ConEmu 170910 [64]"
			c := A_TickCount
			while (title = "ConEmu 170910 [64]" or title = "conemu-msys2-64") {
				WinGetTitle, title, A
				;sleep 50
				if (A_TickCount-c>=conemu_ms) { ;if (A_TickCount-c>=conemu_ms) {
					msgbox your pc is very slow. increase conemu_waittime!
					throw Exception("conemu time to low", -1) ;message wird nicht im enddialog benutzt ändern
				}
			}
		}
	} 
	
	WinActivate, ahk_exe %programexe% ;TIMEOUTS
	WinWaitActive, ahk_exe %programexe%
	sleep 100 ;custom sleep für ini
	SetWorkingDir %A_ScriptDir%
}

get_scriptfullpath_for_atom() {
	clip := Clipboard
	
	clipboard = ; Empty the clipboard
	keys_get_filedest(shortcut_ms)
	ClipWait, 1
	if ErrorLevel
	{
		MsgBox, clipboard error
		return
	}
	scriptfullpath := Clipboard
	
	Clipboard := clip
	return scriptfullpath
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

keys_save_texteditor(shortcut_ms) {
	sendinput {Lcontrol down}
	sendinput {s down}
	sleep shortcut_ms
	sendinput {s up}
	sendinput {lcontrol up}
}

keys_get_filedest(shortcut_ms) {
	sendinput {Lcontrol down}
	sendinput {shift down}
	sendinput {c down}
	sleep shortcut_ms
	sendinput {c up}
	sendinput {shift up}
	sendinput {lcontrol up}
}

write_std_settings(n) {
	std_shortcut_waittime := 100
	std_conemu_waittime := 5000
	std_conemupathexe := "C:\Program Files\ConEmu\ConEmu64.exe"
	std_sumatrapathexe := "C:\Program Files\SumatraPDF\SumatraPDF.exe"

	if (n=1 or n=0)
		iniwrite, %std_shortcut_waittime%, optionsv2.ini, settings, shortcut_waittime
	if (n=2 or n=0)
		iniwrite, %std_conemu_waittime%, optionsv2.ini, settings, conemu_waittime
	
	;iniwrite, "C:\Program Files\ConEmu\ConEmu64.exe", optionsv2.ini, settings, conemu64_path_exe
	;conemupathexe := "e:\Programme\Tools\Toolbox_programs\ConEmu\ConEmu64.exe" 
	if (n=3 or n=0)
		iniwrite, %std_conemupathexe%, optionsv2.ini, settings, conemu64_path_exe
	
	;iniwrite, "C:\Program Files\SumatraPDF\SumatraPDF.exe", optionsv2.ini, settings, SumatraPDF_path_exe
	;sumatrapathexe := "e:\Programme\Tools\Toolbox_programs\SumatraPDF\SumatraPDF.exe"
	if (n=4 or n=0)
		iniwrite, %std_sumatrapathexe%, optionsv2.ini, settings, SumatraPDF_path_exe
	
}

settingsread() {
	global
	
	if !FileExist("optionsv2.ini") 
		write_std_settings(0) 
	
	iniread, conemupathexe, optionsv2.ini, settings, conemu64_path_exe
	iniread, sumatrapathexe, optionsv2.ini, settings, SumatraPDF_path_exe
	
	
	check_program_availability()
	if (err_check_program_availability=1) {
		iniwrite, %conemupathexe%, optionsv2.ini, settings, conemu64_path_exe
		iniwrite, %sumatrapathexe%, optionsv2.ini, settings, SumatraPDF_path_exe
	}
	
	iniread, shortcut_ms, optionsv2.ini ,settings , shortcut_waittime, ERR ;generelle funktion ür iniread mit entsprechendem fehler
	if (p = "ERR") ;try und catch benutzen
		write_std_settings(1)

	iniread, conemu_ms, optionsv2.ini ,settings , conemu_waittime, ERR
	if (p = "ERR") 
		write_std_settings(2)
	
	;DEBUG VALUES

}

check_program_availability(){
	global
	
	; CONEMU	
	if (A_Is64bitOS=1) {
		if !FileExist(conemupathexe) { ;TRY benutzen für fehler in general
			err_check_program_availability = 1
			;über WinGet, OutputVar [, Cmd, WinTitle, WinText, ExcludeTitle, ExcludeText] mit cmd := processname einfach auffordern conemu und sumatra einmal zu starten (wenn schon aktiv silent den processpath retrieven
			;InputBox, conemupathexe , type in your full ConEmu64.exe path. It wasnt found., , , 800, 120, , , , , %conemupathexe% 
			
			;FileSelectFile, OutputVar [, Options, RootDir\Filename, select your ConEmu64.exe path., Executables (*.exe)]
			MsgBox, 32, , Please select the conemu64.exe path. `n`n(it will show a window after clicking ok)
			FileSelectFile, conemupathexe, 1,  %conemupathexe% , select your ConEmu64.exe path., Executables (*.exe)
		}
		conemuexe := SubStr(conemupathexe, InStr(conemupathexe, "\", false, 0, 1)+1 , strlen(conemupathexe))

	} else {
		msgbox 32-bit not supported contact peter.holz@hotmail.de for support request`n`nProgram will exit now
		exitapp
	}
		
	;sumatra

	while !FileExist(sumatrapathexe) {
		;InputBox, sumatrapathexe , type in your full sumatra.exe path. It wasnt found., , , 600, 120, , , , , %sumatrapathexe%
		err_check_program_availability = 1
		MsgBox, 32, , Please select the sumatra.exe path. `n`n(it will show a window after clicking ok)
			FileSelectFile, conemupathexe, 1, %sumatrapathexe% , select your sumatra.exe path., Executables (*.exe)
	}
	sumatraexe := SubStr(sumatrapathexe, InStr(sumatrapathexe, "\", false, 0, 1)+1 , strlen(sumatrapathexe))
		
			;atom
	
	;npp
}
