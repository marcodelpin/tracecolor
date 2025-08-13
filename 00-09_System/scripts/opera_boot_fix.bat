@echo off
echo Opera Boot-Time Fix Script
echo ==========================
echo.
echo This script will schedule folder deletion at next boot.
echo.

REM Use Windows built-in MoveFileEx to schedule deletion at boot
echo Scheduling Opera folder for deletion at next boot...

REM Create a temporary VBS script to handle the registry write
echo Set objShell = CreateObject("WScript.Shell") > "%temp%\opera_boot_delete.vbs"
echo strKeyPath = "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\" >> "%temp%\opera_boot_delete.vbs"
echo strValueName = "PendingFileRenameOperations" >> "%temp%\opera_boot_delete.vbs"
echo strValue = "\??\" ^& Replace("%APPDATA%\Opera Software", "\", "\\") ^& Chr(0) ^& Chr(0) >> "%temp%\opera_boot_delete.vbs"
echo objShell.RegWrite strKeyPath ^& strValueName, strValue, "REG_MULTI_SZ" >> "%temp%\opera_boot_delete.vbs"

cscript //nologo "%temp%\opera_boot_delete.vbs"
del "%temp%\opera_boot_delete.vbs"

echo.
echo Folder scheduled for deletion at next boot.
echo Please restart your computer to complete the fix.
echo.
pause