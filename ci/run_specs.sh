#!/bin/bash

set -e

mkdir -p ${HOME}/.ssh && \
echo -e ${SSH_PRIVATE_KEY} >> $HOME/.ssh/id_rsa && \

suite=$1
echo -e "\033[0;32mRunning test suite ${suite}\033[0m"
kitchen test ${suite}
