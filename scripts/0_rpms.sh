#!/bin/bash

echo -e "Load variables from vars file\n"
source vars.sh

echo -e "Install the required packages\n"
yum -y install $packages
