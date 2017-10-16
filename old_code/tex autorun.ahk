#NoEnv
SetBatchLines -1
ListLines Off
first := true

input

0tosay := "\input{header.tex}" 
1tosay := "\begin{document}"
2tosay := "\end{document}"

f3::
exitapp

F4::
	;Sendinput % %A_Index%tosay 
	sendinput {raw} %0tosay% 
	sendinput {Enter 3} {raw} %1tosay% 
	sendinput {Enter 3} {raw} %2tosay% 
return

f5::
if (winactive("ahk_exe notepad++.exe")=false)
{
	return
}

sendinput {Lcontrol down}
sendinput {s down}
sleep 200
sendinput {s up}
sendinput {lcontrol up}

process, exist, ConEmu64.exe
if (errorlevel=0)
	run, conemu64.exe
else
	WinActivate, ahk_exe conemu64.exe

WinWaitActive, ahk_exe conemu64.exe

if (first=true)
{
	first := false
	
	Sendinput lualatex {space}
	msgbox, pls go to script folder and execute the latex command line for your script once
	
}
else 
{
	sendinput {up}
	SendInput {enter}
}
return


 
