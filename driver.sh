#!/bin/bash
set -e


# Run me from root level of project.
# Will use system ISOs in ./packer_cache if available.


# TODO Paths.


# Remove older VM.
VBoxManage unregistervm packer-virtualbox-iso --delete 2> /dev/null || true


# Do Packer build.
packer build -force ubuntu_64/ubuntu_64.json


# Need 1024MB for CCW REPL.
VBoxManage import output-virtualbox-iso/packer-virtualbox-iso.ovf -vsys 0 --memory 1024
