#!/bin/bash

### make sure repos are up to date
sudo apt-get -qq update -y

### install dependencies for Ruby build
sudo apt-get -qq install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev

### install rbenv from git
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

### modify user's shell for future use
echo 'export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

### enable rbenv in current shell
export PATH=$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH
eval "$(~/.rbenv/bin/rbenv init -)"

### install Ruby 2.3.1
rbenv install 2.3.1
rbenv global 2.3.1

### install latest Jekyll
gem install jekyll
