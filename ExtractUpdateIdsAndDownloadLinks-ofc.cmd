@echo off

setlocal enabledelayedexpansion
rem *** Author: T. Wittrock, Kiel ***

if not exist "%TEMP%\wsusscn2.cab" (
  .\bin\wget.exe -N -i .\static\StaticDownloadLinks-wsus.txt -P "%TEMP%"
  if exist "%TEMP%\wuredist.cab" del "%TEMP%\wuredist.cab"
  if exist "%TEMP%\WindowsUpdateAgent30-x64.exe" del "%TEMP%\WindowsUpdateAgent30-x64.exe"
  if exist "%TEMP%\WindowsUpdateAgent30-x86.exe" del "%TEMP%\WindowsUpdateAgent30-x86.exe"
)
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
%SystemRoot%\System32\expand.exe "%TEMP%\wsusscn2.cab" -F:package.cab "%TEMP%"
%SystemRoot%\System32\expand.exe "%TEMP%\package.cab" "%TEMP%\package.xml"
del "%TEMP%\package.cab"

%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\ExtractUpdateCategoriesAndFileIds.xsl "%TEMP%\UpdateCategoriesAndFileIds.txt"
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\ExtractUpdateCabExeIdsAndLocations.xsl "%TEMP%\UpdateCabExeIdsAndLocations.txt"
goto DoIt

:Determine
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
            if "!UPDATE_LANGUAGES!_%%m"=="_" (
              echo !UPDATE_ID!,%%l>>"%TEMP%\OfficeUpdateAndFileIds.txt"
              echo %%l>>"%TEMP%\OfficeFileIds.txt"
            )
            if "!UPDATE_LANGUAGES!_%%m"=="en_en" (
              echo !UPDATE_ID!,%%l>>"%TEMP%\OfficeUpdateAndFileIds.txt"
              echo %%l>>"%TEMP%\OfficeFileIds.txt"
            )
          ) else (
            if "%%m"=="%3" (
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
rem del "%TEMP%\UpdateCategoriesAndFileIds.txt"

%SystemRoot%\System32\sort.exe "%TEMP%\OfficeFileIds.txt" /O "%TEMP%\OfficeFileIdsSortedForward.txt"
%SystemRoot%\System32\sort.exe /R "%TEMP%\OfficeFileIds.txt" /O "%TEMP%\OfficeFileIdsSortedReverse.txt"
rem del "%TEMP%\OfficeFileIds.txt"
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\ExtractUniqueFromSorted.vbs "%TEMP%\OfficeFileIdsSortedForward.txt" "%TEMP%\OfficeFileIdsUniqueForward.txt"
rem del "%TEMP%\OfficeFileIdsSortedForward.txt"
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\ExtractUniqueFromSorted.vbs "%TEMP%\OfficeFileIdsSortedReverse.txt" "%TEMP%\OfficeFileIdsUniqueReverse.txt"
rem del "%TEMP%\OfficeFileIdsSortedReverse.txt"
%SystemRoot%\System32\findstr.exe /B /L /G:"%TEMP%\OfficeFileIdsUniqueForward.txt" "%TEMP%\UpdateCabExeIdsAndLocations.txt" >"%TEMP%\OfficeUpdateCabExeIdsAndLocationsDouble.txt"
rem del "%TEMP%\OfficeFileIdsUniqueForward.txt"
%SystemRoot%\System32\findstr.exe /B /L /G:"%TEMP%\OfficeFileIdsUniqueReverse.txt" "%TEMP%\UpdateCabExeIdsAndLocations.txt" >>"%TEMP%\OfficeUpdateCabExeIdsAndLocationsDouble.txt"
rem del "%TEMP%\OfficeFileIdsUniqueReverse.txt"
rem del "%TEMP%\UpdateCabExeIdsAndLocations.txt"
%SystemRoot%\System32\sort.exe "%TEMP%\OfficeUpdateCabExeIdsAndLocationsDouble.txt" /O "%TEMP%\OfficeUpdateCabExeIdsAndLocationsSorted.txt"
rem del "%TEMP%\OfficeUpdateCabExeIdsAndLocationsDouble.txt"
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\ExtractUniqueFromSorted.vbs "%TEMP%\OfficeUpdateCabExeIdsAndLocationsSorted.txt" "%TEMP%\OfficeUpdateCabExeIdsAndLocations.txt"
rem del "%TEMP%\OfficeUpdateCabExeIdsAndLocationsSorted.txt"

if exist "%TEMP%\DynamicDownloadLinks-%1-%2.txt" del "%TEMP%\DynamicDownloadLinks-%1-%2.txt"
if exist "%TEMP%\UpdateTableURL-%1-%2.csv" del "%TEMP%\UpdateTableURL-%1-%2.csv"
for /F "usebackq tokens=1,2 delims=," %%i in ("%TEMP%\OfficeUpdateCabExeIdsAndLocations.txt") do (
  for /F "usebackq tokens=1,2 delims=," %%k in ("%TEMP%\OfficeUpdateAndFileIds.txt") do (
    if /i "%%l"=="%%i" (
      echo %%j>>"%TEMP%\DynamicDownloadLinks-%1-%2.txt"
      echo %%k,%%j>>"%TEMP%\UpdateTableURL-%1-%2.csv"
    )
  )
)
rem del "%TEMP%\OfficeUpdateAndFileIds.txt"
rem del "%TEMP%\OfficeUpdateCabExeIdsAndLocations.txt"
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\ExtractIdsAndFileNames.vbs "%TEMP%\UpdateTableURL-%1-%2.csv" "%TEMP%\UpdateTable-%1-%2.csv"
rem del "%TEMP%\UpdateTableURL-%1-%2.csv"
goto :EoF

:DoIt
call :Determine ofc enu en
call :Determine ofc deu de
call :Determine ofc glb
goto EoF

del "%TEMP%\package.xml"
del "%TEMP%\wsusscn2.cab"

:EoF
endlocal
