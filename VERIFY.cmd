@echo off
setlocal EnableExtensions
cd /d "%~dp0"
if not exist "harness\TIFFGifHoloTool.exe" call "%CD%\BUILD_HARNESS.cmd"
if errorlevel 1 exit /b %errorlevel%
if not "%~1"=="" (
  "%CD%\harness\TIFFGifHoloTool.exe" --verify "%~1"
  exit /b %ERRORLEVEL%
)
echo === TIFF temporal carrier ===
"%CD%\harness\TIFFGifHoloTool.exe" --verify "%CD%\cartridge\Lunar127_Showcase_0.3.1_PROCESSABLE.tiff"
if errorlevel 1 exit /b %ERRORLEVEL%
echo.
echo === GIF temporal carrier ===
"%CD%\harness\TIFFGifHoloTool.exe" --verify "%CD%\cartridge\Lunar127_Showcase_0.3.1_PROCESSABLE.gif"
exit /b %ERRORLEVEL%
