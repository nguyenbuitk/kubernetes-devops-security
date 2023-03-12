#!/bin/bash

# openjdk
# openjdk:8-alpine
# openjdk:8-jdk-alpine
# adoptopenjdk/openjdk8:alpine-slim

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName
whoami
pwd

# Nếu tìm thấy HIGH severity thì return 0, critical return 1
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity HIGH --light $dockerImageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $dockerImageName

    # Trivy scan result processing
    exit_code=$?
    echo "Exit Code : $exit_code"

    # Check scan results
    if [[ "${exit_code}" == 1 ]]; then
        echo "Image scanning failed. Vulnerabilities found"
        exit 1;
    else
        echo "Image scanning passed. No CRITICAL vulnerabilities found"
    fi;
