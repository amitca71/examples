#!/bin/bash

set -m

BOOTSTRAP_SERVERS=${BOOTSTRAP_SERVERS:-broker:9092}
SCHEMA_REGISTRY_URL=${SCHEMA_REGISTRY_URL:-http://schema-registry:8081}
RESTPORT=${RESTPORT:-18894}
JAR=${JAR:-"/usr/share/java/kafka-streams-examples/kafka-streams-examples-$CONFLUENT-standalone.jar"}
PIDS=()
[[ -z "$CONFIG_FILE" ]] && CONFIG_FILE_ARG="" || CONFIG_FILE_ARG="--config-file $CONFIG_FILE"
ADDITIONAL_ARGS=${ADDITIONAL_ARGS:-""}
LOG_DIR=${LOG_DIR:="logs"}
PIDS_FILE=${PIDS_FILE:=".microservices.pids"}

echo "Config File arg: $CONFIG_FILE_ARG"
echo "Additional Args: $ADDITIONAL_ARGS"
echo "Starting microservices from $JAR"
echo "Connecting to cluster @ $BOOTSTRAP_SERVERS and Schema Registry @ $SCHEMA_REGISTRY_URL"


PIDS+=($!)
sleep 10

echo "Microservice processes running under PIDS: ${PIDS[@]}"
echo "${PIDS[@]}" > $PIDS_FILE 
wait $PIDS

