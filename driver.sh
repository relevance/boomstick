#!/usr/bin/env bash

set -o xtrace


# Run me from root level of project.
# Will use system ISOs in ./packer_cache if available.


export VM_NAME="boomstick"


# Remove older VM.
if [[ $(VBoxManage list vms) =~ $VM_NAME ]]; then
    VBoxManage unregistervm $VM_NAME --delete
fi


# Do Packer build.
packer build -force ubuntu_64/ubuntu_64.json


# Need 1024MB for CCW REPL.
VBoxManage import output-virtualbox-iso/$VM_NAME.ovf -vsys 0 --memory 1024
