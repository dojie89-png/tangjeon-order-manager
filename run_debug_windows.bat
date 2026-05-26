@echo off
chcp 65001 > nul
setlocal

cd /d "%~dp0"

set PYVER=-3.14
py %PYVER% --version >nul 2>&1
if errorlevel 1 (
    echo [Error] Python 3.14 not found. Please install Python 3.14 or check py launcher.
    pause
    exit /b 1
)

echo [Python]
py %PYVER% --version
echo.
echo [Install/check dependencies]
py %PYVER% -m pip install -r requirements.txt
echo.
echo [Run app - errors will stay visible here]
py %PYVER% order_export_gui.py
echo.
echo [Exit code] %ERRORLEVEL%
echo.
if exist startup_error.log (
    echo [startup_error.log]
    type startup_error.log
    echo.
)
pause
