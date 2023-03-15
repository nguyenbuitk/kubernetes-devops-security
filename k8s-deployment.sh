#!/bin/bash

# file này kiểm tra k8s deployment có tồn tại không, nếu có thì update image của container. nếu không thì deploy mới

sed -i "s#replace#${imageName}#g" k8s_deployment_service.yaml
kubectl -n default get deployment ${deploymentName} > /dev/null

# nếu output command = 1 (tức là error không tìm thấy deployment)
if [[ $? -ne 0]]; then
    echo "deployment ${deploymentName} doesn't exist"
    kubectl -n default apply -f k8s_deployment_service.yaml
else
    echo "deployment ${deployment} exist"
    echo "image name - ${imageName}"
    kubectl -n default set image deploy ${deploymentName} ${containerName}=${imageName} --record=true
fi
