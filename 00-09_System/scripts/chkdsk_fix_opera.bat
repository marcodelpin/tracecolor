@echo off
echo File System Corruption Fix for Opera
echo ====================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Run as Administrator!
    pause
    exit /b 1
)

echo This appears to be a file system corruption issue.
echo We will schedule CHKDSK to run on next boot.
echo.

echo Scheduling disk check...
echo Y | chkdsk C: /F /R

echo.
echo CHKDSK has been scheduled for the next restart.
echo.
echo IMPORTANT STEPS:
echo 1. Close all programs and save your work
echo 2. Restart your computer
echo 3. Let CHKDSK complete (it may take 30-60 minutes)
echo 4. After CHKDSK completes, the Opera folder should be deletable
echo.
echo After CHKDSK completes and Windows starts:
echo - Try to delete the Opera Software folder manually
echo - Or run one of the fix scripts again
echo.
pause