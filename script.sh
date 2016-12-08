#!/bin/bash -ex

SSH_ADDRESS="192.168.122.194"
SSH_KEY="seed_key.rsa"
SSH_USER="user"

SSH_ARGS="-o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no -o IdentityFile=${SSH_KEY} -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o User=${SSH_USER} -o ConnectTimeout=10"

# Verify SSH access
ssh ${SSH_ARGS} ${SSH_ADDRESS} true

# Copy heimdall to target
scp -r ${SSH_ARGS} ./ ${SSH_ADDRESS}:heimdall/

# Run heimdall
ssh ${SSH_ARGS} ${SSH_ADDRESS} bash ./heimdall/heimdall.sh
