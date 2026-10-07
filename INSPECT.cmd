@echo off
setlocal EnableExtensions
cd /d "%~dp0"
if not exist "harness\TIFFGifHoloTool.exe" call "%CD%\BUILD_HARNESS.cmd"
if errorlevel 1 exit /b %errorlevel%
set "TARGET=%~1"
if /I "%TARGET%"=="gif" set "TARGET=%CD%\cartridge\Lunar127_Showcase_0.3.1_PROCESSABLE.gif"
if /I "%TARGET%"=="tiff" set "TARGET=%CD%\cartridge\Lunar127_Showcase_0.3.1_PROCESSABLE.tiff"
if "%TARGET%"=="" set "TARGET=%CD%\cartridge\Lunar127_Showcase_0.3.1_PROCESSABLE.gif"
"%CD%\harness\TIFFGifHoloTool.exe" --inspect "%TARGET%"
echo.
pause
