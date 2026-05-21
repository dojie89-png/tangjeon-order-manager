@echo off
setlocal

cd /d "%~dp0"

:: Python 3.11 또는 3.12 사용 (3.14는 PyInstaller 미지원)
set PYVER=-3.11
py %PYVER% --version >nul 2>&1
if errorlevel 1 (
    set PYVER=-3.12
    py %PYVER% --version >nul 2>&1
    if errorlevel 1 (
        echo [오류] Python 3.11 또는 3.12가 설치되어 있지 않습니다.
        echo https://www.python.org/downloads/release/python-3119/ 에서 설치 후 다시 실행하세요.
        pause
        exit /b 1
    )
)
echo [사용 Python 버전]
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
