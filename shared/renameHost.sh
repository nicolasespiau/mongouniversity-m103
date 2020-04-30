#!/bin/bash

export OLDHOSTNAME=$(cat /etc/hostname)
sudo echo "m103" > /etc/hostname
sudo sed 's/'$OLDHOSTNAME'/m103/g' /etc/hosts