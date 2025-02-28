@echo off
setlocal EnableDelayedExpansion

::Set Config
set ConfigFile=rconfig.txt
if not exist !ConfigFile! (
    echo Config file not found, using default settings > rconfig.txt
    echo https://drive.usercontent.google.com/download?id={1NfzOGFMGUFn8dd8O946b5gYCegFjtwu4}^&confirm=xxx > rconfig.txt
    echo EMULATOR\dev_hdd0\game\BLJM60066\USRDIR\ >> rconfig.txt
    echo EMULATOR\dev_hdd0\game\BLJM55005\USRDIR\ >> rconfig.txt
    echo EMULATOR\dev_hdd0\game\BLUS30187\USRDIR\ >> rconfig.txt
    echo dev_hdd0\game\BLJM60066\USRDIR\ >> rconfig.txt
    echo dev_hdd0\game\BLJM55005\USRDIR\ >> rconfig.txt
    echo dev_hdd0\game\BLUS30187\USRDIR\ >> rconfig.txt
)

for /f "tokens=1" %%A in (%configFile%) do (
    set url=%%A
    goto :exit_1
)
:exit_1

::Download
echo Checking Regulation Updates...
curl -o regulation.tmp !url!

::Hash of new file
for /f "skip=1" %%A in ('certutil -hashfile regulation.tmp SHA256') do (
    set newhash=%%A
    goto :exit_2

)
:exit_2

::Set Directory
set count=0
for /f "skip=1 tokens=*" %%A in (%ConfigFile%) do (
    if exist %%A (
        set /a count+=1
        set "array[!count!]=%%A"
    )
)

::Replace
for /l %%A in (1,1,!count!) do (
    call :SUB !array[%%A]! !newhash!
)
del regulation.tmp
endlocal

::Boot Game
if exist rpcs3.exe (
    start rpcs3.exe
)
if exist EMULATOR\rpcs3.exe (
    start EMULATOR\rpcs3.exe
)
exit /b

:SUB
@echo off
setlocal EnableDelayedExpansion
set dir=%1
set newhash=%2
for /f "skip=1" %%A in ('certutil -hashfile !dir!regulation.bin SHA256') do (
    set oldhash=%%A
    goto :exit_3
)
:exit_3
if not !newhash!==!oldhash! (
    if exist !dir!\regulation.bin.bak (
        del !dir!\regulation.bin.bak
    )
    if exist !dir!\regulation.bin (
        ren !dir!\regulation.bin regulation.bin.bak
    )
    copy regulation.tmp !dir!\regulation.bin > nul
    echo Latest regulation file is applied to this directory: !dir!
) else (
    echo Regulation file is already latest in this directory: !dir!
)

endlocal
exit /b