#!/bin/bash
set -e
set -o pipefail

unset SERVICE_NAME
unset ACTION_TYPE
unset WORKSPACE
unset AWS_PROFILE
unset DBHOST
unset DBNAME
unset INIT_DB_WORKSPACE

usage() {
  cat <<EOM
    Usage:
    mongo_actions.sh -s|--service_name <SERVICE_NAME> -a|--action <mongo_backup/mongo_restore> -w|--workspace <Terraform workspace> -p|--profile <AWS_PROFILE> -dbh|--dbhost <Mongo DB URI> -dbn|--dbname <DB NAME> -dbs|--source_db <source workspace to copy DB from on restore(optional)>
    I.E. for backup 
    mongo_actions.sh --service_name myService --action mongo_backup --workspace my-data --profile my-aws-profile --dbhost mongodb+srv://my-mongodb-connection-string --dbname myDB
    I.E. for restore
    mongo_actions.sh --service_name myService --action mongo_restore --workspace my-data --profile my-aws-profile --dbhost mongodb+srv://my-mongodb-connection-string --dbname myDB --source_db test-data
EOM
    exit 1
}

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -s|--service_name)
      SERVICE_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -a|--action)
      ACTION_TYPE="$2"
      shift # past argument
      shift # past value
      ;;
    -w|--workspace)
      WORKSPACE="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--profile)
      AWS_PROFILE="$2"
      shift # past argument
      shift # past value
      ;;
    -dbh|--dbhost)
      DBHOST="$2"
      shift # past argument
      shift # past value
      ;;
    -dbn|--dbname)
      DBNAME="$2"
      shift # past argument
      shift # past value
      ;;
    -sdb|--source_db)
        INIT_DB_WORKSPACE="$2"
        shift # past argument
        shift # past value
      ;;
    -h|--help)
        usage
        shift # past argument
        shift # past value
      ;;
    *)    # unknown option
      echo "Error in command line parsing: unknown parameter ${*}" >&2
      exit 1
  esac
done

: ${SERVICE_NAME:?Missing -s|--service_name type -h for help}
: ${ACTION_TYPE:?Missing -a|--action type -h for help}
: ${WORKSPACE:?Missing -w|--workspace type -h for help}
: ${AWS_PROFILE:?Missing -p|--profile type -h for help}
: ${DBHOST:?Missing -dbh|--dbhost type -h for help}
: ${DBNAME:?Missing -dbn|--dbname type -h for help}

### VALIDATE MONGODB URI FORMAT ###
if [[ "$DBHOST" =~ ^mongodb\+srv\:\/\/.*$ ]]; then
    echo "Validating mongoDB uri"
else
    echo "Please use a valid mongoDB uri mongodb+srv://myMongo-server"
    exit 1
fi

### VALIDATE DUMP EXISTS FOR RESTORE ###
if [[ "${ACTION_TYPE}" == "mongo_restore" ]]; then
    aws s3api head-object --bucket ${SERVICE_NAME}-mongodb-dumps --key $WORKSPACE/$DBNAME.tar --profile $AWS_PROFILE || object_not_exist=true
    if [[ $object_not_exist && -z "${INIT_DB_WORKSPACE}" ]]; then
        echo "Dump file not found not performing restore"
        exit 0
    elif [[ $object_not_exist && -n "${INIT_DB_WORKSPACE}" ]]
    then
        ACTION_TYPE="mongo_clone"
    else
        echo "Starting Restore..." 
    fi
fi

if [[ "${ACTION_TYPE}" == "mongo_clone" ]]; then
    SDBNAME=$(aws ssm get-parameter --name "/infra/$SERVICE_NAME/$INIT_DB_WORKSPACE-db-name" --query 'Parameter.Value' --profile $AWS_PROFILE  --output text)
    SDBHOST=$(aws ssm get-parameter --name "/infra/$SERVICE_NAME/$INIT_DB_WORKSPACE-db-host" --with-decryption --query 'Parameter.Value' --profile $AWS_PROFILE  --output text)
    SDBUSER=$(aws ssm get-parameter --name "/infra/$SERVICE_NAME/$INIT_DB_WORKSPACE-db-username" --with-decryption --query 'Parameter.Value' --profile $AWS_PROFILE  --output text)
    SDBPASSWORD=$(aws ssm get-parameter --name "/infra/$SERVICE_NAME/$INIT_DB_WORKSPACE-db-password" --with-decryption --query 'Parameter.Value' --profile $AWS_PROFILE  --output text)
    if [[ -z "$SDBUSER" ]] || [[ -z "$SDBPASSWORD" ]] || [[ -z "$SDBHOST" ]]; then
        echo "Could not retrieve one or more parameters from SSM!!!"
        exit 1
    fi
fi

### GET DB CONNECTION DETAILS FROM SSM ###
DBNAME=$(aws ssm get-parameter --name "/infra/$SERVICE_NAME/$WORKSPACE-db-name" --query 'Parameter.Value' --profile $AWS_PROFILE  --output text)
DBUSER=$(aws ssm get-parameter --name "/infra/$SERVICE_NAME/$WORKSPACE-db-username" --with-decryption --query 'Parameter.Value' --profile $AWS_PROFILE  --output text)
DBPASSWORD=$(aws ssm get-parameter --name "/infra/$SERVICE_NAME/$WORKSPACE-db-password" --with-decryption --query 'Parameter.Value' --profile $AWS_PROFILE  --output text)
if [[ -z "$DBNAME"  ]] || [[ -z "$DBUSER" ]] || [[ -z "$DBPASSWORD" ]]; then
        echo "Could not retrieve one or more parameters from SSM!!!"
        exit 1
fi

### VALIDATE DOCKER IS INTALLED AND RUNNING ###
if [[ `docker ps` ]]; then
  echo "Preparing to ${ACTION_TYPE}..."
  echo "pulling mongo docker image..."
  docker pull mongo
else
  echo "docker is missing or docker daemon is not running !!!"
  exit 127
fi

### MONGO DB BACKUP ###
mongo_backup() {
    aws s3api head-bucket --bucket ${SERVICE_NAME}-mongodb-dumps --profile $AWS_PROFILE || bucket_not_exist=true
    if [ $bucket_not_exist ]; then
      echo "Bucket not found, Creating new bucket ${SERVICE_NAME}-mongodb-dumps..."
      aws s3api create-bucket --bucket ${SERVICE_NAME}-mongodb-dumps --profile $AWS_PROFILE --no-cli-pager
      aws s3api put-bucket-versioning --bucket ${SERVICE_NAME}-mongodb-dumps --versioning-configuration Status=Enabled --profile $AWS_PROFILE
      aws s3api put-public-access-block --bucket ${SERVICE_NAME}-mongodb-dumps --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" --profile $AWS_PROFILE
    fi
    [ ! "$(docker ps -a | grep mongodocker)" ] && docker run --name mongodocker -i -d mongo bash
    docker exec -i mongodocker /usr/bin/mongodump --uri "$DBHOST/$DBNAME" -u$DBUSER -p$DBPASSWORD --gzip -o /tmp/$DBNAME
    docker cp mongodocker:/tmp/$DBNAME /tmp/$DBNAME
    tar cvf /tmp/$DBNAME.tar -C /tmp/$DBNAME/ .
    aws s3 cp /tmp/$DBNAME.tar s3://${SERVICE_NAME}-mongodb-dumps/$WORKSPACE/ --profile $AWS_PROFILE
    rm -rf /tmp/$DBNAME.tar /tmp/$DBNAME
    docker rm -f mongodocker
  }

mongo_clone() {
      echo "Copying init db..."
      [ ! "$(docker ps -a | grep mongodocker)" ] && docker run --name mongodocker -i -d mongo bash
      suffix='.*'
      docker exec -i mongodocker mongodump --uri "$SDBHOST/$SDBNAME" -u$SDBUSER -p$SDBPASSWORD --gzip --archive | mongorestore --uri "$DBHOST" -u$DBUSER -p$DBPASSWORD --nsFrom="$SDBNAME.*" --nsTo="$DBNAME.*" --gzip --archive
      docker rm -f mongodocker
}

### MONGO DB RESTORE
mongo_restore() {
      aws s3 cp s3://${SERVICE_NAME}-mongodb-dumps/$WORKSPACE/$DBNAME.tar /tmp/  --profile $AWS_PROFILE
      mkdir -p /tmp/dump
      tar xvf /tmp/$DBNAME.tar -C /tmp/dump
      [ ! "$(docker ps -a | grep mongodocker)" ] && docker run --name mongodocker -i -d mongo bash
      docker cp /tmp/dump mongodocker:/tmp/dump
      docker exec -i mongodocker /usr/bin/mongorestore --uri "$DBHOST" -u$DBUSER -p$DBPASSWORD --gzip /tmp/dump
      rm -rf /tmp/$DBNAME.tar /tmp/dump
      docker rm -f mongodocker
}

$ACTION_TYPE
