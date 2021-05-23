#!/usr/bin/env bash

# Install RbEnv

git clone https://github.com/sstephenson/rbenv.git ~/.rbenv

# Install Ruby Build
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

# Automatic Rehashing
git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash

source $(dirname $0)/path.zsh
source $(dirname $0)/rbenv.zsh

rbenv install 2.7.1
rbenv global 2.7.1

gem install bundler
