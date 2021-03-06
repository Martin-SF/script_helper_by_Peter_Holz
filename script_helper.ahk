﻿{
#NoEnv
#SingleInstance force
SetBatchLines -1
ListLines Off
#Warn
SendMode Input

sendmode input ;schnelligkeit erhöhen
SetWinDelay -1
SetControlDelay -1
SetMouseDelay -1
SetDefaultMouseSpeed, 0
}

/* ideas section
- Bei protokoll eine V*.tex suchen und die ausführen anstatt durchführung.tex etc.
	- oder eine regel anlegen wo das programm einmal fragt nach einer main tex datei
	- NEU: einfach Ordner V* suchen und diesen nehmen (nach struktur V*/latex suchen und entsprechen suchpositionen nutzen um V505 zb. rauszufiltern.
		dann, wenn im "latex" (vielleicht allgemeiner bestimmen?, das man einmal gefragt wird ob lieber V505.tex anstatt auswertung.tex gemacht werden soll, das wird gespeichert unter neuer ini datei sektion.
	
- F5 in conemu versucht die gestartete .tex datei als pdf zu öffnen wenn vorhanden
- Der update checker versucht schon am anfang runterzuladen

- updater kriegt als start parameter url und version.

- make benutzen

if (A_IsCompiled=1)
	Hotkey, *^1, off
	
- ein [ settimer label / beim start ] was anderen instanzen / versioen beendet.
	
- den build order erstellen falls nicht vorhanden

- einfügen crtl v anstatt sendinput

- compilier fehler erkennen und mit ctrl + z ausführung beenden

- beim starten meistens fehler! anfang abgeschnitten

- extra modus mit f5: es werden noch diese befehle nachher ausgeführt:
	cd build; biber V201; cd ..; lualatex...
	ODER: ordentliche make-file
	
- permanente kontroll Gui und hotkey gui (info was was ist.) 
	- kann minimiert werden in taskleiste
	- gibt permanentes "update" textfeld mit allen bisheringen update fenster sachen.
	- beim start tooltip mit information update
	
- alle funktionen wie keys_save_texteditor(ms), wo ein standard werd genommen wird bei bestimmten einganeparametern 
	->  keys_save_texteditor(ms := global shortcut_ms)

- hotkey um gecrashtes latex automatisch neuzukompilieren (X, strg+c dann pfeil nach oben und enter) alles wenn conemu an ist.

- wenn makefile da ist, diesen ausführen. (eine meldung für fragen nach standard prozedur fragen.

- rechtsklick auf icon ermöglichs das update checken.

- anhand der letzten eingabe erkennen ob er "X" wegen latex benutzen muss zum schliessen


//// BUGS:

- Konsole erkennt befehle nicht weil sie nur teilweise da stehen. -> eingabezeiten verändern.
- nach drücken von f5 wird console geöffnet und dann schließt sie sich. (eventuell das schließen erkenen und automatisch 
	neu starten, bzw. in verdacht stehende parameter überwachen und in spezielle datei schreiben
	
	
	
////	changelog bisher:

- vor strg+c wird ein X gesendet um eventuelle Latex compilierungen ordentlich zu stoppen.

*/

inipath := A_AppData "\script_helper\"
FileCreateDir, %inipath%
SetWorkingDir, %inipath%
inifile := "optionsv2.ini"
FileDelete, %A_Temp%\script_version.txt 
fileinstall, version.txt, %A_Temp%\script_version.txt 
version_txt_url := "https://raw.githubusercontent.com/Martin-SF/script_helper_by_Peter_Holz/master/version.txt"

settingsread()
check_updates(version_txt_url)
return

check_updates(verurl) {
	URLDownloadToFile, %verurl% , %A_Temp%\current_version.txt
	IniRead, dwnv , %A_Temp%\current_version.txt , version, version
	IniRead, ver , %A_Temp%\script_version.txt , version, version
	if (Errorlevel != 1 and dwnv != ver) {
		Hotkey, ^f6, off
		Hotkey, ^5, off
		Hotkey, ~f5, off
			Gui, Add, Link, x22 y9 w410 h160 +Center, New Version is out! (Your version: %ver%  latest: %dwnv%)`n`nDownload:`n <a href="https://github.com/Martin-SF/script_helper_by_Peter_Holz/releases">https://github.com/Martin-SF/script_helper_by_Peter_Holz/releases</a>     `n`nmade by peterholz donate:`n<a href="https://www.paypal.me/peterholz1">paypal.me/peterholz1</a>
		Gui, Show, w450 h187, Update Notification - Script Helper by Peter Holz
	}
}

GuiClose:
	gui, destroy
	Hotkey, ^f6, on
	Hotkey, ^5, on
	Hotkey, ~f5, on
return

*^1::
run, % inipath . "\" . inifile
return

^2::
ListVars
return

^f6::
MsgBox, 4, , Close program?
IfMsgBox, Yes
	exitapp
return

; SHORTCUT UM PDF ZU ÖFFNEN / entsprechende pdf
^5:: 
open_c(sumatraexe,sumatrapathexe)
return

~f5:: ;f5 nicht blockieren
	if (winactive("ahk_exe SciTE.exe"))
		exitapp

	if (winactive("ahk_exe notepad++.exe")) {
		msgbox, for notepad++ still not stable!
		return
	}
	;mehrere texteditoren durchgehen dementsprechend filepath getten modifizieren
	;die entsprechende methode um alle paramater zu bekommen abhängig vom texteditor machen
	
	if (winactive("ahk_exe "conemuexe)) {
		clearconsole(1)
		/*
			eine globale variable speichert zuletzte Datei
			if ("last_var hat Form V*.tex")
			dann wenn da öffne die V*.tex datei in sumatra
		
		*/
		open_c(sumatraexe,sumatrapathexe) ;wenn scripttype tex ist dann .pdf öffnen
	}
	else if (winactive("ahk_exe atom.exe") or winactive("ahk_exe notepad++.exe") ){
		try 
			run_line()
		catch e
			MsgBox % e.message "`n`nError in " e.What ", which was called at line " e.Line "`nPlease contact peter.holz@hotmail.de with this error! (unless you did not configured the program wrong)"
	}

return


clearconsole(a := 0){
	global clearmethod
	if (a=1) {
		Sendinput {backspace}
		sleep 0
	} else {
		/*
		it := 30
		;SendInput {control down} {right %it%} {control up} {shift down} {left} {control down} {left %it%} {shift up} {control up} {del}
		;mit der selektierung kein löschen mögich ...
		
		Send {control down} {right %it%} {backspace 100} {control up}
		;löscht nicht mit peiltasten hochgeholte befehle....
		
		Sendinput _this got cleared by script_helper {enter}
		*/
		if (clearmethod=0)
			sendinput {shift down}{home}{del}{end}{right 2}{del}{shift up}{right 2}{del}{shift up}{backspace 10} ;{enter}
		else if (clearmethod=1)
			Sendinput X{enter}{control down}c{control up} ;müsste gleichzeitig alle build dateien aufräumen damit keine komischen fehelr auftreten
		else if (clearmethod=2)
			Sendinput {control down}{left 50}{control up}line_defused_by_script_helper{enter}
	}	
}

run_line() {
	global shortcut_ms, conemuexe, conemupathexe
	
	keys_save_texteditor(shortcut_ms)
	
	scriptname := get_scriptname() ;erkennung für notepad ++ nicht fertig run_line nur für atom ausgelegt
	scripttype := get_scripttype(scriptname)
	scriptfullpath := get_scriptfullpath_atom()
	
	scriptpath := trafo_scriptpath(scriptfullpath, scriptname)
	
	/* 
		nach V*.tex suchen und ausführen falls da
		-> später mit zb. shift+f5 V*.tex ausführen
	*/

	open_c(conemuexe, conemupathexe, scriptpath)
	
	StringReplace, scriptpath, scriptpath, :, , All
	scriptpath := "/" + scriptpath
	
	;nachfolgenden bereich aktiv unterstützen, dass keine fehler bei eingabe passieren
	
	;error wenn fenster gewechselt wurde
	if (WinGetActiveTitle() != scriptpath) ;FRAGEN OB verz. WECHSELN ODER NICHT?
		SendInput cd "%scriptpath%"; ;nur wenn im title von conemu nicht ath steht ;scriptname := % """" scriptpath "/" scriptname """"
	
	SendInput %scripttype% %scriptname%{enter} ;eventl diesen befehl beim starten von conemu als parameter übergeben
}

trafo_scriptpath(s,d) {
	StringReplace, s, s, \,/ , All
	return SubStr(s, 1 , InStr(s, d)-2)
}

WinGetActiveTitle() {
	WinGetActiveTitle, s
	return s
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
		return "lualatex -output-directory=build"
	else if (InStr(scriptname, ".py"))
		return "python"
	else 
		throw Exception("script type not supported!`n`nonly .py (python) and .tex (latex)")
}

open_c(programexe, programpathexe, path := "") {
	
	;programme starparam übergeben : path 
	global conemu_ms, send_ms
	p := 0
	newstarted := 0
	
	if (InStr(programexe, "conemu")) {
		programpathexe .= " -here /single -run {Bash::Msys2-64}"
		p := 1
	}
	
	/*
	} else 
		throw Exception("unspecified program TRIED TO OPEN", -1)
	*/
		
	process, exist, %programexe%
	if (errorlevel=0) {
		newstarted := 1
		run, %programpathexe%, %path%
		WinWaitActive, ahk_exe %programexe%
		
		if (p = 1) {
			static title := "ConEmu 170910 [64]"
			c := A_TickCount
			while (title = "ConEmu 170910 [64]" or title = "conemu-msys2-64") {
				WinGetTitle, title, A
				sleep 0
				if (A_TickCount-c >= conemu_ms)  ;if (A_TickCount-c>=conemu_ms) {
					throw Exception("your pc is very slow. increase conemu_waittime! (in %APPDATA%\script_helper\optionsv2.ini") ;message wird nicht im enddialog benutzt ändern
			}
		}
	}
	
	WinActivate, ahk_exe %programexe% ;TIMEOUTS
	WinWaitActive, ahk_exe %programexe%
	sleep send_ms
	if (newstarted = 0 and p = 1) {
		clearconsole()
	}
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
	loop 3
		sendinput {tab down} {tab up}
	Sendinput {enter down} {enter up}
}

keys_save_texteditor(ms) { ;idee(gilt für alle anderen auch):  keys_save_texteditor(ms := global shortcut_ms)
	global shortcut_ms
	if (ms = -1)
		ms := shortcut_ms
	sendinput {Lcontrol down}{s down}
	sleep ms
	sendinput {s up}{lcontrol up}
}

keys_get_filedest(ms) {
	global shortcut_ms
	if (ms = -1)
		ms := shortcut_ms
	sendinput {Lcontrol down}{shift down}{c down}
	sleep ms
	sendinput {c up}{shift up}{lcontrol up}
}

write_std_settings(n) {
	global inifile
	
	std_shortcut_waittime := 100
	std_send_ms := 50
	std_conemu_waittime := 5000
	std_clearmethod := 1
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
	if (n=5 or n=0)
		iniwrite, %std_clearmethod%, %inifile%, settings, clearing_method_in_conemu
	if (n=6 or n=0)
		iniwrite, %std_send_ms%, %inifile%, settings, wait_for_conemu_input_in_ms
	settingsread()
}

settingsread() {
	global conemupathexe, sumatrapathexe, shortcut_ms, conemu_ms, inifile, clearmethod, send_ms
	
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
	
	iniread, clearmethod, %inifile% ,settings , clearing_method_in_conemu
	if (clearmethod = "ERROR") 
		write_std_settings(5)
	
	iniread, send_ms, %inifile% ,settings , wait_for_conemu_input_in_ms
	if (send_ms = "ERROR") 
		write_std_settings(6)
	
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
