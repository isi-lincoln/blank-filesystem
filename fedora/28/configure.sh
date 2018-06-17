#!/bin/bash

echo "using uname to detect os"
if [[ $(uname -a) = *ubuntu* ]]; then
    sudo apt-get install -qy yum yum-utils &&\
    sudo cp ./repos/fedora*.repo /etc/yum/repos.d &&\
    sudo cp ./repos/vars/releasever /etc/yum/vars/releasever
fi
