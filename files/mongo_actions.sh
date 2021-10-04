#!/bin/bash

usage() {
  cat <<EOM
    Usage:
    mongo_actions.sh <SERVICE_NAME> <ACTION> <DBHOST>
    I.E. for backup 
    mongo_actions.sh myService mongo_backup mongodb+srv://my-mongodb-connection-string
    I.E. for restore
    mongo_actions.sh myService mongo_restore mongodb+srv://my-mongodb-connection-string
EOM
    exit 1
}
[[ $# -ne 3 ]] && usage

if [[ `mongodump --help` ]] || [[ `mongorestore --help` ]]; then
  echo "Preparing to ${2}..."
else
  echo "mongodump or mongorestore are missing please make sure you have them both installed"
  exit 127
fi

### GET TERRAFORM WORKSPACE ###
[[ "$PWD" == ~ ]] && return
    # check if in terraform dir
    if [[ -d .terraform && -r .terraform/environment  ]]; then
      WORKSPACE=$(cat .terraform/environment) || return
    fi

### GET ENVIRONMENT DATA
ENVIRONMET_DATA=$(jq --arg k "$WORKSPACE" '.[$k]' environments.json)
AWS_PROFILE=$(echo $ENVIRONMET_DATA| jq -r '.aws_profile')

### GET DB CONNECTION DETAILS FROM SSM ###
DBHOST=$3
SERVICE_NAME=$1
DBNAME=$(aws ssm get-parameter --name "/infra/$SERVICE_NAME/$WORKSPACE-db-name" --query 'Parameter.Value' --profile $AWS_PROFILE --output text)
DBUSER=$(aws ssm get-parameter --name "/infra/$SERVICE_NAME/$WORKSPACE-db-username" --with-decryption --query 'Parameter.Value' --profile $AWS_PROFILE  --output text)
DBPASSWORD=$(aws ssm get-parameter --name "/infra/$SERVICE_NAME/$WORKSPACE-db-password" --with-decryption --query 'Parameter.Value' --profile $AWS_PROFILE  --output text)
if [[ -z "$DBNAME"  ]] || [[ -z "$DBUSER" ]] || [[ -z "$DBPASSWORD" ]]; then
        echo "Could not retrieve one or more parameters from SSM!!!"
        exit 1
fi
### MONGO DB BACKUP ###
mongo_backup() {
  if aws s3 ls s3://${SERVICE_NAME}-mongodb-dumps 2>&1 | grep -q 'NoSuchBucket'
    then
      aws s3api create-bucket --bucket ${SERVICE_NAME}-mongodb-dumps --profile $AWS_PROFILE
      aws s3api put-public-access-block --bucket ${SERVICE_NAME}-mongodb-dumps --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" --profile $AWS_PROFILE
    fi
    mongodump --uri "$DBHOST/$DBNAME" -u$DBUSER -p$DBPASSWORD --gzip -o /tmp/$DBNAME
    tar cvf /tmp/$DBNAME.tar -C /tmp/$DBNAME/ .
    aws s3 cp /tmp/$DBNAME.tar s3://${SERVICE_NAME}-mongodb-dumps/$WORKSPACE/ --profile $AWS_PROFILE
    rm -rf /tmp/$DBNAME.tar /tmp/$DBNAME
  }

### MONGO DB RESTORE
mongo_restore() {
    if aws s3api head-object --bucket ${SERVICE_NAME}-mongodb-dumps --key $WORKSPACE/$DBNAME.tar --profile $AWS_PROFILE  2>&1 | grep -q 'Not Found'
      then
        echo "Dump file not found not performing restore"
        exit 0
    else
      aws s3 cp s3://${SERVICE_NAME}-mongodb-dumps/$WORKSPACE/$DBNAME.tar /tmp/  --profile $AWS_PROFILE
      mkdir -p /tmp/dump
      tar xvf /tmp/$DBNAME.tar -C /tmp/dump
      mongorestore --uri "$DBHOST" -u$DBUSER -p$DBPASSWORD --gzip /tmp/dump
      rm -rf /tmp/$DBNAME.tar /tmp/dump
    fi
}

$2
