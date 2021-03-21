#!/bin/bash -x
source ../utils/config.env
source ./delta_configs/env.delta


b=`curl -s -S -XGET -H Accept:application/json -H Content-Type:application/json http://localhost:8083/connectors/`

d=`echo $b | sed 's/\[//' | sed  's/\]//' | sed 's/\"//g' |tr "," "\n"`
for i in $d 
do curl -s -S -XDELETE -H Accept:application/json -H Content-Type:application/json http://localhost:8083/connectors/$i
done




