#!/bin/bash -x

set -e

real_path=$(realpath $0)
cd ${real_path%/*}

source configs/env-config.sh
export BIFROST_GIT_URL=${BIFROST_GIT_URL:-"https://github.com/openstack/bifrost"}
export BIFROST_GIT_BRANCH=${BIFROST_GIT_BRANCH:-"master"}
export ANSIBLE_FROM_PYPI="True"
export CONDUCTOR_KEY=${CONDUCTOR_KEY:-""}

# Install initial requirments
sudo apt update -y
sudo apt dist-upgrade -y
sudo apt install -y --no-install-recommends \
    git

# Clone bifrost
if [[ -d bifrost ]]; then
    pushd bifrost
    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"
    git stash save "heimdall_$(date '+%d%m%Y%H%M%S')"
    if [[ "$(git config --get remote.origin.url)" != "${BIFROST_GIT_URL}" ]]; then
        git remote set-url origin ${BIFROST_GIT_URL}
    fi
    git remote update origin --prune
    git fetch --tags
    git checkout ${BIFROST_GIT_BRANCH}
    git pull --rebase origin ${BIFROST_GIT_BRANCH}
    popd
else
    git clone -b ${BIFROST_GIT_BRANCH} ${BIFROST_GIT_URL} bifrost
fi

# Install bifrost
bash -x ./bifrost/scripts/env-setup.sh

# Configure bifrost
rm -f bifrost/playbooks/inventory/group_vars/*
cp group_vars/all bifrost/playbooks/inventory/group_vars/all
cp configs/group_vars/* bifrost/playbooks/inventory/group_vars/

# Install Ironic
pushd bifrost/playbooks
ansible-playbook -vvvv -i inventory/localhost install.yaml
popd

echo "${CONDUCTOR_KEY}" /home/ironic/.ssh/id_rsa
