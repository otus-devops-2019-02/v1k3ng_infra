#!/bin/bash

# update info about repo
sudo apt update
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update

# install packages
sudo apt install -y ruby-full ruby-bundler build-essential mongodb-org

# enable and start mongodb
sudo systemctl enable mongod
sudo systemctl start mongod

# install and start puma
cd /opt
git clone -b monolith https://github.com/express42/reddit.git

# bundle install
cd reddit
bundle install

# start server
puma -d

