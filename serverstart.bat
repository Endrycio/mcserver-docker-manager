@echo off
title Minecraft Server

echo.
echo ================================
echo     Minecraft Server
echo ================================
echo.

SET SEARCH_FILE=search-%RANDOM%.log
SET PROCESS_NAME=Docker Desktop
SET PROCESS_PATH="C:\Program Files\Docker\Docker\Docker Desktop.exe"    :: Default Docker location
SET CONTAINER_NAME=YOUR_CONTAINER_NAME     :: Replace with your container name, e.g. "minecraft"

TASKLIST /FI "IMAGENAME eq %PROCESS_NAME%.exe" 1>%SEARCH_FILE%
FIND /I /N "%PROCESS_NAME%" %SEARCH_FILE% >NUL
IF NOT "%ERRORLEVEL%" == "0" (
    echo Starting Docker now...
    start "" %PROCESS_PATH%
)

if exist "%cd%\search*.log" (
    del /f /q "%cd%\search*.log"
)

echo Create back-up of server? (Y/N) 
choice /c YN /t 5 /d Y >nul

if errorlevel 2 (
    echo N
    echo Starting Minecraft Server...
    timeout /t 7 >nul    
) else (
    echo Saving Server...
    powershell -ExecutionPolicy Bypass -File "pre_backup.ps1"
    echo Done!
    echo Starting Minecraft Server...
)

docker ps | findstr /I "%CONTAINER_NAME%" >nul
if %errorlevel% neq 0 (
    docker compose -f "docker-compose.yml" up -d
    start "Minecraft Server LOGS" cmd /k docker attach %CONTAINER_NAME%
    echo Waiting for RCON connection...
    timeout /t 45 >nul  :: depending on how fast (or slow) or how many mods and plugins your server 
    has you might want to increase or decrease this. If you use too little you need to start the .bat 
    again as the bat will just continue if it cant connect to RCON. 45 sec is safe bet but might take 
    too long for people with good hardware (I use 33)
)

echo NOTE: don't close this window when Logged in to RCON!
mcrcon -H YOUR_SERVER_IP -P 25575 -p YOUR_RCON_PASSWORD     :: Replace YOUR_SERVER_IP with your server IP (Host is fine if running server on local machine) and YOUR_RCON_PASSWORD with your RCON password

echo Minecraft Server is closed.

echo Create Save file of Server? (Y/N) 
choice /c YN /t 5 /d Y >nul

if errorlevel 2 (
    echo N
    echo No back-up made!
) else (
    echo Saving Server...
    powershell -ExecutionPolicy Bypass -File "post_backup.ps1"
    echo Done!
)

echo Press any key to continue . . .
pause >nul
