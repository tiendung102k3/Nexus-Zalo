@echo off
setlocal EnableDelayedExpansion
title Nexus-Zalo — Cai dat he thong
chcp 65001 >nul 2>&1

cd /d "%~dp0"

echo ==========================================================
echo           NEXUS-ZALO — CÀI ĐẶT TRÊN WINDOWS
echo ==========================================================
echo.

:: 1. Kiem tra Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Khong tim thay Node.js tren may tinh!
    echo.
    echo Vui long cai dat Node.js ^(LTS 20+^):
    echo   1. Tai bo cai dat tai: https://nodejs.org
    echo   2. Chay trinh cai dat, tich chon "Automatically install necessary tools"
    echo   3. Sau khi cai dat xong, mo lai file install.bat nay.
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('node -v 2^>nul') do set NODE_VER=%%v
echo [OK] Node.js da duoc cai dat: !NODE_VER!

:: 2. Kiem tra ADB (Android Debug Bridge)
where adb >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo [WARNING] Khong tim thay ADB trong System PATH!
    echo Nexus-Zalo can ADB de ket noi va sao luu du lieu dien thoai Android.
    echo.
    echo Huong dan cai dat ADB tren Windows:
    echo   1. Tai SDK Platform-Tools tai:
    echo      https://developer.android.com/tools/releases/platform-tools
    echo   2. Giai nen vao thu muc ^(vi du: C:\platform-tools^)
    echo   3. Them thu muc do vao bien moi truong System PATH cua Windows.
    echo.
    echo   ^(He thong van tiep tuc cai dat, nhung ban can bo sung ADB truoc khi sao luu^).
    echo.
) else (
    for /f "tokens=*" %%a in ('adb version 2^>nul ^| findstr /i "version"') do set ADB_VER=%%a
    echo [OK] ADB da san sang: !ADB_VER!
)

:: 3. Khoi tao .env tu .env.example neu chua co
if not exist ".env" (
    if exist ".env.example" (
        copy ".env.example" ".env" >nul
        echo [OK] Da tao file cau hinh .env tu .env.example.
    )
)

:: 4. Cai dat dependencies
echo.
echo [*] Dang cai dat thu vien Node.js (npm install)...
call npm install
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Cai dat thu vien that bai! Vui long kiem tra ket noi mang.
    pause
    exit /b 1
)

:: 5. Hoan tat
echo.
echo ==========================================================
echo 🎉 CAI DAT NEXUS-ZALO THANH CONG!
echo ==========================================================
echo.
echo Khoi dong ung dung bang mot trong cac cach sau:
echo   1. lenh chay tai thu muc nay: npm start
echo.
echo Dashboard se mo tai: http://127.0.0.1:5178
echo.
pause
