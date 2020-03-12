# Using Docker instead of Vagrant in MongoDB University m103 course

## Purpose of this repository

This project aims to allow user that are already using Docker to perform [m103 course from MongoDB University](https://university.mongodb.com/mercury/M103/2020_March_10/overview) instead of using Vagrant.

## How it works

First build the image:
```bash
docker build -t local/m103mongosrv .
```

Run the container:
```bash
docker run -dt --rm --name m103 --cpus2 -v PATH/TO/YOUR/PROJECT/DIR/shared:/shared -p 27017:27017 local/m103mongosrv
```

To connect to the machine, instead of `vagrant ssh`:
```bash
docker exec -ti m103 bash
```