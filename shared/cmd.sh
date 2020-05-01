#!/bin/bash

sudo mkdir -p /var/mongodb/pki
sudo chown vagrant:vagrant -R /var/mongodb
openssl rand -base64 741 > /var/mongodb/pki/m103-keyfile
chmod 600 /var/mongodb/pki/m103-keyfile

mkdir /var/mongodb/db/1
mkdir /var/mongodb/db/2
mkdir /var/mongodb/db/3
mkdir /var/mongodb/db/csrs1
mkdir /var/mongodb/db/csrs2
mkdir /var/mongodb/db/csrs3

echo "\n\nLauching config servers"
mongod -f /shared/mongod-csrs-1.conf
mongod -f /shared/mongod-csrs-2.conf
mongod -f /shared/mongod-csrs-3.conf

echo "\n\nWaiting a bit..."
sleep 2

echo "\n\nInitiating replica set"
mongo admin --host localhost:26001 --eval '
  rs.initiate()
'

echo "\n\nWaiting a bit..."
sleep 2

echo "\n\nCreating admin user"
mongo admin --host localhost:26001 --eval '
  db.createUser({
    user: "m103-admin",
    pwd: "m103-pass",
    roles: [
      {role: "root", db: "admin"}
    ]
  })
'

echo "\n\nAdding members"
mongo admin --host localhost:26001 -u m103-admin -p m103-pass --eval '
  rs.add("192.168.103.100:26002")
'
mongo admin --host localhost:26001 -u m103-admin -p m103-pass --eval '
  rs.add("192.168.103.100:26003")
'

echo "\n\nWaiting a bit..."
sleep 3

echo "\n\nLaunching mongos"
mongos -f /shared/mongos.conf

echo "\n\nLaunching db servers"
mongod -f /shared/mongod-repl-1.conf
mongod -f /shared/mongod-repl-2.conf
mongod -f /shared/mongod-repl-3.conf

echo "\n\nWaiting a bit..."
sleep 2

echo "\n\nInitiating replica set"
mongo admin --host localhost:27001 --eval '
  rs.initiate()
'

echo "\n\nWaiting a bit..."
sleep 2

echo "\n\nCreating admin user"
mongo admin --host localhost:27001 --eval '
  db.createUser({
    user: "m103-admin",
    pwd: "m103-pass",
    roles: [
      {role: "root", db: "admin"}
    ]
  })
'

echo "\n\nAdding members"
mongo admin --host localhost:27001 -u m103-admin -p m103-pass --eval '
  rs.add("192.168.103.100:27002")
'
mongo admin --host localhost:27001 -u m103-admin -p m103-pass --eval '
  rs.add("192.168.103.100:27003")
'

echo "\n\nWaiting a bit..."
sleep 2

echo "\n\nSharding replica set"
mongo admin --host 192.168.103.100:26000 -u m103-admin -p m103-pass --eval '
  sh.addShard("m103-repl/192.168.103.100:27001")
'
