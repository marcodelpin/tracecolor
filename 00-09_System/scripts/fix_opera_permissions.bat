@echo off
echo Fixing Opera folder permissions...

REM Take ownership of the folder
takeown /f "%APPDATA%\Opera Software" /r /d y

REM Grant full permissions to current user
icacls "%APPDATA%\Opera Software" /grant "%USERNAME%":F /t

echo.
echo Permissions fixed. Try starting Opera now.
pause