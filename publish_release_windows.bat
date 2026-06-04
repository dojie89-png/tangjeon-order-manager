@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

if /i "%~1" NEQ "__inner" (
    start "케이진 배포" cmd /k ""%~f0" __inner"
    exit /b
)

cd /d "%~dp0"
set LOG=publish_release.log
echo ==== publish_release %DATE% %TIME% ==== > "%LOG%"

call :log "[Start] %CD%"

if not exist "order_export_gui.py" (
    call :log "[Error] order_export_gui.py not found. Run this file inside the project folder."
    goto :fail
)
if not exist "requirements.txt" (
    call :log "[Error] requirements.txt not found. Run this file inside the project folder."
    goto :fail
)

set PYVER=-3.12
py %PYVER% --version >nul 2>&1
if errorlevel 1 (
    call :log "[Error] Python 3.12 not found. Please install Python 3.12 or check py launcher."
    goto :fail
)

for /f "usebackq delims=" %%v in (`py %PYVER% -c "import re; p=open('order_export_gui.py', encoding='utf-8').read(); print(re.search(r'APP_VERSION\\s*=\\s*\"([^\"]+)\"', p).group(1))"`) do set APPVER=%%v
set TAG=v%APPVER%
set EXE=dist\order_export_gui.exe

call :log "[Python]"
py %PYVER% --version >> "%LOG%" 2>&1
if errorlevel 1 goto :fail
call :log "[Version] %TAG%"

call :log "[1/4] Build exe..."
call :run py %PYVER% -m pip install --upgrade pip
if errorlevel 1 goto :fail
call :run py %PYVER% -m pip install --upgrade -r requirements.txt
if errorlevel 1 goto :fail
call :run py %PYVER% -m pip install --upgrade pyinstaller
if errorlevel 1 goto :fail
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist "order_export_gui.spec" del /q "order_export_gui.spec"
for /f "usebackq delims=" %%i in (`py %PYVER% -c "import sys, os; print(os.path.dirname(sys.executable))"`) do set PYDIR=%%i
call :log "[Python dir] %PYDIR%"
set EXTRA_BINS=
if exist "%PYDIR%\vcruntime140_1.dll" (
    set EXTRA_BINS=--add-binary "%PYDIR%\vcruntime140_1.dll;."
    call :log "[DLL] vcruntime140_1.dll 포함"
)
call :run py %PYVER% -m PyInstaller --onefile --windowed --collect-all selenium %EXTRA_BINS% --name order_export_gui order_export_gui.py
if errorlevel 1 goto :fail
if not exist "%EXE%" (
    call :log "[Error] Build failed: %EXE% not found."
    goto :fail
)
call :log "[Build OK] %CD%\%EXE%"

where gh >nul 2>&1
if errorlevel 1 (
    call :log "[Error] GitHub CLI not found. Install from: https://cli.github.com/"
    call :log "[Note] EXE build is complete, but GitHub release upload was skipped."
    goto :fail
)

gh auth status >> "%LOG%" 2>&1
if errorlevel 1 (
    call :log "[GitHub login]"
    gh auth login
    if errorlevel 1 (
        call :log "[Error] GitHub login failed."
        goto :fail
    )
)

call :log "[2/4] Push code and tag..."
git status --short >> "%LOG%" 2>&1
call :run git push origin main
if errorlevel 1 goto :fail
git tag %TAG% >nul 2>&1
call :run git push origin %TAG%
if errorlevel 1 goto :fail

call :log "[3/4] Create or update GitHub Release..."
gh release view %TAG% >nul 2>&1
if errorlevel 1 (
    call :run gh release create %TAG% "%EXE%" --title "%TAG%" --notes "탕전주문관리 %TAG%" --latest
) else (
    call :run gh release upload %TAG% "%EXE%" --clobber
    if errorlevel 1 goto :fail
    call :run gh release edit %TAG% --title "%TAG%" --notes "탕전주문관리 %TAG%" --latest
)
if errorlevel 1 (
    call :log "[Error] Release upload failed."
    goto :fail
)

call :log "[4/4] Done."
call :log "GitHub latest release is now %TAG%."
call :log "Employees will update when they open order_export_gui.exe."
pause
exit /b 0

:log
echo %~1
echo %~1>>"%LOG%"
exit /b 0

:run
echo ^> %*
echo ^> %*>>"%LOG%"
%* >> "%LOG%" 2>&1
if errorlevel 1 (
    echo [Error] command failed. See %LOG%.
    echo [Error] command failed: %*>>"%LOG%"
    exit /b 1
)
exit /b 0

:fail
call :log "[Failed] See %CD%\%LOG%"
echo.
echo 실패했어. 위 메시지나 publish_release.log를 확인해줘.
echo EXE가 만들어졌다면 위치: %CD%\%EXE%
echo.
if exist "%LOG%" (
    echo 마지막 로그:
    powershell -NoProfile -Command "Get-Content -Tail 40 '%LOG%'" 2>nul
)
pause
exit /b 1
