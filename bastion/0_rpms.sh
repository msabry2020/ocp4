#!/bin/bash

echo "Load variables from vars file\n"
source vars.sh

echo "Install the required packages\n"
yum -y install $packages