#!/bin/bash
set -x

source vars.sh
yum -y install $packages
