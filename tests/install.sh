#!/bin/bash

# Install docker - https://docs.docker.com/engine/install/ubuntu/
sudo apt install docker docker.io

# https://github.com/phusion/holy-build-box/blob/master/TUTORIAL-1-BASICS.md
#
# Type 'exit' to quit from the bash shell.
sudo docker run -t -i --rm phusion/holy-build-box-64:latest bash
