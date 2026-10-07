@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
set "CSC=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC%" set "CSC=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if not exist "%CSC%" (
  echo [TIFF-GIF-HOLO] Microsoft .NET Framework C# compiler was not found.
  echo Expected: %%WINDIR%%\Microsoft.NET\Framework64\v4.0.30319\csc.exe
  exit /b 2
)
if not exist "harness" mkdir "harness"
if not exist "workspace" mkdir "workspace"
if not exist "workspace\logs" mkdir "workspace\logs"
set "BUILDLOG=%CD%\workspace\logs\build.log"
>"%BUILDLOG%" echo TIFF-GIF-HOLO C# build log
>>"%BUILDLOG%" echo Started: %DATE% %TIME%
>>"%BUILDLOG%" echo Compiler: %CSC%

del /q "harness\TIFFGifHoloHarness.exe" 2>nul
del /q "harness\TIFFGifHoloTool.exe" 2>nul

echo [TIFF-GIF-HOLO] Building generic C# temporal-image evaluator (console-attached crash-safe host)...
"%CSC%" /nologo /target:exe /optimize+ /platform:anycpu /out:"harness\TIFFGifHoloHarness.exe" /reference:System.dll /reference:System.Core.dll /reference:System.Drawing.dll /reference:System.Windows.Forms.dll /reference:System.Web.Extensions.dll "harness\TIFFGifHoloHarness.cs" >>"%BUILDLOG%" 2>&1
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  type "%BUILDLOG%"
  echo [TIFF-GIF-HOLO] GUI evaluator compilation failed with code %RC%.
  echo [TIFF-GIF-HOLO] Compiler log: "%BUILDLOG%"
  exit /b %RC%
)

echo [TIFF-GIF-HOLO] Building verification tool from the same generic source...
"%CSC%" /nologo /target:exe /optimize+ /platform:anycpu /out:"harness\TIFFGifHoloTool.exe" /reference:System.dll /reference:System.Core.dll /reference:System.Drawing.dll /reference:System.Windows.Forms.dll /reference:System.Web.Extensions.dll "harness\TIFFGifHoloHarness.cs" >>"%BUILDLOG%" 2>&1
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  type "%BUILDLOG%"
  echo [TIFF-GIF-HOLO] Verification-tool compilation failed with code %RC%.
  echo [TIFF-GIF-HOLO] Compiler log: "%BUILDLOG%"
  exit /b %RC%
)

echo [TIFF-GIF-HOLO] Harness build complete.
echo [TIFF-GIF-HOLO] Compiler log: "%BUILDLOG%"
exit /b 0
