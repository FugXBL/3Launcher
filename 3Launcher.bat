@echo off
:: 3Launcher (Preset Creation & Loading Tool)
:: Version: 2.1
:: Author: Ndt

:: Check if preset is passed in
color 09
if "%~1"=="" (
    goto :Initialize
) else (
    goto :LoadPreset
)
pause

:: Initialize variables
:Initialize
setlocal enableextensions
set "config_file=%~dp0bo3_config.ini"
setlocal enabledelayedexpansion
if exist "%config_file%" (
    for /f "tokens=1,* delims==" %%A in ('type "%config_file%" ^| find "="') do (
        set "%%A=%%B"
        set "%%A=!%%A:"=!"
    )
    goto :checkadmin
) else (
    goto :InitialSetup
)

::Sets to admin if configured to do so
:checkadmin
if "%startadmin%"=="true" (
    goto :setadmin
)
goto :Main

:: Check if the script is running as Administrator
:setadmin
NET SESSION >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Requesting administrator privileges...
    :: Relaunch the script with administrator rights
    powershell -Command "Start-Process '%0' -Verb runAs"
    exit /b
)

:: Validate loaded variables
if not defined BO3_RootFolder (
    color 04
    echo.
    echo ============================
    echo       Script Error        
    echo ============================
    echo.
    echo Config file missing required variables. Reconfiguring...
    pause >nul
    goto :InitialSetup
)

:: Function: Main Script Execution
:Main
cls
color 03
echo =========================================
echo             Ndt's 3Launcher         
echo =========================================
echo [1] Start Script
echo [2] Reconfigure Settings
echo [3] Create Preset
echo [4] Exit
echo.
set /p choice="Enter your choice (1/2/3/4): "

if "%choice%"=="1" goto :Start
if "%choice%"=="2" goto :InitialSetup
if "%choice%"=="3" goto :CreatePreset
if "%choice%"=="4" exit
goto :Main

:: Function: Initial Setup
:InitialSetup
cls
color 08
echo =========================================
echo         Initial Configuration           
echo =========================================

:: Step 1: Get BO3 Path
set "BO3_ExePath=null"
echo.
echo Please specify your BO3 exe file path.
echo Example: C:\XboxGames\Call of Duty Black Ops 3\Content\BlackOps3.exe.
echo This would be used to launch BO3 after the script runs.
set /p "BO3_ExePath=BO3 EXE Path: "
set "BO3_ExePath=%BO3_ExePath:"=%"
if "%BO3_ExePath%"=="null" set "BO3_ExePath=C:\XboxGames\Call of Duty Black Ops 3\Content\BlackOps3.exe"
if not exist "%BO3_ExePath%" (
    goto error_noexe
)
if not exist "%BO3_ExePath%" (
    goto error_noexe
)

:: Step 5: Get Source Folder
set "source_folder=null"
echo.
echo Please specify your source folder (nested under Saves folder). The contents inside
echo will be injected into BO3's player folder. Leave blank to default to save.
set /p "source_folder=Source Folder Name: "
if "%source_folder%"=="null" set "source_folder=save"
echo Source Folder set to: %source_folder%

:: Version
set "bo3version=null"
echo.
echo What version of the game are you running?
echo [1] Steam
echo [2] Microsoft Store
echo.
set /p choice="Enter your choice (1/2): "
if "%choice%"=="1" (
    set "bo3version=steam"
    goto :steam_setup
) else if /i "%choice%"=="steam" (
    set "bo3version=steam"
    goto :steam_setup
) else (
    set "bo3version=msstore"
    goto :msstore_setup
)

:steam_setup
:: Get BO3 Players Folder
set "BO3_RootFolder=null"
echo.
echo Please specify the players folder for the Steam Version of Black Ops 3.
echo Default Value: %ProgramFiles(x86)%\Steam\steamapps\common\Call of Duty Black Ops III\players
echo Leave empty to use default value
set /p "BO3_RootFolder=Player Folder Path: "
set "BO3_RootFolder=%BO3_RootFolder:"=%"
if "%BO3_RootFolder%"=="null" set "BO3_RootFolder=%ProgramFiles(x86)%\Steam\steamapps\common\Call of Duty Black Ops III\players"
if not exist "%BO3_RootFolder%" (
    goto :error_nofolder
)
goto :config_save


:msstore_setup
:: Get BO3 Root Folder
set "BO3_RootFolder=null"
echo.
echo Please specify your Windows version BO3 root folder
echo Default Value: %LocalAppData%\Packages\38985CA0.CallofDutyBlackOps3PCMS_5bkah9njm3e9g
echo Leave empty to use default value
set /p "BO3_RootFolder=Root Folder Path: "
set "BO3_RootFolder=%BO3_RootFolder:"=%"
if "%BO3_RootFolder%"=="null" set "BO3_RootFolder=%LocalAppData%\Packages\38985CA0.CallofDutyBlackOps3PCMS_5bkah9njm3e9g"
if not exist "%BO3_RootFolder%" (
    goto :error_nofolder
)

:: Get Player ID Folder Name
set "PlayerIDFolder=null"
echo.
echo Please specify your Player ID folder name.
echo If you are confused, check out the xgs folder in the BO3 root.
echo If you have used multiple Xbox accounts on BO3, you'll see multiple folders pop up.
set /p "PlayerIDFolder=Player ID Folder (leave blank to auto-detect): "
set "PlayerIDFolder=%PlayerIDFolder:"=%"
:: Check if PlayerIDFolder was left blank
if "%PlayerIDFolder%"=="null" (
    echo No Player ID Folder specified. Attempting to auto-detect...
    for /d %%F in ("%BO3_RootFolder%\SystemAppData\xgs\*") do (
        set "PlayerIDFolder=%%~nF"
        goto :FolderFound
    )
    goto :error_nofolder
)

:FolderFound
if not exist "%BO3_RootFolder%\SystemAppData\xgs\%PlayerIDFolder%" (
    echo Specified Player ID Folder does not exist: %PlayerIDFolder%
    goto :error_nofolder
)
echo Player ID Folder detected/set to: %PlayerIDFolder%

:: Disable Internet
set "nowifi=null"
echo.
echo Do you want the script to initiate the brute force workaround?
echo This will disable Wi-Fi while injecting the saves while also setting the
echo saves to read-only. This is recommended when running the MS Store version
echo of Black Ops 3, as this may be the only way to actually get the save working.
echo This will also delete the wgs folder under the BO3 root.
echo [1] Yes
echo [2] No
echo.
set /p choice="Enter your choice (1/2): "
if "%choice%"=="1" (
    set "nowifi=true"
) else (
    set "nowifi=false"
    goto :ms_autoadmin
)

:: Get Internet Interface Name
set "InterfaceName=null"
echo.
echo Please specify your Internet Interface Name.
echo Leave blank to default to Wi-Fi 7.
netsh interface show interface
echo You must select the correct interface. This is so that the internet can get disabled
echo by the script so that the save files don't get wiped. Administrator privilidges will
echo need to be required for this part of the script to run though.
set /p "InterfaceName=Wi-Fi Interface Name: "
set "InterfaceName=%InterfaceName:"=%"
if "%InterfaceName%"=="null" set "InterfaceName=Wi-Fi 7"

:ms_autoadmin
:: Auto-Admin
set "startadmin=null"
echo.
echo Do you want the script to automatically start as administrator?
echo [1] Yes
echo [2] No
echo.
set /p choice="Enter your choice (1/2): "
if "%choice%"=="1" (
    set "startadmin=true"
) else (
    set "startadmin=false"
)

:: Save configuration
:config_save
echo BO3_RootFolder="%BO3_RootFolder%"> "%config_file%"
echo PlayerIDFolder="%PlayerIDFolder%">> "%config_file%"
echo InterfaceName="%InterfaceName%">> "%config_file%"
echo BO3_ExePath="%BO3_ExePath%">> "%config_file%"
echo source_folder="%source_folder%">> "%config_file%"
echo startadmin="%startadmin%">> "%config_file%"
echo nowifi="%nowifi%">> "%config_file%"
echo bo3version="%bo3version%">> "%config_file%"

goto :script_complete

:: Function: Create Preset
:CreatePreset
cls
color 03
echo =========================================
echo         Create New Preset File            
echo =========================================
echo.
set /p "preset_name=Enter Preset Name (e.g., preset1): "
echo Creating preset: %preset_name%

:: Save new preset configuration
set "preset_file=%~dp0\Presets\%preset_name%.ini"
if not exist "%~dp0\Presets" (
    mkdir "%~dp0\Presets"
)
echo BO3_RootFolder="%BO3_RootFolder%"> "%preset_file%"
echo PlayerIDFolder="%PlayerIDFolder%">> "%preset_file%"
echo InterfaceName="%InterfaceName%">> "%preset_file%"
echo BO3_ExePath="%BO3_ExePath%">> "%preset_file%"
echo source_folder="%source_folder%">> "%preset_file%"
echo startadmin="%startadmin%">> "%preset_file%"
echo nowifi="%nowifi%">> "%preset_file%"
echo bo3version="%bo3version%">> "%preset_file%"

:: Create batch file for the preset
set "batch_file=%~dp0\Presets\%preset_name%.bat"
echo @echo off > "%batch_file%"
echo :: BO3 Preset Automation >> "%batch_file%"
echo setlocal enableextensions >> "%batch_file%"
setlocal enabledelayedexpansion
echo goto :Start >> "%batch_file%"
echo :Start >> "%batch_file%" >> "%batch_file%"
echo color 02 >> "%batch_file%"
echo echo Starting BO3 Automation for preset: %preset_name% >> "%batch_file%"
echo call "%~dp03Launcher.bat" "%preset_name%" >> "%batch_file%"

:: Create shortcut to run the batch file as administrator
set "shortcut_path=%~dp0\Presets\%preset_name%.lnk"
set "vbs_script=%~dp0\Presets\create_shortcut.vbs"

:: Generate VBScript to create a shortcut with administrator privileges
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%vbs_script%"
echo Set oLink = oWS.CreateShortcut("%shortcut_path%") >> "%vbs_script%"
echo oLink.TargetPath = "%~dp0\Presets\%preset_name%.bat" >> "%vbs_script%"
echo oLink.Arguments = "" >> "%vbs_script%"
echo oLink.WorkingDirectory = "%~dp0" >> "%vbs_script%"
echo oLink.IconLocation = "%~dp03Launcher.ico" >> "%vbs_script%"
echo oLink.WindowStyle = 1 >> "%vbs_script%"
echo oLink.Description = "BO3 Preset Automation for %preset_name%" >> "%vbs_script%"
echo oLink.Save >> "%vbs_script%"

:: Add "Run as Administrator" registry edit
echo Set objShell = CreateObject("WScript.Shell") >> "%vbs_script%"
echo objShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bat\userchoice", "RunAsAdmin" >> "%vbs_script%"

:: Run the VBScript to create the shortcut
cscript //nologo "%vbs_script%"

:: Clean up VBScript after creating the shortcut
del "%vbs_script%"
echo Shortcut created successfully for %preset_name% with administrator privileges.

goto :script_complete

:: Function: Load Preset
:LoadPreset
echo Loading preset: %~1
set "config_file=%~dp0\Presets\%~1.ini"
set "preset_script=%~dp0\Presets\%~1.bat"
setlocal enableextensions
setlocal enabledelayedexpansion
if exist "%config_file%" (
    for /f "tokens=1,* delims==" %%A in ('type "%config_file%" ^| find "="') do (
        set "%%A=%%B"
        set "%%A=!%%A:"=!"
    )
    goto :start_preset
) else (
    goto :error_nopreset
)

:start_preset
if "%startadmin%"=="true" (
    goto :setadmin2
)
goto :Start

:: Check if the script is running as Administrator
:setadmin2
NET SESSION >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Requesting administrator privileges...
    :: Relaunch the script with administrator rights
    powershell -Command "Start-Process '%preset_script%' -Verb runAs"
    exit /b
)

:: Function: Start Script Execution
:Start
cls
echo =========================================
echo       Starting 3Launcher Script     
echo =========================================

if not exist "%~dp0\Saves" (
    mkdir "%~dp0\Saves"
)
color 01

:: Copy files (depending on version)
if "%bo3version%"=="msstore" (
    echo Copying files from %~dp0Saves\%source_folder% to %BO3_RootFolder%\SystemAppData\xgs\%PlayerIDFolder%\players...
    set "source_path=%~dp0Saves\%source_folder%"
    set "destination_folder=%BO3_RootFolder%\SystemAppData\xgs\%PlayerIDFolder%\players"
    set "wgs_folder=%BO3_RootFolder%\SystemAppData\wgs"
    goto copyfolders
)

if "%bo3version%"=="steam" (
    echo Copying files from %~dp0Saves\%source_folder% to %BO3_RootFolder%...
    set "source_path=%~dp0Saves\%source_folder%"
    set "destination_folder=%BO3_RootFolder%"
    goto copyfolders
)

:copyfolders
if not exist "%source_path%" (
    goto error_nofolder
)
if not exist "%BO3_RootFolder%" (
    goto error_nofolder
)
:: Attempt to copy files and handle errors
echo Copying files...
xcopy "%source_path%\*" "%destination_folder%\" /Y >nul 2>error.log

:: Check for errors
findstr /I /C:"sharing violation" error.log >nul
if %errorlevel%==0 goto force_delete
findstr /I /C:"access denied" error.log >nul
if %errorlevel%==0 goto force_delete

echo Files copied successfully.
del error.log
goto after_copy

:force_delete
echo Sharing violation or access denied detected. Forcing deletion of conflicting files...
for %%F in ("%source_path%\*") do (
    if exist "%destination_folder%\%%~nxF" (
        echo Deleting "%destination_folder%\%%~nxF"...
        del /F /Q "%destination_folder%\%%~nxF"
    )
)

:: Retry copying after deletion
xcopy "%source_path%\*" "%destination_folder%\" /Y
echo Files copied successfully after forced deletion.
del error.log

:after_copy
:: Brute force method for the MS Store version of BO3
if "%nowifi%"=="true" if "%bo3version%"=="msstore" (
    echo Setting files to read-only...
    attrib +R "%destination_folder%\*.*"
    echo Deleting WGS folder...
    if exist "%wgs_folder%" (
        rd /s /q "%wgs_folder%"
        echo WGS folder deleted.
    )
    echo Disabling Internet connection...
    netsh interface set interface name="%InterfaceName%" admin=disabled
    echo Internet disabled.
    set "internet_disabled=true"
)

:: Launch Game
echo Launching game...
if exist "%BO3_ExePath%" (
    start "" "%BO3_ExePath%"
) else (
    goto error_noexe
)

:: If the internet was initially disabled, the script will wait for you to re-enable it
if "%internet_disabled%"=="true" (
    echo.
    echo Press any key to re-enable Internet...
    pause >nul
    netsh interface set interface name="%InterfaceName%" admin=enabled
    echo Internet re-enabled.
    echo Removing read-only attributes...
    attrib -R "%destination_folder%\*.*"
    echo File attributes reset.
)

exit /b

:script_complete
color 02
echo.
echo ========================
echo       Script Fired     
echo ========================
echo.
echo Script tasks completed successfully! Press any key to return to script...
pause>nul
goto :Main

:error_nofolder
color 04
echo.
echo ========================
echo       Script Error     
echo ========================
echo.
echo Folder does not exist or is empty! Press any key to return to script...
pause>nul
goto :Main

:error_noexe
color 04
echo.
echo ========================
echo       Script Error     
echo ========================
echo.
echo Game executable not found! Press any key to key to return to script...
pause>nul
goto :Main

:error_nopreset
color 04
echo.
echo ========================
echo       Script Error     
echo ========================
echo.
echo Preset configurations not found! Press any key to exit script...
pause>nul
exit /b
