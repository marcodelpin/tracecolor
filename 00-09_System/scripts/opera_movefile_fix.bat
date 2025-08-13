@echo off
echo Opera MoveFileEx Fix
echo ====================
echo.

REM Check admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Run as Administrator!
    pause
    exit /b 1
)

echo Downloading Microsoft MoveFile utility...
echo.

REM Download MoveFile.exe from Microsoft
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/MoveFile.zip' -OutFile '%temp%\MoveFile.zip'}" 2>nul

REM Extract if downloaded
if exist "%temp%\MoveFile.zip" (
    powershell -Command "Expand-Archive -Path '%temp%\MoveFile.zip' -DestinationPath '%temp%\' -Force"
    
    if exist "%temp%\movefile64.exe" (
        echo Using MoveFile to schedule deletion...
        "%temp%\movefile64.exe" "%APPDATA%\Opera Software" "" /accepteula
        echo.
        echo SUCCESS: Folder scheduled for deletion at next boot!
    ) else if exist "%temp%\movefile.exe" (
        echo Using MoveFile to schedule deletion...
        "%temp%\movefile.exe" "%APPDATA%\Opera Software" "" /accepteula
        echo.
        echo SUCCESS: Folder scheduled for deletion at next boot!
    )
) else (
    echo Failed to download MoveFile. Using alternative method...
    echo.
    
    REM Alternative: Create a startup script
    echo @echo off > "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\delete_opera_once.bat"
    echo cd /d "%APPDATA%" >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\delete_opera_once.bat"
    echo rmdir /s /q "Opera Software" 2^>nul >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\delete_opera_once.bat"
    echo del "%%~f0" >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\delete_opera_once.bat"
    
    echo Created startup script to delete folder.
)

echo.
echo Please restart your computer to complete the process.
echo.
pause