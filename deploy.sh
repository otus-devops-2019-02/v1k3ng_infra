#!/bin/bash

# install and start puma

# clone repo
cd $HOME
git clone -b monolith https://github.com/express42/reddit.git

# bundle install
cd reddit
bundle install

# start server
puma -d



