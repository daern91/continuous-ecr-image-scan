#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then echo "Please pass at least one repository argument" && exit 1; fi

checkScanResult()
{
    if [ "$1" == "IN_PROGRESS" ]; then
        sleep $2
        SCAN_RESULT=$(aws ecr describe-image-scan-findings --repository-name ${REPOSITORY} --image-id imageTag=latest)
        SCAN_STATUS=$(echo $SCAN_RESULT | jq .imageScanStatus.status -r)
        SCAN_FINDINGS=$(echo $SCAN_RESULT | jq .imageScanFindings.findings -r)
        checkScanResult $SCAN_STATUS $(($2 * 2))
    fi
}

for REPOSITORY in "$@"
do
    echo "Checking scanning results for repository ${REPOSITORY}"
    checkScanResult "IN_PROGRESS" 1
    echo 'Checks finished...'
    if [ "$SCAN_STATUS" != "COMPLETE" ]  || [ "$SCAN_FINDINGS" != "[]"  ]; then
        echo "Something went wrong with scan in $REPOSITORY..."
        echo "Status: $SCAN_STATUS"
        echo "Findings: $SCAN_FINDINGS"
        echo ""
        exit 1
    else
        echo "Image in $REPOSITORY was successfully scanned and reported no vulnerabilities"
        echo ""
    fi
done

