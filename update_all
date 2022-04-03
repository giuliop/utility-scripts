#!/usr/bin/env bash

# Detect os
os=$(uname)

if [[ $os == 'Darwin' ]]; then  # we mare on macOs
    brew update
    brew outdated
    brew upgrade
else                            # assume ubuntu
    sudo apt-get -y update
    sudo apt-get -y upgrade
fi
