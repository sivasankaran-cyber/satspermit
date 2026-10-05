@echo off
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js 24 or newer is required. Install it from https://nodejs.org
  pause
  exit /b 1
)
echo Open http://127.0.0.1:4317 in your browser after the server is ready.
node --env-file-if-exists=.env src/server.ts
pause
