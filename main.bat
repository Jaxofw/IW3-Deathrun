set COMPILEDIR=%CD%
set map="mp_dr_anotherworld"
set options="+set fs_game "mods/arcane_deathrun_dev" +g_gametype deathrun" +exec server.cfg
@ECHO OFF

:MainMenu
CLS

ECHO 1. Build IWD
ECHO 2. Build Mod
ECHO 3. Run Mod
ECHO 4. Run Server
ECHO 5. Exit
ECHO.

CHOICE /C 12345 /M "Enter your choice: "

IF ERRORLEVEL 5 GOTO CloseAll
IF ERRORLEVEL 4 GOTO RunServer
IF ERRORLEVEL 3 GOTO RunMod
IF ERRORLEVEL 2 GOTO BuildMod
IF ERRORLEVEL 1 GOTO BuildIwd
pause

:BuildIwd
del arcane.iwd

7za a -r -tzip arcane.iwd images/
7za a -r -tzip arcane.iwd weapons/
7za a -r -tzip arcane.iwd sound/
goto MainMenu

:BuildMod
del mod.ff

xcopy animtrees ..\..\raw\animtrees /SY
xcopy braxi ..\..\raw\braxi /SY
xcopy english ..\..\raw\english /SY
xcopy fx ..\..\raw\fx /SY
xcopy images ..\..\raw\images /SY
xcopy maps ..\..\raw\maps /SY
xcopy material_properties ..\..\raw\material_properties /SY
xcopy materials ..\..\raw\materials /SY
xcopy mp ..\..\raw\mp /SY
xcopy rumble ..\..\raw\rumble /SY
xcopy soundaliases ..\..\raw\soundaliases /SY
xcopy sound ..\..\raw\sound /SY
xcopy ui_mp ..\..\raw\ui_mp /SY
xcopy weapons ..\..\raw\weapons /SY
xcopy xanim ..\..\raw\xanim /SY
xcopy xmodel ..\..\raw\xmodel /SY
xcopy xmodelparts ..\..\raw\xmodelparts /SY
xcopy xmodelsurfs ..\..\raw\xmodelsurfs /SY
copy /Y mod.csv ..\..\zone_source

cd ..\..\bin
linker_pc.exe -language english -compress -cleanup mod
cd %COMPILEDIR%
copy ..\..\zone\english\mod.ff
goto MainMenu

:RunMod
pushd ..\..\
iw3mp.exe %options% +set developer 2 +set developer_script 1 +devmap %map%
exit

:RunServer
pushd ..\..\
cod4x18_dedrun.exe %options% +set dedicated 2 +set net_port 28961 +map %map%
exit

:CloseAll
exit