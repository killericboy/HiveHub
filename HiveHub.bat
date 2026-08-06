@echo off
cd /d "%~dp0"
if not exist "settings" mkdir settings
set "AHK="
for %%P in ("%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe" "%ProgramFiles%\AutoHotkey\v2\AutoHotkey32.exe" "%ProgramFiles%\AutoHotkey\AutoHotkey64.exe" "%ProgramFiles(x86)%\AutoHotkey\AutoHotkey64.exe" "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe" "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey32.exe") do (if exist %%P set "AHK=%%~P")
if not defined AHK (echo ERROR: AutoHotkey v2 not found. & pause & exit /b 1)
start "" "%AHK%" "%~dp0lib\HiveHub.ahk"
