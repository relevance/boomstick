#!/usr/bin/env bash


set -o xtrace
set -o errexit
set -o pipefail
set -o nounset


REMOVE_OLD_VM=${REMOVE_OLD_VM:-} # Accommodate override.

export VM_NAME="boomstick"


# Remove older VM if it exists and REMOVE_OLD_VM was set.
if [[ $(VBoxManage list vms) =~ $VM_NAME ]] &&
   [[ -n $REMOVE_OLD_VM ]] ; then
     VBoxManage unregistervm $VM_NAME --delete
fi


# Need 1024MB for CCW REPL.
VBoxManage import $VM_NAME.ovf -vsys 0 --memory 1024
