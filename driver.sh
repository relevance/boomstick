#!/bin/bash
set -e


# Run me from root level of project.
# Will use system ISOs in ./packer_cache if available.


# TODO Paths.


ARCHIVE=/Users/daemian/src/boomstick/srv


if [ ! -d "srv" ]; then
    echo "Creating srv directory."
    mkdir srv
fi


echo "Ensuring the contents of $ARCHIVE are mirrored in srv."
cp $ARCHIVE/* srv &> /dev/null


if [ ! -h "srv/editor_configs" ]; then
    echo "Symlinking $(pwd)/editor_configs in srv."
    ln -s $(pwd)/editor_configs srv/
fi


# Remove older VM.
VBoxManage unregistervm packer-virtualbox-iso --delete 2> /dev/null || true


# Do Packer build.
packer build -force ubuntu_64/ubuntu_64.json


# Need 1024MB for CCW REPL.
VBoxManage import output-virtualbox-iso/packer-virtualbox-iso.ovf -vsys 0 --memory 1024
