#!/bin/bash

export OLDHOSTNAME=$(cat /etc/hostname)
sudo echo "m103" > /etc/hostname
sudo sed 's/'$OLDHOSTNAME'/m103/g' /etc/hosts

sudo mkdir -p /var/mongodb/pki
sudo chown vagrant:vagrant -R /var/mongodb
openssl rand -base64 741 > /var/mongodb/pki/m103-keyfile
chmod 600 /var/mongodb/pki/m103-keyfile

mkdir /var/mongodb/db/1
mkdir /var/mongodb/db/2
mkdir /var/mongodb/db/3

mongod -f /shared/mongod-repl-1.conf

mongo admin --host localhost:27001 --eval '
  rs.initiate()
'

sleep 1

mongo admin --host localhost:27001 --eval '
  db.createUser({
    user: "m103-admin",
    pwd: "m103-pass",
    roles: [
      {role: "root", db: "admin"}
    ]
  })
'
mongod -f /shared/mongod-repl-2.conf
mongo admin --host 192.168.103.100:27001 -u m103-admin -p m103-pass --eval '
  rs.add("192.168.103.100:27002")
'
mongod -f /shared/mongod-repl-3.conf
mongo admin --host 192.168.103.100:27001 -u m103-admin -p m103-pass --eval '
  rs.add("192.168.103.100:27003")
'