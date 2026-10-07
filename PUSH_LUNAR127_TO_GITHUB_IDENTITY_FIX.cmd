@echo off
setlocal EnableExtensions
title Lunar127 - Publish to GitHub - Identity Fix
cd /d "%~dp0"

set "REPO_URL=https://github.com/LKVexa/Lunar-Lander-Processable-Holographic-Simulation.git"
set "REPO_PAGE=https://github.com/LKVexa/Lunar-Lander-Processable-Holographic-Simulation"
set "BRANCH=main"

rem -----------------------------------------------------------------
rem Repository-local author identity.
rem These are the values supplied during the previous publish attempt.
rem This script does NOT modify global Git configuration.
rem -----------------------------------------------------------------
set "AUTHOR_NAME=RUSSELL PHILIP SMITHSON"
set "AUTHOR_EMAIL=russellsmithson77@outlook.com"

set "DEFAULT_COMMIT=Publish Lunar127 TIFF-GIF processable hologram - unsigned Windows build"
set "LOG=%TEMP%\Lunar127_GITHUB_PUBLISH.log"
set "SIZECHECK=%TEMP%\lunar127_git_sizecheck_%RANDOM%_%RANDOM%.ps1"

> "%LOG%" echo ================================================================
>>"%LOG%" echo Lunar127 GitHub Publish - Identity Fix
>>"%LOG%" echo Started: %DATE% %TIME%
>>"%LOG%" echo Root: %CD%
>>"%LOG%" echo Remote: %REPO_URL%
>>"%LOG%" echo ================================================================

echo ================================================================
echo   Lunar127 - GitHub Repository Publisher - IDENTITY FIX
echo ================================================================
echo.
echo Repository:
echo   %REPO_URL%
echo.
echo Local root:
echo   %CD%
echo.
echo Local Git author:
echo   %AUTHOR_NAME% ^<%AUTHOR_EMAIL%^>
echo.
echo This window remains open on success or failure.
echo Diagnostic log:
echo   "%LOG%"
echo.

where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git was not found in PATH.
    echo [ERROR] Install Git for Windows and run this CMD again.
    >>"%LOG%" echo ERROR: git.exe not found in PATH.
    goto :FAIL
)

for /f "delims=" %%V in ('git --version 2^>nul') do set "GIT_VERSION=%%V"
echo [OK] %GIT_VERSION%
>>"%LOG%" echo %GIT_VERSION%

rem -----------------------------------------------------------------
rem Initialize if needed. Safe after either of the previous attempts.
rem -----------------------------------------------------------------
if not exist ".git\" (
    echo [GIT] Initializing repository...
    git init >>"%LOG%" 2>&1
    if errorlevel 1 (
        echo [ERROR] git init failed.
        goto :FAIL
    )
) else (
    echo [OK] Existing .git repository detected.
)

rem -----------------------------------------------------------------
rem Repair the repository-local identity unconditionally.
rem The earlier script could write blank values because of CMD block
rem expansion. Explicit --local writes eliminate that ambiguity.
rem -----------------------------------------------------------------
echo [GIT] Repairing repository-local author identity...
git config --local --unset-all user.name >nul 2>&1
git config --local --unset-all user.email >nul 2>&1

git config --local user.name "%AUTHOR_NAME%" >>"%LOG%" 2>&1
if errorlevel 1 (
    echo [ERROR] Could not set repository-local user.name.
    goto :FAIL
)

git config --local user.email "%AUTHOR_EMAIL%" >>"%LOG%" 2>&1
if errorlevel 1 (
    echo [ERROR] Could not set repository-local user.email.
    goto :FAIL
)

set "VERIFY_NAME="
set "VERIFY_EMAIL="
for /f "usebackq delims=" %%A in (`git config --local --get user.name 2^>nul`) do set "VERIFY_NAME=%%A"
for /f "usebackq delims=" %%A in (`git config --local --get user.email 2^>nul`) do set "VERIFY_EMAIL=%%A"

if not defined VERIFY_NAME (
    echo [ERROR] Git returned an empty repository-local user.name.
    goto :FAIL
)
if not defined VERIFY_EMAIL (
    echo [ERROR] Git returned an empty repository-local user.email.
    goto :FAIL
)

echo [OK] Verified Git identity:
echo      %VERIFY_NAME% ^<%VERIFY_EMAIL%^>
>>"%LOG%" echo Verified Git identity: %VERIFY_NAME% ^<%VERIFY_EMAIL%^>

echo [CHECK] Asking Git to resolve the final author identity...
git var GIT_AUTHOR_IDENT
if errorlevel 1 (
    echo [ERROR] Git could not resolve a valid author identity.
    goto :FAIL
)
git var GIT_AUTHOR_IDENT >>"%LOG%" 2>&1

rem -----------------------------------------------------------------
rem Normalize branch.
rem -----------------------------------------------------------------
git branch -M "%BRANCH%" >>"%LOG%" 2>&1
if errorlevel 1 (
    echo [ERROR] Could not set branch to %BRANCH%.
    goto :FAIL
)

rem -----------------------------------------------------------------
rem Ensure requested origin.
rem -----------------------------------------------------------------
set "CURRENT_ORIGIN="
for /f "usebackq delims=" %%R in (`git remote get-url origin 2^>nul`) do set "CURRENT_ORIGIN=%%R"

if not defined CURRENT_ORIGIN goto :ADD_ORIGIN
if /I "%CURRENT_ORIGIN%"=="%REPO_URL%" goto :ORIGIN_OK

echo [GIT] Updating origin:
echo       old: %CURRENT_ORIGIN%
echo       new: %REPO_URL%
git remote set-url origin "%REPO_URL%" >>"%LOG%" 2>&1
if errorlevel 1 (
    echo [ERROR] Could not update origin.
    goto :FAIL
)
goto :ORIGIN_OK

:ADD_ORIGIN
echo [GIT] Adding origin...
git remote add origin "%REPO_URL%" >>"%LOG%" 2>&1
if errorlevel 1 (
    echo [ERROR] Could not add origin.
    goto :FAIL
)

:ORIGIN_OK
echo [OK] origin:
git remote get-url origin

rem -----------------------------------------------------------------
rem GitHub 100 MiB per-file preflight.
rem A temporary PS1 avoids CMD/PowerShell pipeline escaping problems.
rem -----------------------------------------------------------------
echo.
echo [CHECK] Scanning for files at or above 100 MiB...

> "%SIZECHECK%" echo $ErrorActionPreference = 'Stop'
>>"%SIZECHECK%" echo $root = (Get-Location).Path
>>"%SIZECHECK%" echo $bad = Get-ChildItem -LiteralPath $root -File -Recurse -Force ^| Where-Object { $_.FullName -notmatch '\\.git\\' -and $_.Length -ge 100MB }
>>"%SIZECHECK%" echo if ($bad) {
>>"%SIZECHECK%" echo   foreach ($f in $bad) {
>>"%SIZECHECK%" echo     Write-Host ('[TOO LARGE] {0}  ({1:N1} MiB)' -f $f.FullName, ($f.Length / 1MB))
>>"%SIZECHECK%" echo   }
>>"%SIZECHECK%" echo   exit 27
>>"%SIZECHECK%" echo }
>>"%SIZECHECK%" echo Write-Host '[OK] No files at or above 100 MiB.'
>>"%SIZECHECK%" echo exit 0

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SIZECHECK%"
set "SIZE_RC=%ERRORLEVEL%"
del /q "%SIZECHECK%" >nul 2>&1

if "%SIZE_RC%"=="27" (
    echo.
    echo [ERROR] One or more files are at least 100 MiB.
    echo [ERROR] GitHub will reject them through ordinary Git.
    echo [ERROR] Reduce/remove them or configure Git LFS, then retry.
    >>"%LOG%" echo ERROR: One or more files meet/exceed 100 MiB.
    goto :FAIL
)
if not "%SIZE_RC%"=="0" (
    echo.
    echo [ERROR] File-size preflight failed with exit code %SIZE_RC%.
    echo [ERROR] This is not being misreported as an oversized-file result.
    >>"%LOG%" echo ERROR: size preflight failed with exit code %SIZE_RC%.
    goto :FAIL
)

rem -----------------------------------------------------------------
rem Reachability check.
rem -----------------------------------------------------------------
echo.
echo [CHECK] Testing GitHub remote access...
git ls-remote origin >nul 2>>"%LOG%"
if errorlevel 1 (
    echo [WARN] Git could not query the remote before push.
    echo [WARN] Git Credential Manager may still authenticate during push.
) else (
    echo [OK] GitHub remote is reachable.
)

rem -----------------------------------------------------------------
rem The prior failed attempt may already have staged the repository.
rem Re-running git add -A is intentional and safe.
rem -----------------------------------------------------------------
echo.
echo [GIT] Staging repository contents...
git add -A >>"%LOG%" 2>&1
if errorlevel 1 (
    echo [ERROR] git add -A failed.
    goto :FAIL
)

echo.
echo [GIT] Staged status:
git status --short
git status --short >>"%LOG%" 2>&1

rem -----------------------------------------------------------------
rem If there is anything staged, collect a commit message OUTSIDE a
rem parenthesized CMD block so user input cannot be expanded too early.
rem -----------------------------------------------------------------
git diff --cached --quiet
if errorlevel 1 goto :MAKE_COMMIT

echo.
echo [OK] No staged changes require a new commit.
goto :PUSH

:MAKE_COMMIT
echo.
call :ASK_COMMIT_MESSAGE
echo [GIT] Creating commit...
git commit -m "%COMMIT_MSG%"
if errorlevel 1 (
    echo [ERROR] git commit failed.
    >>"%LOG%" echo ERROR: git commit failed.
    goto :FAIL
)
>>"%LOG%" echo Commit created: %COMMIT_MSG%

:PUSH
echo.
echo [GIT] Pushing %BRANCH% to GitHub...
echo [INFO] If GitHub authentication is requested, complete the
echo        Git Credential Manager/browser sign-in and return here.
echo.

git push -u origin "%BRANCH%"
set "PUSH_RC=%ERRORLEVEL%"

if not "%PUSH_RC%"=="0" (
    echo.
    echo [ERROR] Push failed with exit code %PUSH_RC%.
    echo.
    echo The Git message above is authoritative.
    echo Common causes:
    echo   - authentication was cancelled or expired
    echo   - remote commits must be reconciled
    echo   - GitHub rejected a file or repository policy
    >>"%LOG%" echo ERROR: git push failed with exit code %PUSH_RC% at %DATE% %TIME%.
    goto :FAIL
)

echo.
echo ================================================================
echo   PUBLISH SUCCESS
echo ================================================================
echo.
echo Repository:
echo   %REPO_PAGE%
echo.

set "HEAD_SHA="
for /f "usebackq delims=" %%H in (`git rev-parse HEAD 2^>nul`) do set "HEAD_SHA=%%H"
if defined HEAD_SHA echo Commit: %HEAD_SHA%

>>"%LOG%" echo SUCCESS: pushed %BRANCH% at %DATE% %TIME%.
if defined HEAD_SHA >>"%LOG%" echo HEAD: %HEAD_SHA%

echo.
echo The window will remain open until you press a key.
pause
exit /b 0

:ASK_COMMIT_MESSAGE
set "COMMIT_MSG="
set /p "COMMIT_MSG=Commit message [%DEFAULT_COMMIT%]: "
if not defined COMMIT_MSG set "COMMIT_MSG=%DEFAULT_COMMIT%"
exit /b 0

:FAIL
if exist "%SIZECHECK%" del /q "%SIZECHECK%" >nul 2>&1
echo.
echo ================================================================
echo   PUBLISH STOPPED
echo ================================================================
echo.
echo No successful push is being claimed.
echo Diagnostic log:
echo   "%LOG%"
echo.
echo The command window will remain open.
pause
exit /b 1
