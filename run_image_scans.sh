#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then echo "Please pass at least one repository argument" && exit 1; fi

for REPOSITORY in "$@"
do
    echo "Starting to scan ${REPOSITORY}"
    aws ecr start-image-scan --repository-name ${REPOSITORY} --image-id imageTag=latest &
    PIDs="$PIDs $!"
done

for pid in $PIDs; do
    if wait $pid; then
        echo "Process $pid successfully finished"
    else
        echo "Process $pid failed"
        ERROR="ERROR"
    fi
done

if [ -z "$ERROR" ]
then
    echo "All scans started successfully!"
else
    echo "Could not start scans successfully"
    exit 1
fi

