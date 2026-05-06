@echo off
setlocal

cd /d "%~dp0"

echo [1/3] Installing dependencies...
py -m pip install --upgrade pip
py -m pip install --upgrade -r requirements.txt
py -m pip install --upgrade pyinstaller
py -c "import selenium, sys; print('Python:', sys.executable); print('Selenium:', selenium.__version__)"

echo [2/3] Cleaning previous build files...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist "order_export_gui.spec" del /q "order_export_gui.spec"

echo [3/3] Building exe...
py -m PyInstaller --onefile --windowed --collect-all selenium --name order_export_gui order_export_gui.py

echo Done.
echo.
echo EXE path:
echo %CD%\dist\order_export_gui.exe
echo.
pause
