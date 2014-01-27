#!/bin/bash
set -e

# Run me from root level of project.
# Will use system ISOs in ./packer_cache if available.


# TODO Paths.


# Clean any existing build cruft.
rm -rf output-virtualbox-iso/
rm -rf ~/VirtualBox\ VMs/packer-virtualbox/


# Do Packer build.
packer build ubuntu_64/ubuntu_64.json


# ./output/ovf -> ~/VirtualBox VMs/packer-virtualbox/
# Need 1024MB for CCW REPL.
VBoxManage import output-virtualbox-iso/packer-virtualbox-iso.ovf -vsys 0 --memory 1024
