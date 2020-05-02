#!/bin/bash

mkdir /var/mongodb/db/4
mkdir /var/mongodb/db/5
mkdir /var/mongodb/db/6

cp /shared/mongod-repl-1.conf /shared/mongod-repl-4.conf
sed -i 's/db\/1/db\/4/g' /shared/mongod-repl-4.conf
sed -i 's/27001/27004/g' /shared/mongod-repl-4.conf
sed -i 's/m103-repl/m103-repl-2/g' /shared/mongod-repl-4.conf
cp /shared/mongod-repl-4.conf /shared/mongod-repl-5.conf
cp /shared/mongod-repl-4.conf /shared/mongod-repl-6.conf
sed -i 's/4/5/g' /shared/mongod-repl-5.conf
sed -i 's/4/6/g' /shared/mongod-repl-6.conf

echo "\n\nLaunching db servers"
mongod -f /shared/mongod-repl-4.conf
mongod -f /shared/mongod-repl-5.conf
mongod -f /shared/mongod-repl-6.conf

echo "\n\nWaiting a bit..."
sleep 2

echo "\n\nInitiating replica set"
mongo admin --host localhost:27004 --eval '
  rs.initiate()
'

echo "\n\nWaiting a bit..."
sleep 2

echo "\n\nCreating admin user"
mongo admin --host localhost:27004 --eval '
  db.createUser({
    user: "m103-admin",
    pwd: "m103-pass",
    roles: [
      {role: "root", db: "admin"}
    ]
  })
'

echo "\n\nAdding members"
mongo admin --host localhost:27004 -u m103-admin -p m103-pass --eval '
  rs.add("192.168.103.100:27005")
'
mongo admin --host localhost:27004 -u m103-admin -p m103-pass --eval '
  rs.add("192.168.103.100:27006")
'

echo "\n\nWaiting a bit..."
sleep 2

echo "\n\nSharding replica set"
mongo admin --host 192.168.103.100:26000 -u m103-admin -p m103-pass --eval '
  sh.addShard("m103-repl-2/192.168.103.100:27004")
'