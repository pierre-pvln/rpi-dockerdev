:: Name:     rpi2_pscp_get.cmd
:: Purpose:  copy files from rpi2
:: Author:   pierre@pvln.nl
:: Revision: 2017 08 15 - initial version
::           2017 09 08 - folderstructure changed

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: BASIC SETTINGS
:: ==============
:: Setting the name of the script
SET ME=%~n0
:: Setting the name of the directory
SET PARENT=%~p0
:: Setting for Error messages
SET ERROR_MESSAGE=errorfree

:: GET SETTINGS
:: ============
CD .\settings
IF EXIST server.cmd (
   CALL server.cmd
) ELSE (
   SET ERROR_MESSAGE=File with server settings doesn't exist
)

IF EXIST exec.cmd (
   CALL exec.cmd
) ELSE (
   SET ERROR_MESSAGE=File with executable settings doesn't exist
)

IF EXIST folders.cmd (
   CALL folders.cmd
) ELSE (
   SET ERROR_MESSAGE=File with folder settings doesn't exist
)

CD %PARENT%

:: GET SECRETS
:: ===========
CD ..\..\secrets\hst
IF EXIST user.cmd (
   CALL user.cmd
) ELSE (
   SET ERROR_MESSAGE=File with user settings doesn't exist
)

CD %PARENT%


IF %ERROR_MESSAGE% NEQ errorfree GOTO ERROR_EXIT

:: Check if server is available based on server-hostname
::
:: A successful PING does NOT always return an %errorlevel% of 0
:: Therefore to reliably detect a successful ping - pipe the output into FIND and look for the text "TTL" 
:: https://ss64.com/nt/ping.html
:: Also use ping over IP v4; default ping not always returns a TTL in the response.

PING -4 -n 1 %SERVER-HOSTNAME% |find "TTL=" && GOTO DO_SOMETHING
SET ERROR_MESSAGE=%SERVER-HOSTNAME% not available
SET SERVER-HOSTNAME=localhost

:DO_SOMETHING
ECHO *******************
ECHO Connected: %SERVER-HOSTNAME%
ECHO *******************
:: THE ACTUAL THING TO DO
:: ======================
:: Transfer files
:: -scp     use SCP protocol
:: -r       copy directories recursively
:: -pw      use password
:: -P 2222  use port 2222 (since it is NAT)
::
:: For test puposes
:: -v     show verbose messages

IF %SERVER-HOSTNAME% NEQ localhost (
   SET connectport=22
) ELSE (
   SET connectport=2222
)   

echo %_PSCP% -scp -P %CONNECTPORT% -r -pw %HST_PW% %HST_ID%@%SERVER-HOSTNAME%:/tmp/archive/ %ARCHIVE_DIR%/

:: Transfer archive files to server
%_PSCP% -scp -P %CONNECTPORT% -r -pw %HST_PW% %HST_ID%@%SERVER-HOSTNAME%:/tmp/archive/ %ARCHIVE_DIR%/ 

ECHO.
ECHO *******************
ECHO:
ECHO Ga naar directory %ARCHIVE_DIR%
ECHO:
ECHO *******************
GOTO CLEAN_EXIT

:ERROR_EXIT
ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT
timeout /T 3
