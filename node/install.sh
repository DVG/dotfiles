#!/usr/bin/env bash

export NVM_DIR=~/.nvm
if test ! $(which nvm)
then
  echo "Installing NVM, Node, Bower and Ember"
  curl https://raw.githubusercontent.com/creationix/nvm/v0.24.0/install.sh | bash
  source ~/.nvm/nvm.sh
  nvm install 0.10
  nvm use 0.10
  nvm alias default stable

  npm install -g bower
  npm install -g ember-cli
  npm install -g grunt-cli
fi
unset NVM_DIR
