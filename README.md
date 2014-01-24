Run `./driver.sh` and stand back.

`sudo rm /etc/udev/rules.d/70-persistent-net.rules` and reboot to have
external network connectivity.

Prepend `PACKER_LOG=1` to see Packer debug messages.


TODO: Desktop editor symlinks not currently visible.
TODO: Relativize paths in `driver.sh`.
TODO: Fix post-import network connectivity issue?
TODO: Find way to DRY up username/password repetition.
TODO: Find real place from which to serve editor binaries.
TODO: Is there an ubuntu-desktop-minimal package?

