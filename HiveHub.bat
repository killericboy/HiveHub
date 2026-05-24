@echo off
cd /d "%~dp0"
if not exist "settings" mkdir settings
if not exist "lib\Gdip_All.ahk" (
    echo ERROR: lib\Gdip_All.ahk not found. Ensure lib folder is present.
    pause & exit /b 1
)
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
    echo ERROR: AutoHotkey v2 not found. Install from https://www.autohotkey.com/
    pause & exit /b 1
)
echo HiveHub Macro by Killericboy
echo AutoHotkey: %AHK%
echo Starting...
start "" "%AHK%" "%~dp0lib\HiveHub.ahk"
