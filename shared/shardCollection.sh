#!/bin/bash

mongo admin --host 192.168.103.100:26000 --authenticationDatabase admin -u m103-admin -p m103-pass --eval '
    sh.enableSharding("m103")
'
mongo m103 --host 192.168.103.100:26000 --authenticationDatabase admin -u m103-admin -p m103-pass --eval '
    db.products.createIndex({"sku": 1});
    db.adminCommand( { shardCollection: "m103.products", key: { "sku": 1 } } );
'