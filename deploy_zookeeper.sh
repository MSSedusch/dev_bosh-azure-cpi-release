#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ ! -d "${SCRIPT_DIR}/.local/zookeeper-release" ]; then
    git clone https://github.com/cppforlife/zookeeper-release "${SCRIPT_DIR}/.local/zookeeper-release"
fi

bosh -e bosh-1 -n update-cloud-config "${SCRIPT_DIR}/cc.yaml"
bosh -e bosh-1 -d zookeeper -n deploy "${SCRIPT_DIR}/.local/zookeeper-release/manifests/zookeeper.yml"
$SHELL