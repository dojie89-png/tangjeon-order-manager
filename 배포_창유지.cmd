@echo off
cd /d "%~dp0"
cmd /k ""%~dp0publish_release_windows.bat" __inner"
