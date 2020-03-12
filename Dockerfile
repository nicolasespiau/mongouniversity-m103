FROM ubuntu:trusty

# Config
COPY transparent_hugepage.enabled /sys/kernel/mm/transparent_hugepage/enabled
COPY transparent_hugepage.defrag /sys/kernel/mm/transparent_hugepage/defrag
# disable mongod upstart service
RUN echo 'manual' | sudo tee /etc/init/mongod.override
RUN export CLIENT_IP_ADDR=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | tail -1`
RUN export CLIENT_NAME=`hostname | cut -d. -f 1 | tr '[:upper:]' '[:lower:]'`

# IP CONFIG
COPY etchosts /etc/hosts
RUN echo "$CLIENT_IP_ADDR $CLIENT_NAME" >> /etc/hosts

# UPDATE REPO
RUN echo "deb [ arch=amd64 ] http://repo.mongodb.com/apt/ubuntu trusty/mongodb-enterprise/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-enterprise.list
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 0C49F3730359A14518585931BC711F9BA15703C6
RUN sudo apt-get update -y
RUN sudo apt-get install -y libgssapi-krb5-2 libsasl2-2 libssl1.0.0 libstdc++6 snmp

# INSTALL MONGO
RUN sudo apt-get install -y mongodb-enterprise --force-yes
RUN mkdir -p /var/log/mongodb/
RUN sudo echo 'security:'  | sudo tee -a /etc/mongod.conf
RUN sudo echo '  authorization: enabled'  | sudo tee -a /etc/mongod.conf

# SET USER SETUP
RUN sudo useradd -m m103
RUN sudo sh -c "killall mongod; true"
RUN sudo mkdir -p /data
RUN sudo chmod -R 777 /data
RUN mkdir -p /data/db
RUN mkdir -p /home/m103/data
RUN chmod -R 777 /home/m103/data
RUN chown -R m103:m103 /home/m103/data
RUN mkdir -p /var/m103/validation
RUN sudo echo "export LC_ALL=C" >> /home/m103/.profile
RUN sudo echo "PATH=$PATH:/var/m103/validation" >> /home/m103/.profile

# INSTALL PYMONGO
RUN sudo apt-get -y install python-pip
RUN sudo pip install pymongo

# DL DATASET
RUN sudo apt-get install -y curl
RUN mkdir /dataset
RUN curl -s https://s3.amazonaws.com/edu-static.mongodb.com/lessons/M103/products.json.tgz -o products.json.tgz
RUN tar -xzvf products.json.tgz -C /dataset
RUN rm -rf products.json.tgz

RUN curl -s https://s3.amazonaws.com/edu-static.mongodb.com/lessons/M103/products.part2.json.tgz -o products.part2.json.tgz
RUN tar -xzvf products.part2.json.tgz -C /dataset
RUN rm -rf products.part2.json.tgz

# DL VALIDATORS
COPY download_validators /var/m103/validation/download_validators
COPY validate_box /var/m103/validation/validate_box
RUN curl -s https://s3.amazonaws.com/edu-static.mongodb.com/lessons/M103/m103_validation.tgz -o m103_validation.tgz
RUN tar -xzvf m103_validation.tgz -C /var/m103/validation
RUN rm -rf m103_validation.tgz
RUN chmod -R +x /var/m103/validation/
RUN chown root:root /var/m103/validation