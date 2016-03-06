#!/usr/bin/env bash

if which puppet > /dev/null; then
  echo "Puppet is already installed"
  exit 0
fi

# Get the puppet rpm and install it.
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum -y install puppet
echo "Puppet installed!"

