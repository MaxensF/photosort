::@echo off
setlocal enabledelayedexpansion 
set month[0]=01_Janvier
set month[1]=02_Fevrier
set month[2]=03_Mars
set month[3]=04_Avril
set month[4]=05_Mai
set month[5]=06_Juin
set month[6]=07_Juillet
set month[7]=08_Aout
set month[8]=09_Septembre
set month[9]=10_Octobre
set month[10]=11_Novembre
set month[11]=12_Decembre

if exist temp.csv ( del "temp.csv")

REM Read properties file
For /F "tokens=1* delims==" %%A IN (photosort.properties) DO (
    IF "%%A"=="SOURCE_FOLDER" set source_folder=%%B
    IF "%%A"=="TARGET_FOLDER" set target_folder=%%B
	IF "%%A"=="RECURSIVE" set use_recursive=%%B
	IF "%%A"=="DELETE_EMPTY_FOLDERS" set delete_empty_folders=%%B)

REM get actual date
	 for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
	 set dow =%%i
     set actual_year=%%k
     set actual_day=%%l
     set actual_month=%%j
)

REM create csv with files metadatas
::IF !use_recursive!==TRUE ( exiftool.exe -filename -createdate -directory -r -T -n !source_folder!> temp.csv ) 
::IF !use_recursive!==FALSE ( exiftool.exe -filename -createdate -directory -T -n !source_folder!> temp.csv )
IF !use_recursive!==TRUE (
	forfiles /P !source_folder! /S /M *.jpg /C "cmd /c echo @file,@fdate,@path ">temp.csv
	forfiles /P !source_folder! /S /M *.png /C "cmd /c echo @file,@fdate,@path ">>temp.csv
	forfiles /P !source_folder! /S /M *.jpeg /C "cmd /c echo @file,@fdate,@path ">>temp.csv
	forfiles /P !source_folder! /S /M *.tif /C "cmd /c echo @file,@fdate,@path ">>temp.csv	)
IF !use_recursive!==FALSE (
	forfiles /P !source_folder! /M *.jpg /C "cmd /c echo @file,@fdate,@path ">temp.csv
	forfiles /P !source_folder! /M *.png /C "cmd /c echo @file,@fdate,@path ">>temp.csv
	forfiles /P !source_folder! /M *.jpeg /C "cmd /c echo @file,@fdate,@path ">>temp.csv
	forfiles /P !source_folder! /M *.tif /C "cmd /c echo @file,@fdate,@path ">>temp.csv	)

REM get the year of the oldest picture
REM parse the csv file
set oldest_year=!actual_year!
for /f "usebackq tokens=1-2 delims=," %%a in ("temp.csv") do (
	set creation_date=%%b
	set creation_year=!creation_date:~6,4!
	if !oldest_year! gtr !creation_year! ( set oldest_year=!creation_year! )
	)
	echo %oldest_year%

REM  create directories for each year if it not exist
FOR /L %%i IN (!oldest_year! 1 !actual_year! ) DO (
    if not exist !target_folder!\\%%i ( mkdir !target_folder!\\%%i )
	
	REM  create directories for each month if it not exist
	FOR /L %%j IN (0 1 11) DO (
		if not exist !target_folder!\\%%i\\!month[%%j]! ( mkdir !target_folder!\\%%i\\!month[%%j]! )))

REM parse the csv file
for /f "usebackq tokens=1-3 delims=," %%a in ("temp.csv") do (
	set creation_date=%%b
	set file_name=%%a
	set creation_year=!creation_date:~6,4!
	set creation_month=!creation_date:~3,2!
	set creation_day=!creation_date:~0,2!
	set file_path=%%c
	
REM move the file in the write year/month
	if !creation_month!==01 ( move !file_path! !target_folder!\\!creation_year!\%month[0]% )
	if !creation_month!==02 ( move !file_path! !target_folder!\\!creation_year!\%month[1]% )
	if !creation_month!==03 ( move !file_path! !target_folder!\\!creation_year!\%month[2]% )
	if !creation_month!==04 ( move !file_path! !target_folder!\\!creation_year!\%month[3]% )
	if !creation_month!==05 ( move !file_path! !target_folder!\\!creation_year!\%month[4]% )
	if !creation_month!==06 ( move !file_path! !target_folder!\\!creation_year!\%month[5]% )
	if !creation_month!==07 ( move !file_path! !target_folder!\\!creation_year!\%month[6]% )
	if !creation_month!==08 ( move !file_path! !target_folder!\\!creation_year!\%month[7]% )
	if !creation_month!==09 ( move !file_path! !target_folder!\\!creation_year!\%month[8]% )
	if !creation_month!==10 ( move !file_path! !target_folder!\\!creation_year!\%month[9]% )
	if !creation_month!==11 ( move !file_path! !target_folder!\\!creation_year!\%month[10]% )
	if !creation_month!==12 ( move !file_path! !target_folder!\\!creation_year!\%month[11]% ))
      
del "temp.csv"

REM delete recursively empty directories
if !delete_empty_folders!==TRUE ( 
	REM delete empty folders of target directory
	for /f "delims=" %%d in ('dir !target_folder! /s /b /ad ^| sort /r') do (
		if exist %%d ( rd "%%d" ))
	REM delete empty folders of source directory
	for /f "delims=" %%d in ('dir !source_folder! /s /b /ad ^| sort /r') do (
		if exist %%d ( rd "%%d" )))
			
endlocal