@ECHO OFF
setlocal enabledelayedexpansion
SET MyPath=%CD%


REM Defining variables for %1 and %2 to be passed into from the CLI
SET Targ=NullTarg
SET Dest=NullDest
GOTO CLICHECK

REM This count increses if there is missing/null CLI params, menu launches if this is above zero
REM Nested if checks the params are valid if the params are detected.
REM If there is the correct amount of variables, it will then check if they exist, if the destination
REM doesnt exist then it will create it automatically from CLI
:CLICHECK
SET Count=0
IF [%1]==[] ( 
	ECHO Param 1 Not Present
	SET /a Count+=1
)
IF [%2]==[] ( 
	ECHO Param 2 Not Present
	SET /a Count+=1
) 
ECHO %Count%
IF %Count%==0 (
	SET Targ=%1
	SET Dest=%2
	ECHO !Targ!
	ECHO !Dest!
	IF EXIST !Targ! (
		IF NOT EXIST !DEST! (
			MD !DEST!
		)
		IF EXIST !DEST! (
			CALL :AdHoc
			GOTO :EOF
		)
	)
	PAUSE
)

REM menu functionality, resets the defualt targ and dest so that when later functions break, they can return here
REM without risk of old variables affecting usage
:MENU
SET Targ=NullTarg
SET Dest=NullDest
CLS
ECHO SID - 1543319
ECHO ==============================
ECHO Automated Backup Program V3
ECHO ------------------------------
ECHO Please Enter Your Choice:
ECHO AdHoc            (1)
ECHO NewBackupFile    (2)
ECHO MultipleBackups  (3)
ECHO Help             (4)
ECHO Exit             (5)
ECHO ==============================
SET M=""
SET /p M=Your Choice:
ECHO You Selected %M%
IF /i %M%==1 (
	CALL :GetTarg
	CALL :GetDest
	CALL :AdHoc
)
IF /i %M%==2 (
	CALL :GetTarg
	CALL :GetDest
	CALL :NewBackup
)
IF /i %M%==3 (
	CALL :GetDest
	CALL :MultiBack
)
IF /i %M%==4 (
	CALL :Help
)
IF /i %M%==5 (
	CLS
	GOTO :EOF
)
PAUSE
GOTO MENU

:GetTarg
SET /p Targ=Please Enter TARGET directory: 
ECHO !Targ!
IF NOT EXIST !TARG! GOTO GetTarg
Exit /b

:GetDest
SET /p Dest=Please Enter DESTINATION directory:
ECHO !Dest!
IF NOT EXIST !DEST! ( 
	SET /p GD=Destination Not Found, Create? [Y/N]
	IF !GD!==Y (	
		ECHO Creating Destination Folder
		MD !Dest!
		
	)
	IF !GD!==N (
		GOTO MENU
	)
)
Exit /b

:AdHoc
SET dt=%date:~0,2%%date:~3,2%%date:~6,4%%time:~0,2%%time:~3,2%%time:~6,2%
SET dt=%dt: =0%
CD !DEST!
FOR /F "delims=|" %%B IN ("!Targ!") DO SET TargEnd=%%~nB
MD !TargEnd!!dt!
XCOPY !Targ! !Dest!\!TargEnd!!dt! /e /k /i
CD %MyPath%
Exit /b

:NewBackup
Set /p FileName=Please enter a name for your backup script (No File Extentions)
ECHO @ECHO OFF>> %FileName%.bat
ECHO setlocal enabledelayedexpansion>> %FileName%.bat
ECHO SET dt=%%date:~0,2%%%%date:~3,2%%%%date:~6,4%%%%time:~0,2%%%%time:~3,2%%%%time:~6,2%%>> %FileName%.bat
ECHO SET dt=%%dt: =0%%>> %FileName%.bat
ECHO CD !DEST!>> %FileName%.bat
ECHO FOR /F "delims=|" ^%%^%%B IN ("!Targ!") DO SET TargEnd=^%%^%%~nB>> %FileName%.bat
ECHO MD %%TargEnd%%%%dt%%>> %FileName%.bat
ECHO XCOPY !Targ! !Dest!\!TargEnd!%%dt%% /e /k /i>> %FileName%.bat
Exit /b

:MultiBack
ECHO Multiback Called
Exit /b
