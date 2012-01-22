#!/usr/bin/env bash

cd ~
cp .gitconfig .gitconfig.backup
sed 's/--hidden--/08d16bdfc1221e87df40dd20b8ff41f9/' ~/dev/dotfiles/.gitconfig-hidden-token > .gitconfig

