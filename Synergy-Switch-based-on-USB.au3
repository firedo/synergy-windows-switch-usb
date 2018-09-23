#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=your-custom-icon.ico
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=0.1.1.12
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=n
#AutoIt3Wrapper_Res_LegalCopyright=firedo
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Add_Constants=n
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 4 -w 5
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#comments-start
* Start Synergy Client or Server based on if any of specific USB devices (for ex. Gaming keyboard) is connected or not
#comments-end

#include <AutoItConstants.au3>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Get these commands by switching between Synergy client and server mode with the Synergy application.
; Open 'regedit' and browse to "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Synergy" and copy the "Command" registry value to the below variables (copy the whole string, including the double quotes and paste inside the single quotes).
Global $SynergyCommandClient = ''
; Example, please don't use the below line!
;Global $SynergyCommandClient = '"C:/Program Files/Synergy/synergyc.exe" -f --no-tray --debug INFO --name HOSTNAME --ipc --enable-drag-drop --enable-crypto --profile-dir "C:\Users\USERNAME\AppData\Local" 192.168.100.101:24800' 

Global $SynergyCommandServer = ''
; Example, please don't use the below line!
;Global $SynergyCommandServer = '"C:/Program Files/Synergy/synergys.exe" -f --no-tray --debug INFO --name HOSTNAME --ipc --enable-drag-drop --enable-crypto --profile-dir "C:\Users\USERNAME\AppData\Local" -c "C:/Users/USERNAME/Synergy Configs/synergy-server.sgc" --address 192.168.100.202:24800 --serial-key XXXXX' ; Example, please don't use!

; Get VID_XXXX and PID_XXXX from Windows 'Device Manager' => right-click the correct USB device => Properties => Details tab => Property: Hardware Ids
Global $USBdeviceIDstrings[2] = ["VID_046D&PID_C228", "VID_046D&PID_C229"] ; Logitech G19 keyboard (+ macro/LCD interface)
; Please note that the above variable is an array and you need to update the number between the brackets "[]" to the number of devices.

Global $showDevices = False ; Change to true if you want to output the above matching devices

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; WIM Location for this script to check for USB devices
Global $strComputer = "." ; "." = Local Computer
Global $WMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2") ;

; Declare
Global $items
Global $USBdeviceIDstring
Global $SynergyCommand
Global $ServiceResult

; General variables
Global $deviceFound = False
Global $SynergyServiceStart = "net start synergy"
Global $SynergyServiceStop = "net stop synergy"

If $SynergyCommandClient == "" Or $SynergyCommandServer == "" Then
    ConsoleWrite('Line ' & @ScriptLineNumber & ': ERROR: Missing required SynergyCommandClient/Server variable!' & @CRLF)
    Exit 1
EndIf

; Find matching USB device(s)
If IsArray($USBdeviceIDstrings) then
	For $USBdeviceIDstring In $USBdeviceIDstrings
		$items = $WMIService.ExecQuery("SELECT * FROM Win32_PnPEntity where DeviceID like 'USB\\" & $USBdeviceIDstring & "%'")
		If IsObj($items) then
			For $item In $items
				$deviceFound = true
                If $showDevices == True Then
                    ConsoleWrite("-----------------------------------------------" & @CRLF)
                    ConsoleWrite('DeviceId: ' & $item.DeviceID & ' / Caption: ' & $item.Caption & @CRLF)
                Else
                    ExitLoop 2 ; Stop after 1st match
                EndIf
			Next
		Endif
	Next
EndIf

If $deviceFound == True Then
		ConsoleWrite("USB device(s) Found! Switching Synergy to 'Server' mode" & @CRLF)
		$SynergyCommand = $SynergyCommandServer
Else
		ConsoleWrite("USB device(s) NOT Found! Switching Synergy to 'Client' mode" & @CRLF)
		$SynergyCommand = $SynergyCommandClient
EndIf

; Write to registry the new startup command for the 'Synergy' service  (to switch between 'Client' or 'Server' mode)
RegWrite("HKEY_LOCAL_MACHINE\Software\Synergy", "Command", "REG_SZ", $SynergyCommand)

If @error Then
        ConsoleWrite('Line ' & @ScriptLineNumber & ': ERROR: While writing to registry, error code = ' & @error & ' (1 = permission denied, script not run with admin permissions)' & @CRLF)
		Exit 1
EndIf

; Restart the 'Synergy' service
$ServiceResult = RunWait(@ComSpec & " /c " & $SynergyServiceStop & " & " & $SynergyServiceStart, @ScriptDir, @SW_HIDE)

If @error Then
	ConsoleWrite('Line ' & @ScriptLineNumber & ": ERROR: while stopping/starting the 'Synergy' service (result =" & $ServiceResult & ") 2 = Permission denied propably"  & @CRLF)
	Exit 1
EndIf
