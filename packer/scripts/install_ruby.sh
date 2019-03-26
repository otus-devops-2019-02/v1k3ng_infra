#!/bin/bash
set -e
# ruby install
# update info about repo
apt update

# install packages
apt install -y ruby-full ruby-bundler build-essential

