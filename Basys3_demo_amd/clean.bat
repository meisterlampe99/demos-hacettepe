
@echo off

REM clean up working directory
DEL vivado*.zip >nul 2>&1
DEL vivado*.jou >nul 2>&1
DEL vivado*.log >nul 2>&1
DEL webtalk*.jou >nul 2>&1
DEL webtalk*.log >nul 2>&1
RMDIR /S /Q outputSim >nul 2>&1
RMDIR /S /Q outputBit >nul 2>&1
RMDIR /S /Q .Xil >nul 2>&1
ECHO ------------------------------------
ECHO CMDscripts4Vivado: all (or most) output files, folders and vivado logs removed
 