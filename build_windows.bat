@echo off
chcp 65001 > nul
setlocal

cd /d "%~dp0"

:: Try py -3.12 first, then py -3.11, then fallback to python
set PYVER=-3.12
py %PYVER% --version >nul 2>&1
if errorlevel 1 (
    set PYVER=-3.11
    py %PYVER% --version >nul 2>&1
    if errorlevel 1 (
        echo [Error] Python 3.11 or 3.12 not found. Please install from:
        echo https://www.python.org/downloads/release/python-31210/
        pause
        exit /b 1
    )
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
REM dist 폴더 통째로 지우지 않음 - 결과 폴더가 들어 있을 수 있어 exe 만 삭제
if exist dist\order_export_gui.exe del /q dist\order_export_gui.exe
if exist "order_export_gui.spec" del /q "order_export_gui.spec"

echo [3/3] Building exe...
:: Python 설치 경로의 VC++ 런타임 DLL 경로 추출
for /f "delims=" %%i in ('py %PYVER% -c "import sys, os; print(os.path.dirname(sys.executable))"') do set PYDIR=%%i
echo Python dir: %PYDIR%

:: vcruntime140_1.dll 포함 여부 확인 후 빌드 (없으면 기본 빌드)
set EXTRA_BINS=
if exist "%PYDIR%\vcruntime140_1.dll" (
    set EXTRA_BINS=--add-binary "%PYDIR%\vcruntime140_1.dll;."
    echo Including vcruntime140_1.dll
)

py %PYVER% -m PyInstaller --onefile --windowed --collect-all selenium %EXTRA_BINS% --add-data "label_app;label_app" --name order_export_gui order_export_gui.py

echo Done.
echo.
echo EXE path:
echo %CD%\dist\order_export_gui.exe
echo.
pause
