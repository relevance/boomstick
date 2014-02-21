#!/usr/bin/env bash


# Run me from root level of project.


set -o xtrace
set -o nounset


SKIP_UPLOAD=${SKIP_UPLOAD:-} # Accommodate override.

OUTPUT_DIR=output-virtualbox-iso

export USERNAME=dev
export PASSWORD=dev
export VM_NAME="boomstick"


# Remove older VM.
if [[ $(VBoxManage list vms) =~ $VM_NAME ]]; then
    VBoxManage unregistervm $VM_NAME --delete
fi


# Do Packer build.
packer build -force ubuntu_64/ubuntu_64.json


# Upload artifacts if SKIP_UPLOAD is unset.
if [ -z "$SKIP_UPLOAD" ]; then
  s3cmd put --acl-public --no-progress $OUTPUT_DIR/$VM_NAME.ovf s3://boomstick/image/
  s3cmd put --acl-public --no-progress $OUTPUT_DIR/$VM_NAME-disk1.vmdk s3://boomstick/image/
fi


# Need 1024MB for CCW REPL.
VBoxManage import $OUTPUT_DIR/$VM_NAME.ovf -vsys 0 --memory 1024
