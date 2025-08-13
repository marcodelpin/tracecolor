@echo off
echo Stop Windows Update Loop
echo ========================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Run as Administrator!
    pause
    exit /b 1
)

echo Stopping Windows Update services...
net stop wuauserv
net stop cryptSvc
net stop bits
net stop msiserver

echo.
echo Clearing update cache...
ren C:\Windows\SoftwareDistribution SoftwareDistribution.old 2>nul
ren C:\Windows\System32\catroot2 catroot2.old 2>nul

echo.
echo Resetting Windows Update components...
regsvr32.exe /s atl.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s mshtml.dll
regsvr32.exe /s shdocvw.dll
regsvr32.exe /s browseui.dll
regsvr32.exe /s jscript.dll
regsvr32.exe /s vbscript.dll
regsvr32.exe /s scrrun.dll
regsvr32.exe /s msxml.dll
regsvr32.exe /s msxml3.dll
regsvr32.exe /s msxml6.dll
regsvr32.exe /s actxprxy.dll
regsvr32.exe /s softpub.dll
regsvr32.exe /s wintrust.dll
regsvr32.exe /s dssenh.dll
regsvr32.exe /s rsaenh.dll
regsvr32.exe /s gpkcsp.dll
regsvr32.exe /s sccbase.dll
regsvr32.exe /s slbcsp.dll
regsvr32.exe /s cryptdlg.dll
regsvr32.exe /s oleaut32.dll
regsvr32.exe /s ole32.dll
regsvr32.exe /s shell32.dll
regsvr32.exe /s initpki.dll
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng.dll
regsvr32.exe /s wuaueng1.dll
regsvr32.exe /s wucltui.dll
regsvr32.exe /s wups.dll
regsvr32.exe /s wups2.dll
regsvr32.exe /s wuweb.dll
regsvr32.exe /s qmgr.dll
regsvr32.exe /s qmgrprxy.dll
regsvr32.exe /s wucltux.dll
regsvr32.exe /s muweb.dll
regsvr32.exe /s wuwebv.dll

echo.
echo Restarting services...
net start cryptSvc
net start bits
net start msiserver
net start wuauserv

echo.
echo Running Windows Update troubleshooter...
msdt.exe /id WindowsUpdateDiagnostic

echo.
echo Update components have been reset.
echo.
echo Next steps:
echo 1. Restart your computer
echo 2. Go to Settings > Update & Security > Windows Update
echo 3. Click "Check for updates"
echo.
echo If updates still fail, run: sfc /scannow
echo.
pause