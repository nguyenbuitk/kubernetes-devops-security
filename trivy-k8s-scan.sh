#!/bin/bash
# trivy scan application image

echo $imageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName
trivy_output=$(docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $imageName)

num_critical=$(echo "$trivy_output" | grep -oP 'CRITICAL:\s*\K\d+')

# Output the number of critical vulnerabilities
echo "Total: $num_critical (CRITICAL: $num_critical)"

# Output the list of critical vulnerabilities
echo "$trivy_output"


    # exit_code=$?
    # echo "Exit Code : $exit_code"

    # if [[ ${exit_code} == 1 ]]; then
    #     echo "Image scanning fail. Vulnerability found"
    #     exit 1;
    # else
    #     echo "Image scanning passed. No vulnerabilities found"
    # fi;
