#!/usr/bin/env bash


# Run me from root level of project.


set -o xtrace
set -o errexit
set -o pipefail
set -o nounset


SKIP_UPLOAD=${SKIP_UPLOAD:-} # Accommodate override.

OUTPUT_DIR=output-virtualbox-iso

export USERNAME=dev
export PASSWORD=dev
export VM_NAME="boomstick"


# Do Packer build.
packer build -force ubuntu_64/ubuntu_64.json


# Upload artifacts if SKIP_UPLOAD is unset.
if [ -z "$SKIP_UPLOAD" ]; then
  s3cmd put --acl-public --no-progress importer.sh s3://boomstick/image/
  s3cmd put --acl-public --no-progress $OUTPUT_DIR/$VM_NAME.ovf s3://boomstick/image/
  s3cmd put --acl-public --no-progress $OUTPUT_DIR/$VM_NAME-disk1.vmdk s3://boomstick/image/
fi
