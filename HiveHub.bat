@echo off
cd /d "%~dp0"
if not exist "settings" mkdir settings

:: Check WebView2Loader.dll
if not exist "lib\WebView2Loader.dll" (
    echo.
    echo  ============================================================
    echo   WebView2Loader.dll not found in lib\
    echo   HiveHub uses Microsoft Edge WebView2 for its UI.
    echo.
    echo   Download the fixed-version runtime installer:
    echo   https://go.microsoft.com/fwlink/p/?LinkId=2124703
    echo.
    echo   Then copy WebView2Loader.dll from the SDK into lib\
    echo   OR install the runtime - it is usually already present
    echo   on Windows 11 and updated Windows 10 machines.
    echo  ============================================================
    echo.
)

:: Check for AHK v2
set "AHK="
for %%P in (
    "%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe"
    "%ProgramFiles%\AutoHotkey\v2\AutoHotkey32.exe"
    "%ProgramFiles%\AutoHotkey\AutoHotkey64.exe"
    "%ProgramFiles(x86)%\AutoHotkey\AutoHotkey64.exe"
    "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe"
) do (
    if exist %%P set "AHK=%%~P"
)

if not defined AHK (
    echo ERROR: AutoHotkey v2 not found.
    echo Install from https://www.autohotkey.com/
    pause & exit /b 1
)

echo HiveHub Macro by Killericboy
echo AHK: %AHK%
echo Starting...
start "" "%AHK%" "%~dp0lib\HiveHub.ahk"
