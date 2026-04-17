@echo off
setlocal
cd /d "%~dp0"
if not exist build mkdir build
xelatex -interaction=nonstopmode -halt-on-error -output-directory=build main.tex
if errorlevel 1 goto :err
xelatex -interaction=nonstopmode -halt-on-error -output-directory=build main.tex
if errorlevel 1 goto :err
copy /Y build\main.pdf ..\Experiment2_Report.pdf >nul
echo Build success. PDF: ..\Experiment2_Report.pdf
exit /b 0
:err
echo Build failed. See build\main.log
exit /b 1
