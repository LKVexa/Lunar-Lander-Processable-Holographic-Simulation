@echo off
setlocal
cd /d "%~dp0"
set "FORMAT=gif"
if /I "%~1"=="tiff" set "FORMAT=tiff"
if /I "%~1"=="gif" set "FORMAT=gif"
call "%CD%\BOOT.cmd" %FORMAT% reset
