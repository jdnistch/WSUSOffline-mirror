@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions enabledelayedexpansion
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=

%~d0
cd "%~p0"

set WSUSOFFLINE_VERSION=6.7b (r170)
set DOWNLOAD_LOGFILE=..\log\download.log
title %~n0 %1 %2
echo Starting WSUS Offline Update download (v. %WSUSOFFLINE_VERSION%) for %1 %2...
if exist %DOWNLOAD_LOGFILE% (
  echo. >>%DOWNLOAD_LOGFILE%
  echo -------------------------------------------------------------------------------- >>%DOWNLOAD_LOGFILE%
  echo. >>%DOWNLOAD_LOGFILE%
)
echo %DATE% %TIME% - Info: Starting download (v. %WSUSOFFLINE_VERSION%) for %1 %2 >>%DOWNLOAD_LOGFILE%

for %%i in (wxp w2k3 w2k3-x64) do (
  if /i "%1"=="%%i" (
    for %%j in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%2"=="%%j" goto EvalParams)
  )
)
for %%i in (w60 w60-x64 w61 w61-x64) do (
  if /i "%1"=="%%i" (
    if /i "%2"=="glb" goto EvalParams
  )
)
for %%i in (oxp o2k3 o2k7 o2k10) do (
  if /i "%1"=="%%i" (
    for %%j in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%2"=="%%j" goto Lang_%%j)
  )
)
goto InvalidParams

:Lang_enu
set LANG_SHORT=en
goto EvalParams

:Lang_fra
set LANG_SHORT=fr
goto EvalParams

:Lang_esn
set LANG_SHORT=es
goto EvalParams

:Lang_jpn
set LANG_SHORT=ja
goto EvalParams

:Lang_kor
set LANG_SHORT=ko
goto EvalParams

:Lang_rus
set LANG_SHORT=ru
goto EvalParams

:Lang_ptg
set LANG_SHORT=pt
goto EvalParams

:Lang_ptb
set LANG_SHORT=pt-br
goto EvalParams

:Lang_deu
set LANG_SHORT=de
goto EvalParams

:Lang_nld
set LANG_SHORT=nl
goto EvalParams

:Lang_ita
set LANG_SHORT=it
goto EvalParams

:Lang_chs
set LANG_SHORT=zh-cn
goto EvalParams

:Lang_cht
set LANG_SHORT=zh-tw
goto EvalParams

:Lang_plk
set LANG_SHORT=pl
goto EvalParams

:Lang_hun
set LANG_SHORT=hu
goto EvalParams

:Lang_csy
set LANG_SHORT=cs
goto EvalParams

:Lang_sve
set LANG_SHORT=sv
goto EvalParams

:Lang_trk
set LANG_SHORT=tr
goto EvalParams

:Lang_ell
set LANG_SHORT=el
goto EvalParams

:Lang_ara
set LANG_SHORT=ar
goto EvalParams

:Lang_heb
set LANG_SHORT=he
goto EvalParams

:Lang_dan
set LANG_SHORT=da
goto EvalParams

:Lang_nor
set LANG_SHORT=no
goto EvalParams

:Lang_fin
set LANG_SHORT=fi
goto EvalParams

:EvalParams
if "%3"=="" goto NoMoreParams
for %%i in (/excludesp /excludestatics /includedotnet /nocleanup /verify /exitonerror /skipmkisofs /proxy /wsus) do (
  if /i "%3"=="%%i" echo %DATE% %TIME% - Info: Option %%i detected >>%DOWNLOAD_LOGFILE%
)
if /i "%3"=="/excludesp" set EXCLUDE_SP=1
if /i "%3"=="/excludestatics" set EXCLUDE_STATICS=1
if /i "%3"=="/includedotnet" set INCLUDE_DOTNET=1
if /i "%3"=="/includemsse" set INCLUDE_MSSE=1
if /i "%3"=="/nocleanup" set CLEANUP_DOWNLOADS=0
if /i "%3"=="/verify" set VERIFY_DOWNLOADS=1
if /i "%3"=="/exitonerror" set EXIT_ON_ERROR=1
if /i "%3"=="/skipmkisofs" set SKIP_MKISOFS=1
if /i "%3"=="/proxy" (
  set http_proxy=%4
  shift /3
)
if /i "%3"=="/wsus" (
  set HTTP_WSUS=%4
  shift /3
)
shift /3
goto EvalParams

:NoMoreParams
echo %1 | %SystemRoot%\system32\find.exe /I "x64" >nul 2>&1
if errorlevel 1 (set TARGET_ARCH=x86) else (set TARGET_ARCH=x64)

if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd

set CSCRIPT_PATH=%SystemRoot%\system32\cscript.exe
if not exist %CSCRIPT_PATH% goto NoCScript
set WGET_PATH=..\bin\wget.exe
if not exist %WGET_PATH% goto NoWGet
if not exist ..\bin\unzip.exe goto NoUnZip

title Downloading...

rem *** Clean up existing directories ***
echo Cleaning up existing directories...
if exist ..\iso\dummy.txt del ..\iso\dummy.txt
if exist ..\log\dummy.txt del ..\log\dummy.txt
if exist ..\exclude\custom\dummy.txt del ..\exclude\custom\dummy.txt
if exist ..\static\custom\dummy.txt del ..\static\custom\dummy.txt
if exist ..\client\exclude\custom\dummy.txt del ..\client\exclude\custom\dummy.txt
if exist ..\client\static\custom\dummy.txt del ..\client\static\custom\dummy.txt

rem *** Obsolete internal stuff ***
if exist ..\doc\faq.txt del ..\doc\faq.txt 
if exist ..\static\StaticDownloadLinks-mkisofs.txt del ..\static\StaticDownloadLinks-mkisofs.txt
if exist ..\static\StaticDownloadLink-unzip.txt del ..\static\StaticDownloadLink-unzip.txt
if exist DetermineRegVersion.vbs del DetermineRegVersion.vbs
if exist DetermineAutoDaylightTimeSet.vbs del DetermineAutoDaylightTimeSet.vbs
if exist ..\client\cmd\Reboot.vbs del ..\client\cmd\Reboot.vbs
if exist ..\client\msi\nul call ..\client\cmd\SafeRmDir.cmd ..\client\msi

rem *** Office 2000 stuff ***
if exist ..\client\bin\msxsl.exe move /Y ..\client\bin\msxsl.exe ..\bin >nul
if exist ..\client\xslt\nul rd /S /Q ..\client\xslt
if exist ..\client\static\StaticUpdateIds-o2k.txt del ..\client\static\StaticUpdateIds-o2k.txt
if exist ..\exclude\ExcludeList-o2k.txt del ..\exclude\ExcludeList-o2k.txt
if exist ..\exclude\ExcludeListISO-o2k.txt del ..\exclude\ExcludeListISO-o2k.txt
if exist ..\exclude\ExcludeListUSB-o2k.txt del ..\exclude\ExcludeListUSB-o2k.txt
del /Q ..\static\*o2k-*.* >nul 2>&1
del /Q ..\xslt\*o2k-*.* >nul 2>&1
if exist ..\xslt\ExtractExpiredIds-o2k.xsl del ..\xslt\ExtractExpiredIds-o2k.xsl
if exist ..\xslt\ExtractValidIds-o2k.xsl del ..\xslt\ExtractValidIds-o2k.xsl

rem *** .NET restructuring stuff ***
if exist ..\client\win\glb\ndp*.* (
  if not exist ..\client\dotnet\x86-glb\nul md ..\client\dotnet\x86-glb
  move /Y ..\client\win\glb\ndp*.* ..\client\dotnet\x86-glb >nul
)
if exist ..\client\w2k3-x64\glb\ndp*.* (
  if not exist ..\client\dotnet\x64-glb\nul md ..\client\dotnet\x64-glb
  move /Y ..\client\w2k3-x64\glb\ndp*.* ..\client\dotnet\x64-glb >nul
)
if exist ..\static\StaticDownloadLink-dotnet.txt del ..\static\StaticDownloadLink-dotnet.txt
if exist ..\xslt\ExtractDownloadLinks-dotnet-glb.xsl del ..\xslt\ExtractDownloadLinks-dotnet-glb.xsl
if exist ..\client\dotnet\glb\nul (
  if not exist ..\client\dotnet\x64-glb\nul md ..\client\dotnet\x64-glb
  move /Y ..\client\dotnet\glb\*-x64_*.* ..\client\dotnet\x64-glb >nul
  if not exist ..\client\dotnet\x86-glb\nul md ..\client\dotnet\x86-glb
  move /Y ..\client\dotnet\glb\*-x86_*.* ..\client\dotnet\x86-glb >nul
  rd /S /Q ..\client\dotnet\glb
)

rem *** FCIV stuff ***
if exist ..\bin\fciv.exe del ..\bin\fciv.exe
if exist ..\fciv\nul rd /S /Q ..\fciv
if exist ..\static\StaticDownloadLink-fciv.txt del ..\static\StaticDownloadLink-fciv.txt

rem *** WUA stuff - now statically defined ***
if exist ..\xslt\ExtractDownloadLinks-wua-x86.xsl del ..\xslt\ExtractDownloadLinks-wua-x86.xsl
if exist ..\xslt\ExtractDownloadLinks-wua-x64.xsl del ..\xslt\ExtractDownloadLinks-wua-x64.xsl

rem *** MSSEDEFS stuff ***
if exist ..\static\StaticDownloadLink-mssedefs-x64.txt del ..\static\StaticDownloadLink-mssedefs-x64.txt
if exist ..\static\StaticDownloadLink-mssedefs-x86.txt del ..\static\StaticDownloadLink-mssedefs-x86.txt
if exist ..\client\mssedefs\x64\nul (
  if not exist ..\client\mssedefs\x64-glb\nul md ..\client\mssedefs\x64-glb
  move /Y ..\client\mssedefs\x64\*.* ..\client\mssedefs\x64-glb >nul
  rd /S /Q ..\client\mssedefs\x64
  if exist ..\client\md\hashes-mssedefs.txt del ..\client\md\hashes-mssedefs.txt
)
if exist ..\client\mssedefs\x86\nul (
  if not exist ..\client\mssedefs\x86-glb\nul md ..\client\mssedefs\x86-glb
  move /Y ..\client\mssedefs\x86\*.* ..\client\mssedefs\x86-glb >nul
  rd /S /Q ..\client\mssedefs\x86
  if exist ..\client\md\hashes-mssedefs.txt del ..\client\md\hashes-mssedefs.txt
)

rem *** Obsolete external stuff ***
if exist ..\bin\extract.exe del ..\bin\extract.exe
if exist ..\static\StaticDownloadLink-extract.txt del ..\static\StaticDownloadLink-extract.txt
if exist ..\static\StaticDownloadLink-sigcheck.txt del ..\static\StaticDownloadLink-sigcheck.txt
if exist ..\static\StaticDownloadLink-streams.txt del ..\static\StaticDownloadLink-streams.txt

rem *** Windows 2000 stuff ***
if exist ..\client\static\StaticUpdateIds-w2k-x86.txt del ..\client\static\StaticUpdateIds-w2k-x86.txt
if exist FixIE6SetupDir.cmd del FixIE6SetupDir.cmd
if exist ..\exclude\ExcludeList-w2k-x86.txt del ..\exclude\ExcludeList-w2k-x86.txt
if exist ..\exclude\ExcludeListISO-w2k-x86.txt del ..\exclude\ExcludeListISO-w2k-x86.txt
if exist ..\exclude\ExcludeListUSB-w2k-x86.txt del ..\exclude\ExcludeListUSB-w2k-x86.txt
if exist ..\sh\FIXIE6SetupDir.sh del ..\sh\FIXIE6SetupDir.sh
if exist ..\xslt\ExtractDownloadLinks-win-x86-glb.xsl del ..\xslt\ExtractDownloadLinks-win-x86-glb.xsl
del /Q ..\static\*ie6-*.* >nul 2>&1
del /Q ..\static\*w2k-*.* >nul 2>&1
del /Q ..\xslt\*w2k-*.* >nul 2>&1

rem *** Office and invcif.exe stuff ***
if exist ..\static\StaticDownloadLinks-inventory.txt del ..\static\StaticDownloadLinks-inventory.txt
if exist ..\client\wsus\invcif.exe (
  if exist ..\client\md\hashes-wsus.txt del ..\client\md\hashes-wsus.txt
  del ..\client\wsus\invcif.exe
)
if exist ..\client\wsus\invcm.exe (
  if exist ..\client\md\hashes-wsus.txt del ..\client\md\hashes-wsus.txt
  del ..\client\wsus\invcm.exe
)
if exist ..\client\static\StaticUpdateIds-o2k7-x64.txt del ..\client\static\StaticUpdateIds-o2k7-x64.txt
if exist ..\client\static\StaticUpdateIds-o2k7-x86.txt del ..\client\static\StaticUpdateIds-o2k7-x86.txt
if exist ..\ExtractDownloadLinks-oall.cmd del ..\ExtractDownloadLinks-oall.cmd
if exist ..\ExtractDownloadLinks-wall.cmd del ..\ExtractDownloadLinks-wall.cmd
if exist ..\static\StaticDownloadLinks-o2k7-x64-glb.txt del ..\static\StaticDownloadLinks-o2k7-x64-glb.txt
if exist ..\xslt\ExtractDownloadLinks-oall-deu.xsl del ..\xslt\ExtractDownloadLinks-oall-deu.xsl
if exist ..\xslt\ExtractDownloadLinks-oall-enu.xsl del ..\xslt\ExtractDownloadLinks-oall-enu.xsl
if exist ..\xslt\ExtractDownloadLinks-oall-fra.xsl del ..\xslt\ExtractDownloadLinks-oall-fra.xsl
if exist ..\xslt\ExtractDownloadLinks-wall.xsl del ..\xslt\ExtractDownloadLinks-wall.xsl
del /Q ..\xslt\ExtractDownloadLinks-o*.* >nul 2>&1
del /Q ..\xslt\ExtractExpiredIds-o*.* >nul 2>&1
del /Q ..\xslt\ExtractValidIds-o*.* >nul 2>&1
del /Q ..\exclude\ExcludeList*-o2k7-x64.txt >nul 2>&1
del /Q ..\exclude\ExcludeList*-o2k7-x86.txt >nul 2>&1

rem *** Execute custom initialization hook ***
if exist .\custom\InitializationHook.cmd (
  echo Executing custom initialization hook...
  call .\custom\InitializationHook.cmd
  echo %DATE% %TIME% - Info: Executed custom initialization hook >>%DOWNLOAD_LOGFILE%
)

rem *** Download Microsoft XSL processor frontend ***
if exist ..\bin\msxsl.exe goto SkipMSXSL
echo Downloading/validating Microsoft XSL processor frontend...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-msxsl.txt -P ..\bin
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated Microsoft XSL processor frontend >>%DOWNLOAD_LOGFILE%
:SkipMSXSL

rem *** Download mkisofs tool ***
if "%SKIP_MKISOFS%"=="1" goto SkipMkIsoFs
if exist ..\bin\mkisofs.exe goto SkipMkIsoFs
echo Downloading mkisofs tool...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-mkisofs.txt -P ..\bin
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded mkisofs tool >>%DOWNLOAD_LOGFILE%
pushd ..\bin
for /F %%i in ('dir /B cdrtools*.zip') do unzip.exe %%i mkisofs.exe
del /Q cdrtools*.zip
popd
:SkipMkIsoFs

rem *** Download Sysinternals' tools Autologon, Sigcheck and Streams ***
if not exist ..\client\bin\Autologon.exe goto DownloadSysinternals 
if not exist ..\bin\sigcheck.exe goto DownloadSysinternals 
if not exist ..\bin\streams.exe goto DownloadSysinternals 
goto SkipSysinternals
:DownloadSysinternals
echo Downloading Sysinternals' tools Autologon, Sigcheck and Streams...
%WGET_PATH% -N -i ..\static\StaticDownloadLinks-sysinternals.txt -P ..\bin
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded Sysinternals' tools Autologon, Sigcheck and Streams >>%DOWNLOAD_LOGFILE%
pushd ..\bin
unzip.exe -o Autologon.zip Autologon.exe
del Autologon.zip
move /Y Autologon.exe ..\client\bin 
unzip.exe -o Sigcheck.zip sigcheck.exe
del Sigcheck.zip
unzip.exe -o Streams.zip streams.exe
del Streams.zip
popd
:SkipSysinternals

rem *** Download most recent Windows Update Agent and catalog file ***
if "%VERIFY_DOWNLOADS%" NEQ "1" goto DownloadWSUS
if not exist ..\client\wsus\nul goto DownloadWSUS
if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
if exist ..\client\md\hashes-wsus.txt (
  echo Verifying integrity of Windows Update Agent and catalog file...
  pushd ..\client\md
  ..\bin\hashdeep.exe -a -l -vv -k hashes-wsus.txt -r ..\wsus
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of Windows Update Agent and catalog file >>%DOWNLOAD_LOGFILE%
) else (
  echo Warning: Integrity database ..\client\md\hashes-wsus.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-wsus.txt not found >>%DOWNLOAD_LOGFILE%
)
:DownloadWSUS
echo Downloading/validating most recent Windows Update Agent and catalog file...
%WGET_PATH% -N -i ..\static\StaticDownloadLinks-wsus.txt -P ..\client\wsus
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated most recent Windows Update Agent and catalog file >>%DOWNLOAD_LOGFILE%
if "%VERIFY_DOWNLOADS%"=="1" (
  if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
  echo Creating integrity database for Windows Update Agent and catalog file...
  if not exist ..\client\md\nul md ..\client\md
  pushd ..\client\md
  ..\bin\hashdeep.exe -c md5,sha256 -l -r ..\wsus >hashes-wsus.txt
  if errorlevel 1 (
    popd
    echo Warning: Error creating integrity database ..\client\md\hashes-wsus.txt.
    echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-wsus.txt >>%DOWNLOAD_LOGFILE%
  ) else (
    popd
    echo %DATE% %TIME% - Info: Created integrity database for Windows Update Agent and catalog file >>%DOWNLOAD_LOGFILE%
  )
) else (
  if exist ..\client\md\hashes-wsus.txt (
    del ..\client\md\hashes-wsus.txt 
    echo %DATE% %TIME% - Info: Deleted integrity database for Windows Update Agent and catalog file >>%DOWNLOAD_LOGFILE%
  )
)

rem *** Download installation files for .NET Framework 3.5 SP1 and 4 ***
if "%INCLUDE_DOTNET%" NEQ "1" goto SkipDotNet
set DOTNET35_FILENAME=..\dotnet\dotnetfx35.exe
set DOTNET4_FILENAME=..\dotnet\dotNetFx40_Full_x86_x64.exe
if "%VERIFY_DOWNLOADS%" NEQ "1" goto DownloadDotNet
if not exist ..\client\dotnet\nul goto DownloadDotNet
if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
if exist ..\client\md\hashes-dotnet.txt (
  echo Verifying integrity of .NET Framework installation files...
  pushd ..\client\md
  ..\bin\hashdeep.exe -a -l -vv -k hashes-dotnet.txt %DOTNET35_FILENAME% %DOTNET4_FILENAME%
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of .NET Framework installation files >>%DOWNLOAD_LOGFILE%
) else (
  echo Warning: Integrity database ..\client\md\hashes-dotnet.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-dotnet.txt not found >>%DOWNLOAD_LOGFILE%
)
:DownloadDotNet
echo Downloading/validating installation files for .NET Framework 3.5 SP1 and 4...
%WGET_PATH% -N -i ..\static\StaticDownloadLinks-dotnet.txt -P ..\client\dotnet
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated installation files for .NET Framework 3.5 SP1 and 4 >>%DOWNLOAD_LOGFILE%
if "%VERIFY_DOWNLOADS%"=="1" (
  if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
  echo Creating integrity database for .NET Framework installation files...
  if not exist ..\client\md\nul md ..\client\md
  pushd ..\client\md
  ..\bin\hashdeep.exe -c md5,sha256 -l %DOTNET35_FILENAME% %DOTNET4_FILENAME% >hashes-dotnet.txt
  if errorlevel 1 (
    popd
    echo Warning: Error creating integrity database ..\client\md\hashes-dotnet.txt.
    echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-dotnet.txt >>%DOWNLOAD_LOGFILE%
  ) else (
    popd
    echo %DATE% %TIME% - Info: Created integrity database for .NET Framework installation files >>%DOWNLOAD_LOGFILE%
  )
) else (
  if exist ..\client\md\hashes-dotnet.txt (
    del ..\client\md\hashes-dotnet.txt 
    echo %DATE% %TIME% - Info: Deleted integrity database for .NET Framework installation files >>%DOWNLOAD_LOGFILE%
  )
)
call :DownloadCore dotnet %TARGET_ARCH%-glb
if errorlevel 1 goto Error
:SkipDotNet

rem *** Download definition files for Microsoft Security Essentials - not required for w2k3 ***
if /i "%1"=="w2k3" goto SkipMSSE
if /i "%1"=="w2k3-x64" goto SkipMSSE
if "%INCLUDE_MSSE%" NEQ "1" goto SkipMSSE
if "%VERIFY_DOWNLOADS%" NEQ "1" goto DownloadMSSE
if not exist ..\client\mssedefs\nul goto DownloadMSSE
if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
if exist ..\client\md\hashes-mssedefs.txt (
  echo Verifying integrity of Microsoft Security Essentials definition files...
  pushd ..\client\md
  ..\bin\hashdeep.exe -a -l -vv -k hashes-mssedefs.txt -r ..\mssedefs
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of Microsoft Security Essentials definition files >>%DOWNLOAD_LOGFILE%
) else (
  echo Warning: Integrity database ..\client\md\hashes-mssedefs.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-mssedefs.txt not found >>%DOWNLOAD_LOGFILE%
)
:DownloadMSSE
echo Downloading/validating definition files for Microsoft Security Essentials...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-mssedefs-%TARGET_ARCH%-glb.txt -P ..\client\mssedefs\%TARGET_ARCH%-glb
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated definition files for Microsoft Security Essentials >>%DOWNLOAD_LOGFILE%
if "%VERIFY_DOWNLOADS%"=="1" (
  if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
  echo Creating integrity database for Microsoft Security Essentials definition files...
  if not exist ..\client\md\nul md ..\client\md
  pushd ..\client\md
  ..\bin\hashdeep.exe -c md5,sha256 -l -r ..\mssedefs >hashes-mssedefs.txt
  if errorlevel 1 (
    popd
    echo Warning: Error creating integrity database ..\client\md\hashes-mssedefs.txt.
    echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-mssedefs.txt >>%DOWNLOAD_LOGFILE%
  ) else (
    popd
    echo %DATE% %TIME% - Info: Created integrity database for Microsoft Security Essentials definition files >>%DOWNLOAD_LOGFILE%
  )
) else (
  if exist ..\client\md\hashes-mssedefs.txt (
    del ..\client\md\hashes-mssedefs.txt 
    echo %DATE% %TIME% - Info: Deleted integrity database for Microsoft Security Essentials definition files >>%DOWNLOAD_LOGFILE%
  )
)
:SkipMSSE

rem *** Download the platform specific patches ***
for %%i in (wxp w2k3) do (
  if /i "%1"=="%%i" (
    call :DownloadCore win glb
    if errorlevel 1 goto Error
    call :DownloadCore win %2
    if errorlevel 1 goto Error
  )
)
for %%i in (oxp o2k3 o2k7 o2k10) do (
  if /i "%1"=="%%i" (
    call :DownloadCore ofc glb
    if errorlevel 1 goto Error
    call :DownloadCore ofc %2
    if errorlevel 1 goto Error
  )
)
for %%i in (wxp w2k3 w2k3-x64 oxp o2k3 o2k7 o2k10) do (
  if /i "%1"=="%%i" (
    call :DownloadCore %1 glb
    if errorlevel 1 goto Error
    call :DownloadCore %1 %2
    if errorlevel 1 goto Error
  )
)
for %%i in (w60 w60-x64 w61 w61-x64) do (
  if /i "%1"=="%%i" (
    call :DownloadCore %1 %2
    if errorlevel 1 goto Error
  )
)
goto RemindDate

:DownloadCore
rem *** Determine update urls for %1 %2 ***
echo.
echo Determining update urls for %1 %2...
if exist "%TEMP%\StaticDownloadLinks-%1-%2.txt" del "%TEMP%\StaticDownloadLinks-%1-%2.txt"
if exist "%TEMP%\ValidStaticLinks-%1-%2.txt" del "%TEMP%\ValidStaticLinks-%1-%2.txt"
if exist "%TEMP%\ValidDownloadLinks-%1-%2.txt" del "%TEMP%\ValidDownloadLinks-%1-%2.txt"

if "%EXCLUDE_STATICS%"=="1" goto SkipStatics
if exist ..\static\StaticDownloadLinks-%1-%2.txt (
  copy /Y ..\static\StaticDownloadLinks-%1-%2.txt "%TEMP%\StaticDownloadLinks-%1-%2.txt" >nul
  if exist ..\static\custom\StaticDownloadLinks-%1-%2.txt (
    for /F %%i in (..\static\custom\StaticDownloadLinks-%1-%2.txt) do echo %%i>>"%TEMP%\StaticDownloadLinks-%1-%2.txt"
  )
  goto EvalStatics
)
if exist ..\static\StaticDownloadLinks-%1-%TARGET_ARCH%-%2.txt (
  copy /Y ..\static\StaticDownloadLinks-%1-%TARGET_ARCH%-%2.txt "%TEMP%\StaticDownloadLinks-%1-%2.txt" >nul
  if exist ..\static\custom\StaticDownloadLinks-%1-%TARGET_ARCH%-%2.txt (
    for /F %%i in (..\static\custom\StaticDownloadLinks-%1-%TARGET_ARCH%-%2.txt) do echo %%i>>"%TEMP%\StaticDownloadLinks-%1-%2.txt"
  )
  goto EvalStatics
)
goto SkipStatics

:EvalStatics
if "%EXCLUDE_SP%"=="1" (
  %SystemRoot%\system32\findstr.exe /I /V /G:..\exclude\ExcludeList-SPs.txt "%TEMP%\StaticDownloadLinks-%1-%2.txt" >>"%TEMP%\ValidStaticLinks-%1-%2.txt"
  del "%TEMP%\StaticDownloadLinks-%1-%2.txt"
) else (
  ren "%TEMP%\StaticDownloadLinks-%1-%2.txt" ValidStaticLinks-%1-%2.txt
)

:SkipStatics
if not exist ..\bin\msxsl.exe goto NoMSXSL
for %%i in (dotnet win wxp w2k3 w2k3-x64 w60 w60-x64 w61 w61-x64) do (if /i "%1"=="%%i" goto DetermineWindows)
for %%i in (ofc) do (if /i "%1"=="%%i" goto DetermineOffice)
goto DoDownload

:DetermineWindows
rem *** Extract Microsoft update catalog file package.xml ***
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
%SystemRoot%\system32\expand.exe ..\client\wsus\wsusscn2.cab -F:package.cab "%TEMP%" >nul
%SystemRoot%\system32\expand.exe "%TEMP%\package.cab" "%TEMP%\package.xml" >nul
del "%TEMP%\package.cab"

if exist ..\xslt\ExtractDownloadLinks-%1-%2.xsl (
  ..\bin\msxsl.exe "%TEMP%\package.xml" ..\xslt\ExtractDownloadLinks-%1-%2.xsl -o "%TEMP%\DownloadLinks-%1-%2.txt"
  if errorlevel 1 goto DownloadError
)
if exist ..\xslt\ExtractDownloadLinks-%1-%TARGET_ARCH%-%2.xsl (
  ..\bin\msxsl.exe "%TEMP%\package.xml" ..\xslt\ExtractDownloadLinks-%1-%TARGET_ARCH%-%2.xsl -o "%TEMP%\DownloadLinks-%1-%2.txt"
  if errorlevel 1 goto DownloadError
)
del "%TEMP%\package.xml"

if not exist "%TEMP%\DownloadLinks-%1-%2.txt" goto DoDownload

if exist "%TEMP%\ExcludeList-%1.txt" del "%TEMP%\ExcludeList-%1.txt"
if exist ..\exclude\ExcludeList-%1.txt (
  copy /Y ..\exclude\ExcludeList-%1.txt "%TEMP%\ExcludeList-%1.txt" >nul
  if exist ..\exclude\custom\ExcludeList-%1.txt (
    for /F %%i in (..\exclude\custom\ExcludeList-%1.txt) do echo %%i>>"%TEMP%\ExcludeList-%1.txt"
  )
  goto ExcludeWindows
)
if exist ..\exclude\ExcludeList-%1-%TARGET_ARCH%.txt (
  copy /Y ..\exclude\ExcludeList-%1-%TARGET_ARCH%.txt "%TEMP%\ExcludeList-%1.txt" >nul
  if exist ..\exclude\custom\ExcludeList-%1-%TARGET_ARCH%.txt (
    for /F %%i in (..\exclude\custom\ExcludeList-%1-%TARGET_ARCH%.txt) do echo %%i>>"%TEMP%\ExcludeList-%1.txt"
  )
)

:ExcludeWindows
%SystemRoot%\system32\findstr.exe /I /V /G:"%TEMP%\ExcludeList-%1.txt" "%TEMP%\DownloadLinks-%1-%2.txt" >>"%TEMP%\ValidDownloadLinks-%1-%2.txt"
if not exist "%TEMP%\ValidDownloadLinks-%1-%2.txt" ren "%TEMP%\DownloadLinks-%1-%2.txt" ValidDownloadLinks-%1-%2.txt
if exist "%TEMP%\ExcludeList-%1.txt" del "%TEMP%\ExcludeList-%1.txt"
if exist "%TEMP%\DownloadLinks-%1-%2.txt" del "%TEMP%\DownloadLinks-%1-%2.txt"
goto DoDownload

:DetermineOffice
rem *** Extract Microsoft update catalog file package.xml ***
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
%SystemRoot%\system32\expand.exe ..\client\wsus\wsusscn2.cab -F:package.cab "%TEMP%" >nul
%SystemRoot%\system32\expand.exe "%TEMP%\package.cab" "%TEMP%\package.xml" >nul
del "%TEMP%\package.cab"

..\bin\msxsl.exe "%TEMP%\package.xml" ..\xslt\ExtractUpdateCategoriesAndFileIds.xsl -o "%TEMP%\UpdateCategoriesAndFileIds.txt"
if errorlevel 1 goto DownloadError
..\bin\msxsl.exe "%TEMP%\package.xml" ..\xslt\ExtractUpdateCabExeIdsAndLocations.xsl -o "%TEMP%\UpdateCabExeIdsAndLocations.txt"
if errorlevel 1 goto DownloadError
del "%TEMP%\package.xml"

if exist "%TEMP%\OfficeUpdateAndFileIds.txt" del "%TEMP%\OfficeUpdateAndFileIds.txt"
if exist "%TEMP%\OfficeFileIds.txt" del "%TEMP%\OfficeFileIds.txt"
set UPDATE_ID=
set UPDATE_CATEGORY=
set UPDATE_LANGUAGES=
for /F "usebackq tokens=1,2 delims=;" %%i in ("%TEMP%\UpdateCategoriesAndFileIds.txt") do (
  if "%%j"=="" (
    if "!UPDATE_CATEGORY!"=="477b856e-65c4-4473-b621-a8b230bb70d9" (
      for /F "tokens=1-3 delims=," %%k in ("%%i") do (
        if "%%l" NEQ "" (
          if /i "%2"=="glb" (
            if "%%m"=="" (
              echo !UPDATE_ID!,%%l>>"%TEMP%\OfficeUpdateAndFileIds.txt"
              echo %%l>>"%TEMP%\OfficeFileIds.txt"
            )
          ) else (
            if "%%m"=="%LANG_SHORT%" (
              echo !UPDATE_ID!,%%l>>"%TEMP%\OfficeUpdateAndFileIds.txt"
              echo %%l>>"%TEMP%\OfficeFileIds.txt"
            )
          )
        ) 
      ) 
    ) 
  ) else (
    for /F "tokens=1 delims=," %%k in ("%%i") do (
      set UPDATE_ID=%%k
    )
    for /F "tokens=1* delims=," %%k in ("%%j") do (
      set UPDATE_CATEGORY=%%k
      set UPDATE_LANGUAGES=%%l
    )
  )
)
set UPDATE_ID=
set UPDATE_CATEGORY=
set UPDATE_LANGUAGES=
del "%TEMP%\UpdateCategoriesAndFileIds.txt"                         

%SystemRoot%\system32\findstr.exe /B /G:"%TEMP%\OfficeFileIds.txt" "%TEMP%\UpdateCabExeIdsAndLocations.txt" >"%TEMP%\OfficeUpdateCabExeIdsAndLocations.txt"
del "%TEMP%\OfficeFileIds.txt"
del "%TEMP%\UpdateCabExeIdsAndLocations.txt"

if exist "%TEMP%\DownloadLinks-%1-%2.txt" del "%TEMP%\DownloadLinks-%1-%2.txt"
if exist ..\client\ofc\UpdateTable-%1-%2.csv del ..\client\ofc\UpdateTable-%1-%2.csv
for /F "usebackq tokens=1,2 delims=," %%i in ("%TEMP%\OfficeUpdateCabExeIdsAndLocations.txt") do (
  for /F "usebackq tokens=1,2 delims=," %%k in ("%TEMP%\OfficeUpdateAndFileIds.txt") do (
    if /i "%%l"=="%%i" (
      echo %%j>>"%TEMP%\DownloadLinks-%1-%2.txt"
      echo %%k,%%~nj>>..\client\ofc\UpdateTable-%1-%2.csv
    )
  )
)
del "%TEMP%\OfficeUpdateAndFileIds.txt"
del "%TEMP%\OfficeUpdateCabExeIdsAndLocations.txt"

:ExcludeOffice
if exist "%TEMP%\ExcludeList-%1.txt" del "%TEMP%\ExcludeList-%1.txt"
if exist ..\exclude\ExcludeList-%1.txt (
  copy /Y ..\exclude\ExcludeList-%1.txt "%TEMP%\ExcludeList-%1.txt" >nul
  if exist ..\exclude\custom\ExcludeList-%1.txt (
    for /F %%i in (..\exclude\custom\ExcludeList-%1.txt) do echo %%i>>"%TEMP%\ExcludeList-%1.txt"
  )
)
for /F "usebackq" %%i in ("%TEMP%\ExcludeList-%1.txt") do echo %%i>>"%TEMP%\InvalidIds-%1.txt"
%SystemRoot%\system32\findstr.exe /I /V /G:"%TEMP%\InvalidIds-%1.txt" "%TEMP%\DownloadLinks-%1-%2.txt" >>"%TEMP%\ValidDownloadLinks-%1-%2.txt" 
if exist "%TEMP%\ExcludeList-%1.txt" del "%TEMP%\ExcludeList-%1.txt"
del "%TEMP%\InvalidIds-%1.txt"
del "%TEMP%\DownloadLinks-%1-%2.txt"

:DoDownload
rem *** Verify integrity of existing updates for %1 %2 ***
if "%VERIFY_DOWNLOADS%" NEQ "1" goto SkipVerification
if not exist ..\client\%1\%2\nul goto SkipVerification
if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
for %%i in (..\client\md\hashes-%1-%2.txt) do (if %%~zi==0 del %%i)
if exist ..\client\md\hashes-%1-%2.txt (
  echo Verifying integrity of existing updates for %1 %2...
  pushd ..\client\md
  ..\bin\hashdeep.exe -a -l -vv -k hashes-%1-%2.txt -r ..\%1\%2
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of existing updates for %1 %2 >>%DOWNLOAD_LOGFILE%
) else (
  echo Warning: Integrity database ..\client\md\hashes-%1-%2.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-%1-%2.txt not found >>%DOWNLOAD_LOGFILE%
)
:SkipVerification

rem *** Download updates for %1 %2 ***
if not exist "%TEMP%\ValidStaticLinks-%1-%2.txt" goto DownloadDynamicUpdates
echo Downloading/validating statically defined updates for %1 %2...
for /F "delims=: tokens=1*" %%i in ('%SystemRoot%\system32\findstr.exe /N $ "%TEMP%\ValidStaticLinks-%1-%2.txt"') do set LINES_COUNT=%%i
for /F "delims=: tokens=1*" %%i in ('%SystemRoot%\system32\findstr.exe /N $ "%TEMP%\ValidStaticLinks-%1-%2.txt"') do (
  echo Downloading/validating update %%i of %LINES_COUNT%...
  %WGET_PATH% -N -P ..\client\%1\%2 %%j
  if errorlevel 1 (
    echo Warning: Download of %%j failed.
    echo %DATE% %TIME% - Warning: Download of %%j failed >>%DOWNLOAD_LOGFILE%
  )
)
echo %DATE% %TIME% - Info: Downloaded/validated %LINES_COUNT% statically defined updates for %1 %2 >>%DOWNLOAD_LOGFILE%

:DownloadDynamicUpdates
if not exist "%TEMP%\ValidDownloadLinks-%1-%2.txt" goto CleanupDownload
echo Downloading/validating dynamically determined updates for %1 %2...
for /F "delims=: tokens=1*" %%i in ('%SystemRoot%\system32\findstr.exe /N $ "%TEMP%\ValidDownloadLinks-%1-%2.txt"') do set LINES_COUNT=%%i
if "%HTTP_WSUS%"=="" (
  for /F "delims=: tokens=1*" %%i in ('%SystemRoot%\system32\findstr.exe /N $ "%TEMP%\ValidDownloadLinks-%1-%2.txt"') do (
    echo Downloading/validating update %%i of %LINES_COUNT%...
    %WGET_PATH% -nv -N -P ..\client\%1\%2 -a %DOWNLOAD_LOGFILE% %%j
    if errorlevel 1 (
      echo Warning: Download of %%j failed.
      echo %DATE% %TIME% - Warning: Download of %%j failed >>%DOWNLOAD_LOGFILE%
    )
  )
) else (
  echo Creating WSUS download table for %1 %2...
  %CSCRIPT_PATH% //Nologo //B //E:vbs CreateDownloadTable.vbs "%TEMP%\ValidDownloadLinks-%1-%2.txt" %HTTP_WSUS%
  if errorlevel 1 goto DownloadError
  echo %DATE% %TIME% - Info: Created WSUS download table for %1 %2 >>%DOWNLOAD_LOGFILE%
  for /F "delims=: tokens=1*" %%i in ('%SystemRoot%\system32\findstr.exe /N $ "%TEMP%\ValidDownloadLinks-%1-%2.csv"') do (
    echo Downloading/validating update %%i of %LINES_COUNT%...
    for /F "delims=, tokens=1-3" %%k in ("%%j") do (
      if "%%m"=="" (
        %WGET_PATH% -nv -N -P ..\client\%1\%2 -a %DOWNLOAD_LOGFILE% %%l
        if errorlevel 1 (
          echo Warning: Download of %%j failed.
          echo %DATE% %TIME% - Warning: Download of %%j failed >>%DOWNLOAD_LOGFILE%
        )
      ) else (
        if exist ..\client\%1\%2\%%k ren ..\client\%1\%2\%%k _%%k
        %WGET_PATH% -nv --no-proxy -O ..\client\%1\%2\%%k -a %DOWNLOAD_LOGFILE% %%l
        if errorlevel 1 (
          if exist ..\client\%1\%2\%%k del ..\client\%1\%2\%%k
          if exist ..\client\%1\%2\_%%k ren ..\client\%1\%2\_%%k %%k
          %WGET_PATH% -nv -N -P ..\client\%1\%2 -a %DOWNLOAD_LOGFILE% %%m
          if errorlevel 1 (
            echo Warning: Download of %%m failed.
            echo %DATE% %TIME% - Warning: Download of %%m failed >>%DOWNLOAD_LOGFILE%
          )
        ) else (
          if exist ..\client\%1\%2\_%%k del ..\client\%1\%2\_%%k
        )
      )
    )
  )
)
echo %DATE% %TIME% - Info: Downloaded/validated %LINES_COUNT% dynamically determined updates for %1 %2 >>%DOWNLOAD_LOGFILE%

:CleanupDownload
rem *** Clean up client directory for %1 %2 ***
if "%CLEANUP_DOWNLOADS%"=="0" goto VerifyDownload
echo Cleaning up client directory for %1 %2...
for /F %%i in ('dir /A:-D /B ..\client\%1\%2\*.*') do (
  %SystemRoot%\system32\find.exe /I "%%i" "%TEMP%\ValidDownloadLinks-%1-%2.txt" >nul 2>&1
  if errorlevel 1 (
    %SystemRoot%\system32\find.exe /I "%%i" "%TEMP%\ValidStaticLinks-%1-%2.txt" >nul 2>&1
    if errorlevel 1 (
      del ..\client\%1\%2\%%i
      echo %DATE% %TIME% - Info: Deleted ..\client\%1\%2\%%i >>%DOWNLOAD_LOGFILE%
    )
  )
)
echo %DATE% %TIME% - Info: Cleaned up client directory for %1 %2 >>%DOWNLOAD_LOGFILE%

:VerifyDownload
if not exist ..\client\%1\%2\nul goto EndDownload
dir ..\client\%1\%2 /A:-D >nul 2>&1
if errorlevel 1 goto EndDownload
rem *** Delete alternate data streams for %1 %2 ***
if exist ..\bin\streams.exe (
  echo Deleting alternate data streams for %1 %2...
  ..\bin\streams.exe /accepteula -s -d ..\client\%1\%2\*.* >nul 2>&1
  if errorlevel 1 (
    echo Warning: Unable to delete alternate data streams for %1 %2.
    echo %DATE% %TIME% - Warning: Unable to delete alternate data streams for %1 %2 >>%DOWNLOAD_LOGFILE%
  ) else (
    echo %DATE% %TIME% - Info: Deleted alternate data streams for %1 %2 >>%DOWNLOAD_LOGFILE%
  )
) else (
  echo Warning: Sysinternals' NTFS alternate data stream handling tool ..\bin\streams.exe not found.
  echo %DATE% %TIME% - Warning: Sysinternals' NTFS alternate data stream handling tool ..\bin\streams.exe not found >>%DOWNLOAD_LOGFILE%
)
if "%VERIFY_DOWNLOADS%"=="1" (
  rem *** Verifying digital file signatures for %1 %2 ***
  if not exist ..\bin\sigcheck.exe goto NoSigCheck
  echo Verifying digital file signatures for %1 %2...
  ..\bin\sigcheck.exe /accepteula -q -s -u -v ..\client\%1\%2 >"%TEMP%\sigcheck-%1-%2.txt"
  for /F "usebackq eol=N skip=1 tokens=1 delims=," %%i in ("%TEMP%\sigcheck-%1-%2.txt") do (
    echo Warning: File %%i is unsigned.
    echo %DATE% %TIME% - Warning: File %%i is unsigned >>%DOWNLOAD_LOGFILE%
  ) 
  if exist "%TEMP%\sigcheck-%1-%2.txt" del "%TEMP%\sigcheck-%1-%2.txt"
  echo %DATE% %TIME% - Info: Verified digital file signatures for %1 %2 >>%DOWNLOAD_LOGFILE%
  rem *** Create integrity database for %1 %2 ***
  if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
  echo Creating integrity database for %1 %2...
  if not exist ..\client\md\nul md ..\client\md
  pushd ..\client\md
  ..\bin\hashdeep.exe -c md5,sha256 -l -r ..\%1\%2 >hashes-%1-%2.txt
  if errorlevel 1 (
    popd
    echo Warning: Error creating integrity database ..\client\md\hashes-%1-%2.txt.
    echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-%1-%2.txt >>%DOWNLOAD_LOGFILE%
  ) else (
    popd
    for %%i in (..\client\md\hashes-%1-%2.txt) do (
      if %%~zi==0 (
        del %%i
        echo %DATE% %TIME% - Info: Deleted zero size integrity database for %1 %2 >>%DOWNLOAD_LOGFILE%
      ) else (
        echo %DATE% %TIME% - Info: Created integrity database for %1 %2 >>%DOWNLOAD_LOGFILE%
      )
    )
  )
) else (
  if exist ..\client\md\hashes-%1-%2.txt (
    del ..\client\md\hashes-%1-%2.txt 
    echo %DATE% %TIME% - Info: Deleted integrity database for %1 %2 >>%DOWNLOAD_LOGFILE%
  )
)

:EndDownload
if exist "%TEMP%\ValidStaticLinks-%1-%2.txt" del "%TEMP%\ValidStaticLinks-%1-%2.txt"
if exist "%TEMP%\ValidDownloadLinks-%1-%2.txt" del "%TEMP%\ValidDownloadLinks-%1-%2.txt"
if exist "%TEMP%\ValidDownloadLinks-%1-%2.csv" del "%TEMP%\ValidDownloadLinks-%1-%2.csv"
goto :eof

:RemindDate
rem *** Remind build date ***
echo Reminding build date...
date /T >..\client\builddate.txt
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions / delayed variable expansion available.
echo.
exit /b 1

:InvalidParams
echo.
echo ERROR: Invalid parameter: %1 %2 %3 %4
echo Usage1: %~n0 {wxp ^| w2k3 ^| w2k3-x64 ^| oxp ^| o2k3 ^| o2k7 ^| o2k10} {enu ^| fra ^| esn ^| jpn ^| kor ^| rus ^| ptg ^| ptb ^| deu ^| nld ^| ita ^| chs ^| cht ^| plk ^| hun ^| csy ^| sve ^| trk ^| ell ^| ara ^| heb ^| dan ^| nor ^| fin} [/excludesp ^| /excludestatics] [/includedotnet] [/nocleanup] [/verify] [/proxy http://[username:password@]^<server^>:^<port^>] [/wsus http://^<server^>]
echo Usage2: %~n0 {w60 ^| w60-x64 ^| w61 ^| w61-x64} {glb} [/excludesp ^| /excludestatics] [/includedotnet] [/nocleanup] [/verify] [/proxy http://[username:password@]^<server^>:^<port^>] [/wsus http://^<server^>]
echo %DATE% %TIME% - Error: Invalid parameter: %1 %2 %3 %4 >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoTemp
echo.
echo ERROR: Environment variable TEMP not set.
echo %DATE% %TIME% - Error: Environment variable TEMP not set >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoTempDir
echo.
echo ERROR: Directory "%TEMP%" not found.
echo %DATE% %TIME% - Error: Directory "%TEMP%" not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoCScript
echo.
echo ERROR: VBScript interpreter %CSCRIPT_PATH% not found.
echo %DATE% %TIME% - Error: VBScript interpreter %CSCRIPT_PATH% not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoWGet
echo.
echo ERROR: Download utility %WGET_PATH% not found.
echo %DATE% %TIME% - Error: Download utility %WGET_PATH% not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoUnZip
echo.
echo ERROR: Utility ..\bin\unzip.exe not found.
echo %DATE% %TIME% - Error: Utility ..\bin\unzip.exe not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoMSXSL
echo.
echo ERROR: Microsoft XSL processor frontend ..\bin\msxsl.exe not found.
echo %DATE% %TIME% - Error: Microsoft XSL processor frontend ..\bin\msxsl.exe not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoHashDeep
echo.
echo ERROR: Hash computing/auditing utility ..\client\bin\hashdeep.exe not found.
echo %DATE% %TIME% - Error: Hash computing/auditing utility ..\client\bin\hashdeep.exe not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoSigCheck
echo.
echo ERROR: Sysinternals' digital file signature verification tool ..\bin\sigcheck.exe not found.
echo %DATE% %TIME% - Error: Sysinternals' digital file signature verification tool ..\bin\sigcheck.exe not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:DownloadError
echo.
echo ERROR: Download failure for %1 %2.
echo %DATE% %TIME% - Error: Download failure for %1 %2 >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:IntegrityError
echo.
echo ERROR: File integrity verification failure.
echo %DATE% %TIME% - Error: File integrity verification failure >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:Error
if "%EXIT_ON_ERROR%"=="1" (
  endlocal
  pause
  verify other 2>nul
  exit
) else (
  title %ComSpec%
  endlocal
  verify other 2>nul
  goto :eof
)

:EoF
rem *** Execute custom finalization hook ***
if exist .\custom\FinalizationHook.cmd (
  echo Executing custom finalization hook...
  call .\custom\FinalizationHook.cmd
  echo %DATE% %TIME% - Info: Executed custom finalization hook >>%DOWNLOAD_LOGFILE%
)
echo Done.
echo %DATE% %TIME% - Info: Ending download for %1 %2 >>%DOWNLOAD_LOGFILE%
title %ComSpec%
endlocal
