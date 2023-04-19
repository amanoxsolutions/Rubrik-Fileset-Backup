#!/usr/bin/env bash
# Backup ODB (Fileset Backup)
# Backup Epic ODB using Fileset Backup from Rubrik
#
# Author         			Date        Version Info
# --------------------------------------------------------------------------------
# Kirusihaan Sathiyapalan  	2023.04.13  0.0.1   Initial Version

# Variables need to be defined
RUBRIK_IP='RUBRIK FQDN'
HOST_NAME='HOST NAME'

# ===============
# get auth token

TOKEN='generate token on Rubrik CDM (max 365 days)'

# ===============
# get Fileset ID
FILESET_QUERY=$(curl -X GET \
        "https://$RUBRIK_IP/api/v1/fileset" \
        -H  "accept: application/json" \
        -H  "Authorization: $TOKEN" \
        | jq -r '.data[]|select(.name | contains("ODB Proxy VM Backup"))')

FILESET_ID=$(echo $FILESET_QUERY | jq -r '.id')
SLA_ID=$(echo $FILESET_QUERY | jq -r '.configuredSlaDomainId')

# ===============
# check that host exists
HOST_QUERY=$(curl -X GET \
        "https://$RUBRIK_IP/api/v1/fileset/$FILESET_ID" \
        -H "accept: application/json" \
        -H "Authorization: $TOKEN" \
        | jq -r '.hostName')

if [ $(echo "$HOST_QUERY") != "$HOST_NAME" ]; then
    echo "Host $HOST_NAME not found on Rubrik system, exiting"
    exit 1
else
    echo "Fileset of Proxy VM $HOST_NAME found"
fi

# ===============
# run Fileset Backup
SNAPSHOT_REQ=$(curl -X POST \
	"https://$RUBRIK_IP/api/v1/fileset/$FILESET_ID/snapshot"\
	-H "accept: application/json" \
	-H "Authorization: $TOKEN" \
	-H "Content-Type: application/json" \
	-d "{ \"slaId\": \"$SLA_ID\"}")

SNAPSHOT_URL=$(echo $SNAPSHOT_REQ | jq -r '.links[0].href')
SNAPSHOT_STATUS=$(echo $SNAPSHOT_REQ | jq -r '.status')
while [ $SNAPSHOT_STATUS != 'SUCCEEDED' ] && [ $SNAPSHOT_STATUS != 'FAILED' ]
do
    echo "Snapshot status is $SNAPSHOT_STATUS, sleeping..."
    sleep 5
    SNAPSHOT_STATUS=$(curl -k -s \
        --header "Authorization: $TOKEN" -X GET \
        $SNAPSHOT_URL | jq -r '.status')
done
echo "Snapshot done"
exit 0
