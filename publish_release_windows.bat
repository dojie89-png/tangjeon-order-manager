@echo off
chcp 65001 > nul
setlocal

cd /d "%~dp0"

set PYVER=-3.12
py %PYVER% --version >nul 2>&1
if errorlevel 1 (
    echo [Error] Python 3.12 not found. Please install Python 3.12 or check py launcher.
    pause
    exit /b 1
)

for /f "usebackq delims=" %%v in (`py %PYVER% -c "import re; p=open('order_export_gui.py', encoding='utf-8').read(); print(re.search(r'APP_VERSION\\s*=\\s*\"([^\"]+)\"', p).group(1))"`) do set APPVER=%%v
set TAG=v%APPVER%
set EXE=dist\order_export_gui.exe

echo [Version] %TAG%

where gh >nul 2>&1
if errorlevel 1 (
    echo [Error] GitHub CLI not found. Install from:
    echo https://cli.github.com/
    pause
    exit /b 1
)

gh auth status >nul 2>&1
if errorlevel 1 (
    echo [GitHub login]
    gh auth login
    if errorlevel 1 (
        echo [Error] GitHub login failed.
        pause
        exit /b 1
    )
)

echo [1/4] Build exe...
py %PYVER% -m pip install --upgrade pip
py %PYVER% -m pip install --upgrade -r requirements.txt
py %PYVER% -m pip install --upgrade pyinstaller
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist "order_export_gui.spec" del /q "order_export_gui.spec"
py %PYVER% -m PyInstaller --onefile --windowed --collect-all selenium --name order_export_gui order_export_gui.py
if not exist "%EXE%" (
    echo [Error] Build failed: %EXE% not found.
    pause
    exit /b 1
)

echo [2/4] Push code and tag...
git push origin main
git tag %TAG% >nul 2>&1
git push origin %TAG%

echo [3/4] Create or update GitHub Release...
gh release view %TAG% >nul 2>&1
if errorlevel 1 (
    gh release create %TAG% "%EXE%" --title "%TAG%" --notes "탕전주문관리 %TAG%" --latest
) else (
    gh release upload %TAG% "%EXE%" --clobber
    gh release edit %TAG% --title "%TAG%" --notes "탕전주문관리 %TAG%" --latest
)
if errorlevel 1 (
    echo [Error] Release upload failed.
    pause
    exit /b 1
)

echo [4/4] Done.
echo GitHub latest release is now %TAG%.
echo Employees will update when they open order_export_gui.exe.
pause
