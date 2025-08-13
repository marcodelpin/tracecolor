@echo off
echo Opera Portable Installation Fix
echo ===============================
echo.

echo Creating portable Opera installation...

REM Create a new directory for Opera
mkdir "C:\OperaPortable" 2>nul
mkdir "C:\OperaPortable\profile" 2>nul

REM Download Opera installer
echo Downloading Opera...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://get.opera.com/pub/opera/desktop/115.0.5322.109/win/Opera_115.0.5322.109_Setup_x64.exe' -OutFile 'C:\OperaPortable\opera_installer.exe'}"

REM Extract Opera files
echo Extracting Opera files...
"C:\OperaPortable\opera_installer.exe" /extract:"C:\OperaPortable\Opera" /silent

REM Create launcher with custom profile
echo Creating custom launcher...
echo @echo off > "C:\OperaPortable\StartOpera.bat"
echo start "" "C:\OperaPortable\Opera\opera.exe" --user-data-dir="C:\OperaPortable\profile" %%* >> "C:\OperaPortable\StartOpera.bat"

REM Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Opera Portable.lnk'); $Shortcut.TargetPath = 'C:\OperaPortable\StartOpera.bat'; $Shortcut.IconLocation = 'C:\OperaPortable\Opera\opera.exe'; $Shortcut.Save()"

echo.
echo Opera Portable has been set up!
echo Use the desktop shortcut "Opera Portable" to start Opera.
echo.
echo This version will NOT use the problematic AppData folder.
echo.
pause