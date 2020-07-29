#!/usr/bin/env bash

# Schedule the export
set -x
EXPORT_SCHEDULE_MAIN=$(curl -X POST -H "PRIVATE-TOKEN: $GITLAB_METRICS_API_TOKEN" https://gitlab.metrics.ca/api/v4/projects/192/export)
set +x

echo $EXPORT_SCHEDULE_MAIN
EXPORT_MESSAGE_MAIN=$(echo $EXPORT_SCHEDULE_MAIN | jq -r .message)
# exit if the message wasn't successful
if [[ $EXPORT_MESSAGE_MAIN != "202 Accepted" ]]; then 
    echo "export main was not scheduled"; 
    exit 1; 
fi

# gather the status of the export
EXPORT_STATUS_MAIN=$(curl -H "PRIVATE-TOKEN: $GITLAB_METRICS_API_TOKEN" https://gitlab.metrics.ca/api/v4/projects/192/export | jq -r .export_status)
echo $EXPORT_STATUS_MAIN
# wait for the status to be finished
while [ $EXPORT_STATUS_MAIN != "finished" ] && [ $EXPORT_STATUS_MAIN != "failed" ]; do 
    sleep 10; 
    echo "waiting for export to complete"; 
    # gather the status of the export
    EXPORT=$(curl -H "PRIVATE-TOKEN: $GITLAB_METRICS_API_TOKEN" https://gitlab.metrics.ca/api/v4/projects/192/export)
    EXPORT_STATUS_MAIN=$(echo $EXPORT | jq -r .export_status)
done
echo $EXPORT_STATUS_MAIN

# download the export tar ball
curl -H "PRIVATE-TOKEN: $GITLAB_METRICS_API_TOKEN" https://gitlab.metrics.ca/api/v4/projects/192/export/download --output qa_runner_project.tar.gz