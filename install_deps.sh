#!/bin/bash

# The sledge Docker image runs as root
if [ "$(whoami)" == "root" ]; then
  apt-get update
  apt-get install bison swig python-dev -y
else
  sudo apt-get update
  sudo apt-get install bison swig -y
fi
