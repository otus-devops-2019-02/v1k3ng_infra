#!/bin/bash

# install Mongo-DB

# add key
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

# add repo
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'

# update info about repo 
sudo apt update

# install package
sudo apt install -y mongodb-org

# enable and start mongodb
sudo systemctl enable mongod
sudo systemctl start mongod

