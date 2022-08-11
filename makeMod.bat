del mod.ff

xcopy braxi ..\..\raw\braxi /SY
xcopy images ..\..\raw\images /SY
xcopy maps ..\..\raw\maps /SY
xcopy material_properties ..\..\raw\material_properties /SY
xcopy materials ..\..\raw\materials /SY
xcopy ui_mp ..\..\raw\ui_mp /SY

copy /Y mod.csv ..\..\zone_source

cd ..\..\bin
linker_pc.exe -language english -compress -cleanup mod
cd ..\mods\arcane_deathrun_dev
copy ..\..\zone\english\mod.ff

pause