

curl.exe -X POST http://emi-after-sales.test/api/utility/sync/finish ^
 -H "Content-Type: application/json" ^
 -d "{\"job_name\":\"sync_pentaho\",\"status\":\"FAILED\"}"
 
pause
exit /b 1