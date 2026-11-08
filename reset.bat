@echo off
setlocal
REM Run from repository root. This rebuilds tables and deletes existing project data.
if "%DB_NAME%"=="" set DB_NAME=club_management_db
if "%DB_USER%"=="" set DB_USER=postgres
echo [1/6] Rebuilding base schema...
psql -v ON_ERROR_STOP=1 -U %DB_USER% -d %DB_NAME% -f "dbms project\schema.sql"
if errorlevel 1 goto fail
echo [2/6] Adding user_account...
psql -v ON_ERROR_STOP=1 -U %DB_USER% -d %DB_NAME% -f "sql\01_user_account.sql"
if errorlevel 1 goto fail
echo [3/6] Installing triggers...
psql -v ON_ERROR_STOP=1 -U %DB_USER% -d %DB_NAME% -f "sql\02_triggers_fixed.sql"
if errorlevel 1 goto fail
echo [4/6] Installing function and views...
psql -v ON_ERROR_STOP=1 -U %DB_USER% -d %DB_NAME% -f "sql\03_functions.sql"
if errorlevel 1 goto fail
psql -v ON_ERROR_STOP=1 -U %DB_USER% -d %DB_NAME% -f "sql\04_views.sql"
if errorlevel 1 goto fail
echo [5/6] Loading sample data...
psql -v ON_ERROR_STOP=1 -U %DB_USER% -d %DB_NAME% -f "dbms project\seed.sql"
if errorlevel 1 goto fail
echo [6/6] Creating demo accounts...
py scripts\create_accounts.py
if errorlevel 1 goto fail
echo Reset completed. Now run sql\05_validation_tests.sql
exit /b 0
:fail
echo RESET FAILED. Fix the first error shown above.
exit /b 1
