/*
- compilier routine
	- autom. pushen mit versionsnummer
	- neue versionsnummer in prompt
	- automatisch release fenster öffnen
		- version autom. eintragen
		- exe autom. hochladen
		
	- zugehörige script version dazukopieren (bzw. sollte ja auf github sein
*/

ScrName := "script_helper.ahk"
icon := "quickopen.ico"

SetWorkingDir, A_ScriptDir
ver := iniread("version.txt","version","version")
FileCreateDir, releases/%ver%
name :=  "_" ver ".exe"
NewFileName := StrReplace(ScrName, ".ahk" , name)

;RunWait, %comspec% /c ipconfig /all > %A_Temp%\demo.tmp, , hide
runwait, % comspec . " /c ""C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"" /in " . ScrName . " /out " . "releases/" . ver . "/" . NewFileName . " /icon " . icon , , hide
exitapp

IniRead(file, section, key) {
	IniRead, out , %file% , %section% , %key%
	return out
}

