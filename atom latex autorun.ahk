#NoEnv
SetBatchLines -1
ListLines Off

sendmode input ;schnelligkeit erhöhen
SetWinDelay -1
SetControlDelay -1
SetMouseDelay -1
SetDefaultMouseSpeed, 0

#SingleInstance, force

iniread()

;conemu_ms

check_program_availability(){
	
	
; CONEMU	
if (A_Is64bitOS=1) {
	conemuexe := "conemu64.exe"
	conemupathexe := "C:\Program Files\ConEmu\ConEmu64.exe"
		IfnotExist, %conemupathexe% 
			InputBox, conemupathexe , type in your conemu64.exe path it wasnt found in \program files `n(with conemu64.exe at the end), , , 200, 120, , , , , %conemupathexe%
		; STABILE LÖSUNG NÖTIG
} else {
	msgbox 32-bit not supported contact peter.holz@hotmail.de for support reqeust`n`nProgram will exit now
	exit
	/*
	conemuexe := "conemu64.exe"
	conemupathexe := "C:\Program Files (x86)\ConEmu\ConEmu.exe"
	IfnotExist, %conemupathexe%
		InputBox,  conemupathexe , type in your conemu.exe path it wasnt found in \program files(x86), , , 200, 120, , , , , %conemupathexe%
	*/
}

;atom


;sumatra



}
;PATH SPEICHERN

check_sumatra_present()

/*
debug()
debug() {
	winactivate, ahk_exe atom.exe
	WinWaitActive, ahk_exe atom.exe
	sleep 500
	save_texteditor()
	
	run_line()

*/
^4::
ListVars
return

; SHORTCUT UM PDF ZU ÖFFNEN

^5::
o_sumatra()
return

~f5:: ;f5 nicht blockieren
	if (winactive("ahk_exe atom.exe")=false)
	{
		return
	}

	save_texteditor()
	
	run_line()

return

{
~^f5::
msgbox not ready
return
	if (winactive("ahk_exe atom.exe")=false)
	{
		return
	}

	save_texteditor()

	run_line()
	if (first = 0)
		o_sumatra()

return
}
;strg & f5 öffnet nach commando sumantra pdf


save_texteditor() {
	global
	sendinput {Lcontrol down}
	sendinput {s down}
	sleep shortcut_ms
	sendinput {s up}
	sendinput {lcontrol up}
}

get_filedest(){
	global
	sendinput {Lcontrol down}
	sendinput {shift down}
	sendinput {c down}
	sleep shortcut_ms
	sendinput {c up}
	sendinput {shift up}
	sendinput {lcontrol up}
}

open_c(program,path) { ;NOCH NICHT FERTIG?
	
	global
	if (program = "conemu") {
		programexe := conemuexe
		prorgampath := conemupathexe
	} else if (program = "sumatra") {
		Msgbox, contact peter holz now! error sumatra
		exitapp
		programexe := sumatraexe
		programpath := sumatrapathexe
	}


	
	process, exist, %programexe%
	if (errorlevel=0) {
		run, %programpathexe%
		WinWaitActive, ahk_exe %programexe%
		if (program = "conemu") 
			sleep conemu_ms
	} else {
		WinActivate, ahk_exe %programexe% ;TIMEOUTS
		WinWaitActive, ahk_exe %programexe%
	}
	
}

run_line() {
	global
	;MAKE BENUTZEN
	iniread, shortcut_ms, options.ini,settings , shortcut_waittime
	
	WinGetTitle, title, A
	
	;FoundPos := InStr(Haystack, Needle [, CaseSensitive = false, StartingPos = 1, Occurrence = 1])
	len_a := InStr(title, " — " )
	
	;NewStr := SubStr(String, StartingPos [, Length])
	scriptname := SubStr(title, 1 , Len_a-1)
	
	if (InStr(scriptname, ".tex")
		scripttype := "lualatex"
	else if (InStr(scriptname, ".py"
		scripttype := "python"
	else {
		msgbox script type not supported!
		return
	}
	
	clip := Clipboard
	
	clipboard = ; Empty the clipboard
	get_filedest()
	ClipWait, 1
	if ErrorLevel
	{
		MsgBox, clipboard error
		return
	}
	scriptfullpath := Clipboard
	
	Clipboard := clip

	o_conemu()
	
	
	StringReplace, scriptfullpath, scriptfullpath, \,/ , All
	
	len_c := InStr(scriptfullpath, scriptname)
	
	scriptpath := SubStr(scriptfullpath, 1 , Len_c-2)
	WinGetTitle, title, A
	len_a := InStr(title, scriptpath)
	
	SendInput cd %scriptpath%{enter} ;nur wenn im title von conemu nicht ath steht
	
	
	
	SendInput %scripttype% %scriptname%{enter}
	
	;wenn biber dateien auftauchen biber
		;max threads anpasssen -> gewisse zeit ordner überwachen auf biber dateien
	/* 
	
	#maxthreads 2
	
	Loop Files, %scriptpath%\*%scriptname%, R  ; Recurse into subfolders.
	{
		;if (InStr(A_LoopFileFullPath, scriptpath) and InStr(A_LoopFileFullPath, "\"+scriptname) ){
			scriptfullpath := A_LoopFileFullPath
			MsgBox, 4, , Filename = %A_LoopFileFullPath%`n`nContinue?
			IfMsgBox, No
				break
			
		;}
	}
	
	*/
}

;OLD
/*
run_line() {
	global
	WinGetTitle, title, A
	
	;FoundPos := InStr(Haystack, Needle [, CaseSensitive = false, StartingPos = 1, Occurrence = 1])
	
	len_a := InStr(title, " — " )
	len_b := InStr(title, " — Atom", , StartingPos = len_a)
	
	;NewStr := SubStr(String, StartingPos [, Length])
	
	scriptname := SubStr(title, 1 , Len_a-1)
	scriptpath := SubStr(title, len_a+3, Len_b-len_a-3)
	
	o_conemu()
	
	^+c ;srg shift c
	
	msgbox
	Loop Files, %scriptpath%\*%scriptname%, R  ; Recurse into subfolders.
	{
		;if (InStr(A_LoopFileFullPath, scriptpath) and InStr(A_LoopFileFullPath, "\"+scriptname) ){
			scriptfullpath := A_LoopFileFullPath
			MsgBox, 4, , Filename = %A_LoopFileFullPath%`n`nContinue?
			IfMsgBox, No
				break
			
		;}
	}
	msgbox 
	
	
	;msgbox, %scriptpath%
	
	StringReplace, scriptfullpath, scriptfullpath, \,/ , All
	
	len10 := InStr(scriptfullpath, scriptname)
	
	scriptpath := SubStr(scriptfullpath, 1 , Len10-2)
	
	Send cd %scriptpath%{enter}
	Send lualatex %scriptname%{enter}
	
	/*
	if (first=true)
	{
		first := false
		msgbox, pls go to script folder and execute the command line for your script once
	}
	else 
	{
		sendinput {up}
		SendInput {enter}
	}
	
}
*/

;open_c("conemu")



o_sumatra() {
	;MIT path\sumatra exe "dateiverzeichnis\file" öffnen von datei möglich
	process, exist, SumatraPDF.exe
	if (errorlevel=0){
		
		msgbox, open sumatra pls ;run, SumatraPDF.exe
	}
	else
		WinActivate, ahk_exe SumatraPDF.exe

	WinWaitActive, ahk_exe SumatraPDF.exe
}

o_conemu() {
	global
	process, exist, %conemuexe%
	if (errorlevel=0) {
		run, %conemupathexe%
		WinWaitActive, ahk_exe %conemuexe%
		sleep 3000
	} else {
		WinActivate, ahk_exe %conemuexe% ;TIMEOUTS
		WinWaitActive, ahk_exe %conemuexe%
	}
}

iniread(){
	global
	IfNotExist, options.ini {
		iniwrite, 100, options.ini, settings, shortcut_waittime
		iniwrite, 3000, options.ini, settings, conemu_waittime
	}
	iniread, shortcut_ms, options.ini,settings , shortcut_waittime
	iniread, conemu_ms, options.ini,settings , conemu_waittime
}

^f6::
	MsgBox, 4, , Close program?
	IfMsgBox, Yes
		exitapp
	return