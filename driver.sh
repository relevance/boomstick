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


# If we care about post-import connectivity...
# NIC is set to NAT by default. Bridge instead.
VBoxManage modifyvm packer-virtualbox --nic1 bridged
# TODO: Networking incomplete. Need to do something like
# also throw --bridgeadapter1 to point to en0.
# This will need to be aware of host system NIC name and will
# vary by host OS.
# VBoxManage modifyvm packer-virtualbox --bridgeadapter1 en0

# Need to sudo rm /etc/udev/rules.d/70-persistent-net.rules and reboot
