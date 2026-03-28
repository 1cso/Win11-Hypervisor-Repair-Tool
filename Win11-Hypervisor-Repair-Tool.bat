@echo off
:: =============================================================
:: Win10/11 Hypervisor Repair Tool v1.1 (Final)
:: Supports: Windows 10 & 11
:: Focus: Hypervisor-related BSOD diagnostics + smart repair
:: =============================================================

set version=1.1
set logfile=%~dp0repair_log.txt
set report=%~dp0system_report.txt
set bcdbackup=%~dp0bcd_backup.txt
set silent=0
set dry=0

if "%1"=="/silent" set silent=1
if "%1"=="/dry" set dry=1

color 0A
title Hypervisor Repair Tool v%version%

:: Admin check
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Run as Administrator!
    pause
    exit /b 1
)

:: Init logs
echo ============================================== >> %logfile%
echo [%date% %time%] Tool started v%version% >> %logfile%

:: OS check
ver | find "10.0." >nul
if %errorlevel% neq 0 (
    echo [WARNING] Unsupported Windows version >> %logfile%
)

:: Backup BCD
bcdedit /enum > %bcdbackup% 2>&1

:menu
if %silent%==1 goto full
cls
echo ============================================
echo   Hypervisor Repair Tool v%version%
echo ============================================
echo.
echo [1] Diagnostics + Analysis
echo [2] Create Restore Point
echo [3] Disable Hyper-V stack
echo [4] Repair system (SFC + DISM)
echo [5] Full Smart Repair
echo [0] Exit
set /p choice=Select option: 

if "%choice%"=="1" goto diagnostics
if "%choice%"=="2" goto restore
if "%choice%"=="3" goto disableHV
if "%choice%"=="4" goto repair
if "%choice%"=="5" goto full
if "%choice%"=="0" exit /b 0

goto menu

:restore
call :confirm
if errorlevel 1 goto menu

echo Creating restore point...
powershell -Command "Checkpoint-Computer -Description 'HypervisorFix' -RestorePointType 'MODIFY_SETTINGS'" >> %logfile% 2>&1
pause
goto menu

:diagnostics
cls
echo Running diagnostics...
echo ==== SYSTEM REPORT ==== > %report%

systeminfo >> %report%

echo --- Hypervisor --- >> %report%
bcdedit | find "hypervisorlaunchtype" >> %report%

echo --- CPU --- >> %report%
wmic cpu get Name,VirtualizationFirmwareEnabled >> %report%

echo --- VBS --- >> %report%
powershell -Command "Get-CimInstance Win32_DeviceGuard" >> %report% 2>&1

echo --- VM Software --- >> %report%
wmic product get name | findstr /i "vmware virtualbox" >> %report%

wsl --status >> %report% 2>&1
sc query vmcompute >> %report% 2>&1

echo --- Dumps --- >> %report%
dir C:\Windows\Minidump >> %report% 2>&1

:: Analysis
echo --- ANALYSIS --- >> %report%

wmic cpu get VirtualizationFirmwareEnabled | find "FALSE" >nul
if %errorlevel%==0 echo [CRITICAL] Virtualization disabled in BIOS >> %report%

bcdedit | find "Off" >nul
if %errorlevel%==0 echo [INFO] Hypervisor disabled >> %report%

wmic product get name | find /i "vmware" >nul
if %errorlevel%==0 echo [WARNING] VMware conflict possible >> %report%

wmic product get name | find /i "virtualbox" >nul
if %errorlevel%==0 echo [WARNING] VirtualBox conflict possible >> %report%

echo Report saved: %report%
pause
goto menu

:disableHV
call :confirm
if errorlevel 1 goto menu
call :disableHV_internal
pause
goto menu

:disableHV_internal
bcdedit | find "Off" >nul
if %errorlevel%==0 (
    echo [SKIP] Hypervisor already off >> %logfile%
    exit /b 0
)

echo Disabling Hyper-V >> %logfile%
if %dry%==1 (
    echo [DRY] Skip disable >> %logfile%
    exit /b 0
)

dism /Online /Disable-Feature:Microsoft-Hyper-V-All /NoRestart >> %logfile% 2>&1
dism /Online /Disable-Feature:VirtualMachinePlatform /NoRestart >> %logfile% 2>&1
dism /Online /Disable-Feature:HypervisorPlatform /NoRestart >> %logfile% 2>&1
bcdedit /set hypervisorlaunchtype off >> %logfile% 2>&1
exit /b 0

:repair
echo Running SFC >> %logfile%
sfc /scannow >> %logfile% 2>&1

echo Running DISM >> %logfile%
dism /Online /Cleanup-Image /RestoreHealth >> %logfile% 2>&1

pause
goto menu

:full
cls
echo Starting SMART repair...

call :restore
call :disableHV_internal
call :repair

:: Disk
for %%d in (C D E F) do (
    if exist %%d:\ (
        echo Checking %%d: >> %logfile%
        echo Y | chkdsk %%d: /f /r >> %logfile% 2>&1
    )
)

:: Disable VBS
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f >> %logfile%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f >> %logfile%

:: Final evaluation
bcdedit | find "Off" >nul
if %errorlevel%==0 (
    echo [SUCCESS] Hypervisor disabled >> %logfile%
) else (
    echo [FAIL] Hypervisor still enabled >> %logfile%
)


echo ============================================
echo REPAIR COMPLETE - REBOOT REQUIRED
echo ============================================
pause
exit /b 0

:confirm
if %silent%==1 exit /b 0
set /p confirm=Proceed? (y/n): 
if /i not "%confirm%"=="y" exit /b 1
exit /b 0
