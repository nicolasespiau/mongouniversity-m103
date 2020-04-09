# Using Docker instead of Vagrant in MongoDB University m103 course

## Purpose of this repository

This project aims to allow user that are already using Docker to perform [m103 course from MongoDB University](https://university.mongodb.com/mercury/M103/2020_March_10/overview) instead of using Vagrant.

## How it works

:warning: **On this branch you have to rebuild the Docker image in order to include in the build some steps made in previous labs.**

First build the image:
```bash
docker build -t local/m103mongosrv .
```

Create the network:
```sh
docker network create --subnet 192.168.0.0/16 m103
```

Run the container:
```bash
docker run -dt --rm --name m103 --net m103 --ip 192.168.103.100 --cpus 2 -v PATH/TO/YOUR/PROJECT/DIR/shared:/shared local/m103mongosrv
```

This image does not run mongod by default. It only create the container and keep it alive so you can exec a bash on it and then launch mongod with the different configuration you need.

To connect to the machine, instead of `vagrant ssh`:
```bash
docker exec -ti m103 bash
```
