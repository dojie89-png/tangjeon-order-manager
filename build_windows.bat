@echo off
setlocal

cd /d "%~dp0"

echo [1/4] Installing dependencies...
py -m pip install --upgrade pip
py -m pip install --upgrade -r requirements.txt
py -m pip install --upgrade pyinstaller
py -c "import selenium, sys; print('Python:', sys.executable); print('Selenium:', selenium.__version__)"

echo [2/4] Cleaning previous build files...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist "케이진_탕전주문관리_v12.56.spec" del /q "케이진_탕전주문관리_v12.56.spec"

echo [3/4] Building exe...
py -m PyInstaller ^
  --onefile ^
  --windowed ^
  --clean ^
  --name "케이진_탕전주문관리_v12.56" ^
  --collect-all selenium ^
  --collect-submodules selenium ^
  --collect-submodules selenium.webdriver ^
  --hidden-import selenium.webdriver.chrome.webdriver ^
  --hidden-import selenium.webdriver.chrome.service ^
  --hidden-import selenium.webdriver.chrome.options ^
  --hidden-import selenium.webdriver.chromium.webdriver ^
  --hidden-import selenium.webdriver.chromium.service ^
  --hidden-import selenium.webdriver.chromium.options ^
  --hidden-import selenium.webdriver.common.service ^
  --hidden-import selenium.webdriver.common.driver_finder ^
  --hidden-import selenium.webdriver.common.selenium_manager ^
  --hidden-import selenium.webdriver.remote.webdriver ^
  --hidden-import selenium.webdriver.remote.remote_connection ^
  --hidden-import selenium.webdriver.support.expected_conditions ^
  order_export_gui.py

echo [4/4] Done.
echo.
echo EXE path:
echo %CD%\dist\케이진_탕전주문관리_v12.56.exe
echo.
pause
