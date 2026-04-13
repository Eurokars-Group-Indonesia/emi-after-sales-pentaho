#!/bin/bash

echo "=========================="
echo "START SYNC PROCESS"
echo "=========================="

# 1. Notify Laravel START
curl -k -X POST https://app-staging.mazda.co.id:8443/api/utility/sync/start \
 -H "Content-Type: application/json" \
 -d '{"job_name":"sync_pentaho"}'

echo ""
echo "=========================="
echo "RUNNING PENTAHO"
echo "=========================="

# 2. Run Pentaho Job (via Docker container)
docker exec pentaho \
/opt/pentaho/pdi/kitchen.sh \
-file=/opt/pentaho/etl/jobs/job_sync_wrs_aftersales.kjb \
-param:last_kd_customer=0 \
-param:last_kd_kpi=0 \
-param:last_no_faktur_request=0 \
-level=Basic
#-level=Rowlevel


#docker exec pentaho \
#/opt/pentaho/pdi/kitchen.sh \
#-file=/opt/pentaho/etl/job/job_sync_wrs_aftersales.kjb \
#-param:PG_HOST=192.168.1.238 \
#-param:PG_PORT=5432 \
#-param:PG_DB=wrs_aftersales \
#-param:PG_USER=postgres \
#-param:PG_PASS=meta \
#-param:last_kd_customer=0 \
#-param:last_kd_kpi=0 \
#-param:last_no_faktur_request=0 \
#-level=Basic



EXIT_CODE=$?

echo ""
echo "EXIT CODE: $EXIT_CODE"

# 3. Check result
if [ $EXIT_CODE -ne 0 ]; then
    echo ""
    echo "=========================="
    echo "ETL FAILED"
    echo "=========================="

    curl -k -X POST https://app-staging.mazda.co.id:8443/api/utility/sync/finish \
     -H "Content-Type: application/json" \
     -d '{"job_name":"sync_pentaho","status":"FAILED"}'

    exit 1
fi

# 4. Success
echo ""
echo "=========================="
echo "ETL SUCCESS"
echo "=========================="

curl -k -X POST https://app-staging.mazda.co.id:8443/api/utility/sync/finish \
 -H "Content-Type: application/json" \
 -d '{"job_name":"sync_pentaho","status":"SUCCESS"}'

echo ""
echo "=========================="
echo "END PROCESS"
echo "=========================="

exit 0
