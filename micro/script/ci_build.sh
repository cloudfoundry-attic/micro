#!/bin/bash -l

source .rvmrc
cd micro
echo "Installing gems"
(gem install bundler --no-ri --no-rdoc) && (bundle check || bundle install)
rspec