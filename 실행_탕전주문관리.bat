@echo off
chcp 65001 > nul
setlocal

cd /d "%~dp0"

py -3.12 --version >nul 2>&1
if errorlevel 1 (
    echo [오류] Python 3.12를 찾지 못했어요.
    echo Python 3.12 설치 후 다시 실행해주세요.
    pause
    exit /b 1
)

echo [1/2] 필요한 패키지 확인 중...
py -3.12 -m pip install -r requirements.txt
if errorlevel 1 (
    echo [오류] 패키지 설치에 실패했어요.
    pause
    exit /b 1
)

echo [2/2] 프로그램 실행...
py -3.12 order_export_gui.py

if errorlevel 1 (
    echo.
    echo [오류] 프로그램 실행 중 문제가 발생했어요.
    if exist startup_error.log (
        echo.
        echo ===== startup_error.log =====
        type startup_error.log
    )
    pause
)
