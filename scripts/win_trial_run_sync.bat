@echo off
curl.exe -X POST emi-after-sales.test/api/utility/sync/start ^
  -H "Content-Type: application/json" ^
  -d "{\"job_name\":\"sync_customer\"}"
pause