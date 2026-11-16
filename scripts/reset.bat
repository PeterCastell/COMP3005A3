@echo off
setlocal

set "PSQL=psql"
where psql >nul 2>nul || for /d %%d in ("%ProgramFiles%\PostgreSQL\*") do if exist "%%d\bin\psql.exe" set "PSQL=%%d\bin\psql.exe"

"%PSQL%" -U postgres -h localhost -d comp3005_a3 -v ON_ERROR_STOP=1 -f "%~dp0setup.sql"
