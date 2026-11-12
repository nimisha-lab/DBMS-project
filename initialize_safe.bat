
@echo off
setlocal

REM Run manually from the DBMS-project folder.
REM Do not use this script during application startup.

cd /d "%~dp0"

set "DB_NAME=club_management_database"
set "DB_USER=postgres"

echo Target database: %DB_NAME%
echo This will NOT reset tables or seed data.

choice /M "Continue with manual initialization"
if errorlevel 2 exit /b 1

psql -X -v ON_ERROR_STOP=1 -U "%DB_USER%" -d "%DB_NAME%" -f "sql\03_functions.sql"
if errorlevel 1 goto fail

psql -X -v ON_ERROR_STOP=1 -U "%DB_USER%" -d "%DB_NAME%" -f "sql\04_views.sql"
if errorlevel 1 goto fail

python "scripts\create_accounts_safe.py"
if errorlevel 1 goto fail

echo Initialization completed successfully.
exit /b 0

:fail
echo Initialization failed.
exit /b 1
