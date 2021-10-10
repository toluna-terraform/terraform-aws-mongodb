#!/bin/bash

eval "$(jq -r '@sh "BUCKET_NAME=\(.bucket) KEY=\(.key) AWS_PROFILE=\(.profile)"')"
object=$(aws s3api head-object --bucket $BUCKET_NAME --key $KEY --profile $AWS_PROFILE --no-cli-pager || echo "Not Found")
if [[ $object == *"Not Found"* ]]; then
    object='{"Message":"Dump file for this environment does not exist"}'
    jq -n --arg object "${object}" '{$object}'
else 
    jq -n --arg object "${object}" '{$object}' 
fi    
