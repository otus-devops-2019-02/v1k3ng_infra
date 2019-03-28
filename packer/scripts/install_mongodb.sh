#!/bin/bash
set -e
# install Mongo-DB

# add key
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

# add repo
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list

# update info about repo 
apt update

# install package
apt install -y mongodb-org

# enable and start mongodb
systemctl enable mongod
systemctl start mongod

