@echo off

REM ***
REM *** Filename:	Vanilla_MECM_Updates.BAT
REM *** Date:		2024-03-11
REM *** Version:	1.00
REM *** Author:		Derek Wirch
REM ***
REM *** Purpose:
REM ***
REM *** Utilizing exported configuration from Microsoft Endpoint Configuration Manager (MECM),
REM *** retrieve updated program bits from Microsoft, then package the resultant bits in to 
REM *** a ZIP file for use to update an offline installation of MECM to the current version.
REM *** 
REM *** Output:
REM *** 
REM *** Creates a ZIP file with a date-encoded filename in PackageDir. 
REM *** Example: 2024-03-08-MECMPkg.zip
REM *** 
REM *** Requirements:
REM *** 
REM *** Internet Connection
REM *** 7Zip archiver
REM *** 

Set OpsRoot=C:\Temp

Set ServiceTool=%OpsRoot%\ServiceConnectionTool
Set ExportDir=%OpsRoot%\Export
Set ImportDir=%OpsRoot%\Import
Set PackageDir=%OpsRoot%\Package

REM ***
REM *** Echo date to null. If the date command is not available, exit the script
REM ***

echo. | date | FIND "(mm" > NUL
If errorlevel 1,(call :Parsedate DD MM) Else,(call :Parsedate MM DD)
goto :ScriptDone

:Parsedate 

REM ***
REM *** The date is available. Parse the output of DATE /T
REM ***

For /F "tokens=1-4 delims=/.- " %%A in ('date /T') do if %%D!==! (set %1=%%A&set %2=%%B&set YYYY=%%C) else (set DOW=%%A&set %1=%%B&set %2=%%C&set YYYY=%%D)
(Set DateStamp=%YYYY%%MM%%DD%)

:Get the data based on the cab file we received from the offline site

%ServiceTool%\ServiceConnectionTool.exe -connect -downloadsiteversion -usagedatasrc %ExportDir% -updatepackdest %ImportDir%

:Package up Received Data

7z a -tzip %PackageDir%\%DateStamp%-MECMPkg.zip %ExportDir%\*.* -r

:ScriptDone
