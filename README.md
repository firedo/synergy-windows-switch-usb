# synergy-windows-switch-usb
AutoIt Script - starts Synergy client or server mode (as service) based on if specific USB device is connected


Quick Tutorial:
1. Download and Install [AutoIt & Editor](https://www.autoitscript.com/site/autoit-script-editor/downloads/)
1. Clone this repository to your computer
1. Edit the "Synergy-Switch-based-on-USB.au3" file in SciTE:
  1. Get the Synergy client & server commands by switching between Synergy client and server mode with the Synergy application (press Apply).
  1. Press Win+R and run 'regedit', browse to "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Synergy" and copy the "Command" registry value to the SynergyCommand(Client/Server) variables (press F5 to refresh the view)
    * NOTE: Copy the whole command string, including the double quotes and paste inside the single quotes
  1. Get VID_XXXX and PID_XXXX from Windows 'Device Manager' => right-click the correct USB device => Properties => Details tab => Property: Hardware Ids
  1. Replace the 4-character codes in the $USBdeviceIDstrings array values and update the number between the brackets "[]" to the number of devices
  * You can also add an custom icon by adding it to the same folder and changing the "AutoIt3Wrapper_Icon" variable in top of the file.
1. Save changes and Compile the EXE from SciTE: Tools => Compile
1. Test that the EXE works (it requires admin permission to change the Synergy command in the registroy and to stop/start Synergy service)
1. Open Task Scheduler (use the Windows search)
  1. Create Task
  1. Name it as you like (for ex. "Synergy Switch based on USB device")
  1. Change the user to "SYSTEM"
  1. Enable "Run with highest privileges"
  1. Trigger tab => New => At Startup (Delay task for: 30 seconds)
  1. Action tab => New => Browse to the EXE file you compiled earlier
  1. Conditions tab: Disable all checkboxes
  1. Settings tab: Enable "If the task fails, restart every": 1 minute (5 times)
  1. Press OK to create the task
* On next boot the Synergy client/server service will be started based on if the USB device is connected (at startup). You can also run it manually.

Feel free to use, edit & share these files. Pull requests for bugs or extra features are also welcome.

No support provided for this script nor Synergy by me. Please use Google or go to the Synergy forums.

I'm not affiliated in anyway with Synergy, Symless nor AutoIt. I just use their software.


