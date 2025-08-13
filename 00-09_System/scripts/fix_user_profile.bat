@echo off
echo User Profile Fix for Opera
echo ==========================
echo.

echo This will check and fix potential user profile issues.
echo.

REM Check Windows user profile integrity
echo Checking user profile integrity...
sfc /scannow

echo.
echo Checking for profile corruption...
dism /online /cleanup-image /restorehealth

echo.
echo Creating a test user to verify if it's a profile issue...
echo.
echo Would you like to create a test user account? (Y/N)
choice /C YN /M "Create test user"
if %errorlevel%==1 (
    net user OperaTest TempPass123! /add
    net localgroup administrators OperaTest /add
    echo.
    echo Test user created:
    echo Username: OperaTest
    echo Password: TempPass123!
    echo.
    echo 1. Log out and log in as OperaTest
    echo 2. Try installing Opera there
    echo 3. If it works, your main profile is corrupted
    echo.
    echo To remove test user later: net user OperaTest /delete
)

echo.
pause