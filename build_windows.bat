@echo off
chcp 65001 > nul
setlocal

cd /d "%~dp0"

:: Use Python 3.14 for local run/build consistency.
set PYVER=-3.14
py %PYVER% --version >nul 2>&1
if errorlevel 1 (
    echo [Error] Python 3.14 not found. Please install Python 3.14 or check py launcher.
    pause
    exit /b 1
)
echo [Python version]
py %PYVER% --version

echo [1/3] Installing dependencies...
py %PYVER% -m pip install --upgrade pip
py %PYVER% -m pip install --upgrade -r requirements.txt
py %PYVER% -m pip install --upgrade pyinstaller
py %PYVER% -c "import selenium, sys; print('Python:', sys.executable); print('Selenium:', selenium.__version__)"

echo [2/3] Cleaning previous build files...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist "order_export_gui.spec" del /q "order_export_gui.spec"

echo [3/3] Building exe...
py %PYVER% -m PyInstaller --onefile --windowed --collect-all selenium --name order_export_gui order_export_gui.py

echo Done.
echo.
echo EXE path:
echo %CD%\dist\order_export_gui.exe
echo.
pause
