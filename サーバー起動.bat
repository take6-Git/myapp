@echo off
chcp 65001 > nul
echo HEIC変換ツール を起動します...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
pause
