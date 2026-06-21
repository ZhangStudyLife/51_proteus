@echo off
setlocal
cd /d "%~dp0"
if not exist build_all mkdir build_all
xelatex -interaction=nonstopmode -halt-on-error -output-directory=build_all merge_all_reports.tex
if errorlevel 1 goto err
copy /Y build_all\merge_all_reports.pdf 51_proteus_all_reports.pdf >nul
echo Build success: 51_proteus_all_reports.pdf
exit /b 0
:err
echo Build failed. See build_all\merge_all_reports.log
exit /b 1
