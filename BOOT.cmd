@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
title TIFF-GIF-HOLO Lunar127 - Crash-Safe Boot Shell

set "FORMAT=gif"
set "RESET=0"
set "NOLOOP=1"
if /I "%~1"=="tiff" set "FORMAT=tiff"
if /I "%~1"=="gif" set "FORMAT=gif"
if /I "%~1"=="reset" set "RESET=1"
if /I "%~2"=="reset" set "RESET=1"
if /I "%~3"=="reset" set "RESET=1"
if /I "%~1"=="direct" set "NOLOOP=1"
if /I "%~2"=="direct" set "NOLOOP=1"
if /I "%~3"=="direct" set "NOLOOP=1"
if /I "%~1"=="no-loopback" set "NOLOOP=1"
if /I "%~2"=="no-loopback" set "NOLOOP=1"
if /I "%~3"=="no-loopback" set "NOLOOP=1"
if /I "%~1"=="loopback" set "NOLOOP=0"
if /I "%~2"=="loopback" set "NOLOOP=0"
if /I "%~3"=="loopback" set "NOLOOP=0"

set "SEED=%CD%\cartridge\Lunar127_Showcase_0.3.1_PROCESSABLE.%FORMAT%"
set "CURRENT=%CD%\workspace\current.%FORMAT%"
set "HARNESS=%CD%\harness\TIFFGifHoloHarness.exe"
set "TOOL=%CD%\harness\TIFFGifHoloTool.exe"
set "LOGDIR=%CD%\workspace\logs"
set "RUNTIMELOG=%LOGDIR%\runtime.log"

if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>nul
>"%RUNTIMELOG%" echo TIFF-GIF-HOLO persistent boot log
>>"%RUNTIMELOG%" echo Started: %DATE% %TIME%
>>"%RUNTIMELOG%" echo Carrier format: %FORMAT%

cls
echo ================================================================
echo   TIFF-GIF-HOLO Lunar127 0.3.1 - HOTFIX 4
echo   Persistent boot shell / crash capture enabled
echo ================================================================
echo.
echo [TIFF-GIF-HOLO] This command window will remain open while the
echo [TIFF-GIF-HOLO] virtual console is running. It will also remain
echo [TIFF-GIF-HOLO] open after an unexpected exit so the error is visible.
echo.

if not exist "%SEED%" (
  echo [TIFF-GIF-HOLO] ERROR: Missing processable image carrier:
  echo   "%SEED%"
  >>"%RUNTIMELOG%" echo ERROR missing seed: %SEED%
  goto :FAIL
)

if not exist "workspace" mkdir "workspace" >nul 2>nul
if not exist "workspace\checkpoints" mkdir "workspace\checkpoints" >nul 2>nul

if "%RESET%"=="1" (
  del /q "%CD%\workspace\current.gif" 2>nul
  del /q "%CD%\workspace\current.tiff" 2>nul
  copy /y "%SEED%" "%CURRENT%" >nul
  if errorlevel 1 (
    echo [TIFF-GIF-HOLO] ERROR: Could not reset the active carrier.
    >>"%RUNTIMELOG%" echo ERROR reset copy failed
    goto :FAIL
  )
  echo [TIFF-GIF-HOLO] Active %FORMAT% temporal carrier reset from seed.
)

if not exist "%CURRENT%" (
  copy /y "%SEED%" "%CURRENT%" >nul
  if errorlevel 1 (
    echo [TIFF-GIF-HOLO] ERROR: Could not create workspace carrier.
    >>"%RUNTIMELOG%" echo ERROR initial carrier copy failed
    goto :FAIL
  )
)

echo [TIFF-GIF-HOLO] Building the Hotfix 4 crash-safe generic evaluator from source...
call "%CD%\BUILD_HARNESS.cmd"
if errorlevel 1 (
  echo [TIFF-GIF-HOLO] Harness build failed.
  >>"%RUNTIMELOG%" echo ERROR harness build failed
  goto :FAIL
)

if not exist "%HARNESS%" (
  echo [TIFF-GIF-HOLO] ERROR: GUI evaluator was not produced.
  >>"%RUNTIMELOG%" echo ERROR GUI evaluator missing after build
  goto :FAIL
)
if not exist "%TOOL%" (
  echo [TIFF-GIF-HOLO] ERROR: Verification tool was not produced.
  >>"%RUNTIMELOG%" echo ERROR verification tool missing after build
  goto :FAIL
)

echo [TIFF-GIF-HOLO] Preflight-validating the authoritative image...
"%TOOL%" --verify "%CURRENT%"
if errorlevel 1 (
  echo [TIFF-GIF-HOLO] ERROR: Carrier validation failed before GUI start.
  >>"%RUNTIMELOG%" echo ERROR preflight carrier validation failed
  goto :FAIL
)
echo [TIFF-GIF-HOLO] Preflight-loading image-resident runtime and assets...
"%TOOL%" --smoke "%CURRENT%"
if errorlevel 1 (
  echo [TIFF-GIF-HOLO] ERROR: Semantic runtime smoke test failed before GUI start.
  >>"%RUNTIMELOG%" echo ERROR runtime smoke test failed
  goto :FAIL
)

echo.
echo [TIFF-GIF-HOLO] Booting authoritative temporal image:
echo   "%CURRENT%"
echo [TIFF-GIF-HOLO] Runtime log:
echo   "%RUNTIMELOG%"
if "%NOLOOP%"=="1" echo [TIFF-GIF-HOLO] Direct console mode is the safe default. Use BOOT.cmd loopback to opt in to 127.0.0.1 transport.
echo.

if "%NOLOOP%"=="1" (
  "%HARNESS%" --carrier "%CURRENT%" --seed "%SEED%" --log "%RUNTIMELOG%" --no-loopback
) else (
  "%HARNESS%" --carrier "%CURRENT%" --seed "%SEED%" --log "%RUNTIMELOG%"
)
set "RC=%ERRORLEVEL%"

echo.
echo [TIFF-GIF-HOLO] Evaluator exited with code %RC%.
>>"%RUNTIMELOG%" echo Evaluator exit code: %RC%
if not "%RC%"=="0" (
  echo [TIFF-GIF-HOLO] The GUI did not exit normally.
  echo [TIFF-GIF-HOLO] Last runtime log follows:
  echo ----------------------------------------------------------------
  type "%RUNTIMELOG%"
  echo ----------------------------------------------------------------
) else (
  echo [TIFF-GIF-HOLO] GUI closed normally by the user.
)
echo.
echo [TIFF-GIF-HOLO] The boot shell is now persistent.
echo [TIFF-GIF-HOLO] Type EXIT only when you want to close this window.
cmd /d /k
exit /b %RC%

:FAIL
echo.
echo [TIFF-GIF-HOLO] Startup was stopped. This window is being held open
if exist "%RUNTIMELOG%" echo [TIFF-GIF-HOLO] Log: "%RUNTIMELOG%"
echo [TIFF-GIF-HOLO] Type EXIT only when you want to close this window.
cmd /d /k
exit /b 1
