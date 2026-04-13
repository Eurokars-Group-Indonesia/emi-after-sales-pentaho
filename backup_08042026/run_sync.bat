@echo off

echo ==========================
echo START SYNC PROCESS
echo ==========================
pause

:: 1. Notify Laravel START
curl.exe -X POST http://emi-after-sales.test/api/utility/sync/start ^
 -H "Content-Type: application/json" ^
 -d "{\"job_name\":\"sync_pentaho\"}"

echo.
echo ==========================
echo RUNNING PENTAHO
echo ==========================
pause

:: 2. Run Pentaho Job
call "D:\pentaho\pdi-ce-11.0.0.0-237\data-integration\Kitchen.bat" ^
/file:"D:\laragon\www\emi-after-sales\storage\pentaho\job\job_sync_wrs_aftersales.kjb" ^
/param:last_kd_customer="0" ^
/param:last_kd_kpi="0" ^
/param:last_no_faktur_request="0" ^
/level:Basic

echo.
echo ERRORLEVEL: %ERRORLEVEL%
pause

:: 3. Check result
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo ==========================
    echo ETL FAILED
    echo ==========================
    pause

    curl.exe -X POST http://emi-after-sales.test/api/utility/sync/finish ^
     -H "Content-Type: application/json" ^
     -d "{\"job_name\":\"sync_pentaho\",\"status\":\"FAILED\"}"

    pause
    exit /b 1
)

:: 4. Success
echo.
echo ==========================
echo ETL SUCCESS
echo ==========================
pause

curl.exe -X POST http://emi-after-sales.test/api/utility/sync/finish ^
 -H "Content-Type: application/json" ^
 -d "{\"job_name\":\"sync_pentaho\",\"status\":\"SUCCESS\"}"

echo.
echo ==========================
echo END PROCESS
echo ==========================
pause

exit /b 0