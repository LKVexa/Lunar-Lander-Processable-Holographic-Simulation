@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
title TIFF-GIF-HOLO HOTFIX 4 - Diagnose
echo ================================================================
echo   TIFF-GIF-HOLO Lunar127 0.3.1 - HOTFIX 4 DIAGNOSE
echo ================================================================
echo.
call "%CD%\BUILD_HARNESS.cmd"
if errorlevel 1 goto :FAIL
echo.
echo [1/4] Verifying seed GIF...
"%CD%\harness\TIFFGifHoloTool.exe" --verify "%CD%\cartridge\Lunar127_Showcase_0.3.1_PROCESSABLE.gif"
if errorlevel 1 goto :FAIL
echo [2/4] Semantic/runtime smoke test for GIF...
"%CD%\harness\TIFFGifHoloTool.exe" --smoke "%CD%\cartridge\Lunar127_Showcase_0.3.1_PROCESSABLE.gif"
if errorlevel 1 goto :FAIL
echo [3/4] Verifying seed TIFF...
"%CD%\harness\TIFFGifHoloTool.exe" --verify "%CD%\cartridge\Lunar127_Showcase_0.3.1_PROCESSABLE.tiff"
if errorlevel 1 goto :FAIL
echo [4/4] Semantic/runtime smoke test for TIFF...
"%CD%\harness\TIFFGifHoloTool.exe" --smoke "%CD%\cartridge\Lunar127_Showcase_0.3.1_PROCESSABLE.tiff"
if errorlevel 1 goto :FAIL
echo.
echo [TIFF-GIF-HOLO] DIAGNOSE PASS
echo Type EXIT only when you want to close this window.
cmd /d /k
exit /b 0
:FAIL
echo.
echo [TIFF-GIF-HOLO] DIAGNOSE FAILED.
echo Build log: "%CD%\workspace\logs\build.log"
echo Runtime log: "%CD%\workspace\logs\runtime.log"
echo Type EXIT only when you want to close this window.
cmd /d /k
exit /b 1
