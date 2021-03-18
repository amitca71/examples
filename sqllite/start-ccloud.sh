#!/bin/bash

# Source library
source ../utils/ccloud_library.sh
source ../utils/helper.sh

MAX_WAIT=${MAX_WAIT:-60}

ccloud::validate_version_ccloud_cli 1.20.1 \
  && print_pass "ccloud version ok"

ccloud::validate_logged_in_ccloud_cli \
  && print_pass "logged into ccloud CLI"

printf "\n====== Create new Confluent Cloud stack\n"
[[ -z "$NO_PROMPT" ]] && ccloud::prompt_continue_ccloud_demo
export EXAMPLE="sqllite-to-s3"
#AMIT change zone
export CLUSTER_CLOUD="aws" 
export CLUSTER_REGION="ap-south-1"

#AMIT false means no cloud ksql
ccloud::create_ccloud_stack false

SERVICE_ACCOUNT_ID=$(ccloud kafka cluster list -o json | jq -r '.[0].name' | awk -F'-' '{print $4;}')
if [[ "$SERVICE_ACCOUNT_ID" == "" ]]; then
  printf "\nERROR: Could not determine SERVICE_ACCOUNT_ID from 'ccloud kafka cluster list'. Please troubleshoot, destroy stack, and try again to create the stack.\n"
  exit 1
fi
export CONFIG_FILE=stack-configs/java-service-account-$SERVICE_ACCOUNT_ID.config

printf "\n====== Generating Confluent Cloud configurations\n"
ccloud::generate_configs $CONFIG_FILE

DELTA_CONFIGS_DIR=delta_configs
source $DELTA_CONFIGS_DIR/env.delta

printf "\n====== Creating demo topics\n"
./scripts/create-topics-ccloud.sh ./topics.txt

printf "\n====== Starting local services in Docker\n"
docker-compose -f docker-compose-ccloud.yml up -d --build 

printf "\n====== Giving services $WARMUP_TIME seconds to startup\n"
sleep $WARMUP_TIME 
MAX_WAIT=240
echo "Waiting up to $MAX_WAIT seconds for connect to start"
retry $MAX_WAIT check_connect_up connect || exit 1
printf "\n\n"


printf "\n====== Submitting connectors\n\n"
printf "====== Submitting Kafka Connector to source customers from sqlite3 database and produce to topic 'customers'\n"
INPUT_FILE=./connectors/connector_jdbc_customers_template.config 
OUTPUT_FILE=./connectors/rendered-connectors/connector_jdbc_customers.config 
SQLITE_DB_PATH=/opt/docker/db/data/microservices.db
source ./scripts/render-connector-config.sh 
curl -s -S -XPOST -H Accept:application/json -H Content-Type:application/json http://localhost:8083/connectors/ -d @$OUTPUT_FILE


printf "\n\n====== Submitting Kafka Connector to sink records from all to S3\n"
INPUT_FILE=./connectors/connector_amits3sink_template.config
OUTPUT_FILE=./connectors/rendered-connectors/connector_amits3sink.config
source ./scripts/render-connector-config.sh
curl -s -S -XPOST -H Accept:application/json -H Content-Type:application/json http://localhost:8083/connectors/ -d @$OUTPUT_FILE


printf "\n\n====== Submitting Kafka Connector to JDBC MSSQL\n"
INPUT_FILE=./connectors/jdbc_mssql_templeate.config
OUTPUT_FILE=./connectors/rendered-connectors/jdbc_mssql.conf
KAFKA_JDBC_MODE=incrementing
source ./scripts/render-connector-config.sh
curl -s -S -XPOST -H Accept:application/json -H Content-Type:application/json http://localhost:8083/connectors/ -d @$OUTPUT_FILE


echo  
echo "To destroy the Confluent Cloud resources and stop the demo, run ->"
echo "    ./stop-ccloud.sh $CONFIG_FILE"
echo

echo
ENVIRONMENT=$(ccloud::get_environment_id_from_service_id $SERVICE_ACCOUNT_ID)
echo "Tip: 'ccloud' CLI has been set to the new environment $ENVIRONMENT"

