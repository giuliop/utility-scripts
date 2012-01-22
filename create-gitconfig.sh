#!/usr/bin/env bash

cd ~
sed 's/08d16bdfc1221e87df40dd20b8ff41f9/--hidden--/' \
    .gitconfig > ~/dev/dotfiles/.gitconfig-hidden-token 

