#!/bin/bash
# trivy scan application image

echo $imageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName
trivy_output=$(docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $imageName)

output=$(echo "$trivy_output" | grep -oP 'CRITICAL:\s*\K\d+')

# Initialize sum variable
sum=0

# Loop over each number in the array and add to sum
for num in "${output[@]}"; do
    sum=$((sum + num))
done

# Output the sum
echo "Total critical vulnerabilities found: $sum"


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
