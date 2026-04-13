#!/bin/bash

echo "=========================="
echo "START SYNC PROCESS"
echo "=========================="
read -p "Press Enter to continue..."

# 1. Notify Laravel START
curl -X POST http://emi-after-sales.test/api/utility/sync/start \
 -H "Content-Type: application/json" \
 -d '{"job_name":"sync_pentaho"}'

echo ""
echo "=========================="
echo "RUNNING PENTAHO"
echo "=========================="
read -p "Press Enter to continue..."

# 2. Run Pentaho Job
/opt/pentaho/pdi-ce-11.0.0.0-237/data-integration/kitchen.sh \
 /file:"/var/www/emi-after-sales/storage/pentaho/job/job_sync_wrs_aftersales.kjb" \
 /param:last_kd_customer="0" \
 /param:last_kd_kpi="0" \
 /param:last_no_faktur_request="0" \
 /level:Basic

EXIT_CODE=$?
echo ""
echo "EXIT CODE: $EXIT_CODE"
read -p "Press Enter to continue..."

# 3. Check result
if [ $EXIT_CODE -ne 0 ]; then
    echo ""
    echo "=========================="
    echo "ETL FAILED"
    echo "=========================="
    read -p "Press Enter to continue..."

    curl -X POST http://emi-after-sales.test/api/utility/sync/finish \
     -H "Content-Type: application/json" \
     -d '{"job_name":"sync_pentaho","status":"FAILED"}'

    read -p "Press Enter to continue..."
    exit 1
fi

# 4. Success
echo ""
echo "=========================="
echo "ETL SUCCESS"
echo "=========================="
read -p "Press Enter to continue..."

curl -X POST http://emi-after-sales.test/api/utility/sync/finish \
 -H "Content-Type: application/json" \
 -d '{"job_name":"sync_pentaho","status":"SUCCESS"}'

echo ""
echo "=========================="
echo "END PROCESS"
echo "=========================="
read -p "Press Enter to continue..."

exit 0