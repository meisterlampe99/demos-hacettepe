
@echo off
REM Check if an argument was provided
if "%~1"=="" (
    echo Usage: runSim.bat TopModuleName [Optional: DUTname]
    exit /b 1
)

set TopModuleName=%~1
set DUTName=%~2

REM clean up working directory
DEL vivado*.zip >nul 2>&1
DEL vivado*.jou >nul 2>&1
DEL vivado*.log >nul 2>&1
DEL webtalk*.jou >nul 2>&1
DEL webtalk*.log >nul 2>&1
RMDIR /S /Q outputSim >nul 2>&1
RMDIR /S /Q .Xil >nul 2>&1


REM Run Vivado in tcl mode with the provided top module name
vivado -mode tcl -source npm_runSim.tcl -tclarg %TopModuleName% %DUTName%
