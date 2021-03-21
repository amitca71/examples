#!/bin/bash
source ../utils/ccloud_library.sh
source ../utils/helper.sh
WARMUP_TIME=80
source ../utils/config.env
source ./delta_configs/env.delta
docker-compose -f docker-compose-ccloud.yml up -d --build
printf "\n====== Giving services $WARMUP_TIME seconds to startup\n"
sleep $WARMUP_TIME 
MAX_WAIT=240
echo "Waiting up to $MAX_WAIT seconds for connect to start"
retry $MAX_WAIT check_connect_up connect || exit 1
printf "\n\n"


#printf "\n====== Submitting connectors\n\n"
#printf "====== Submitting Kafka Connector to source customers from sqlite3 database and produce to topic 'customers'\n"
#INPUT_FILE=./connectors/connector_jdbc_customers_template.config 
#OUTPUT_FILE=./connectors/rendered-connectors/connector_jdbc_customers.config 
#SQLITE_DB_PATH=/opt/docker/db/data/microservices.db
#source ./scripts/render-connector-config.sh 
#curl -s -S -XPOST -H Accept:application/json -H Content-Type:application/json http://localhost:8083/connectors/ -d @$OUTPUT_FILE
#
#
#printf "\n\n====== Submitting Kafka Connector to sink records from all to S3\n"
#INPUT_FILE=./connectors/connector_amits3sink_template.config
#OUTPUT_FILE=./connectors/rendered-connectors/connector_amits3sink.config
#source ./scripts/render-connector-config.sh
#curl -s -S -XPOST -H Accept:application/json -H Content-Type:application/json http://localhost:8083/connectors/ -d @$OUTPUT_FILE
#
#
#printf "\n\n====== Submitting Kafka Connector to JDBC MSSQL\n"
#INPUT_FILE=./connectors/jdbc_mssql_templeate.config
#OUTPUT_FILE=./connectors/rendered-connectors/jdbc_mssql.conf
##KAFKA_JDBC_MODE=incrementing
#KAFKA_JDBC_MODE=bulk
#source ./scripts/render-connector-config.sh
#curl -s -S -XPOST -H Accept:application/json -H Content-Type:application/json http://localhost:8083/connectors/ -d @$OUTPUT_FILE


