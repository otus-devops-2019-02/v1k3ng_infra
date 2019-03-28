#!/bin/bash

# install and start puma

# clone repo
cd $HOME
git clone -b monolith https://github.com/express42/reddit.git

# bundle install
cd reddit
bundle install

# start server
#puma -d
wget https://raw.githubusercontent.com/otus-devops-2019-02/v1k3ng_infra/packer-base/packer/files/puma.service -O /etc/systemd/system/puma.service
sudo systemctl daemon-reload 
sudo systemctl enable puma.service

