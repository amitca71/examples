![image](../images/confluent-logo-300-2.png)
execute the 1st step on powershell, as the $PWD on cygwin is not correct
execute docker-compose exec ksqldb-cli ksql http://ksqldb-server:8088 on cygwin as on powershell it shows error


for elastic search memory problem :
wsl -d docker-desktop
sysctl -w vm.max_map_count=262144
# Overview

This example shows how KSQL can be used to process a stream of click data, aggregate and filter it, and join to information about the users.
Visualisation of the results is provided by Grafana, on top of data streamed to Elasticsearch. 

# Documentation

You can find the documentation for running this example and its accompanying tutorial at [https://docs.confluent.io/platform/current/tutorials/examples/clickstream/docs/index.html](https://docs.confluent.io/platform/current/tutorials/examples/clickstream/docs/index.html?utm_source=github&utm_medium=demo&utm_campaign=ch.examples_type.community_content.clickstream)
