Boomstick
=========
![](resources/boom.png)
### Success criteria

* We provide a VirtualBox image that anyone can download or
distribute on a memory stick for Clojure/ClojureScript/Datomic
training.
* (Lower priority) The same VirtualBox image works well for "beginner
night" Clojure meetups.
* We can easily keep the image up to date as components have new releases.
* Anyone in the company can build & release an update to the image.
* Our method for building the image can be adopted and extended by others.

Each piece of software should be integrated and ready-to-run. E.g., I should be able
to log in as the "dev" user and run lein with no further config or
setup. I should be able to start Eclipse and create a Clojure project
with no further config, etc.


### Usage

Run `./driver.sh` and STAND BACK.


### Program Flow

`driver.sh` will...

- Launch packer to build a new Ubuntu VM named 'boomstick'.  
 - Run `ubuntu_64/bootstrap.sh` to finish provisioning the new VM.  
 - The new VM comprises an OVF file and a VMDK file.  
   - These will be placed into `./output-virtualbox-iso`.  
- Upload the two VM files to S3.  

This assumes...

- [Packer](http://www.packer.io/) is in your path.
- [s3cmd](http://s3tools.org/download) is configured and in your path.


### AWS Integration

The VM files will be uploaded to Cognitect's 'boomstick/images' bucket and will be publicly readable.

Uploading is restricted to the 'boomstick' user, so `s3cmd` must be
configured with the corresponding IAM credentials.

Skip this upload by prepending SKIP_UPLOAD=1 when executing `driver.sh`.


### Next steps

#### Softwares
- TODO: Add mbrainz dataset.
- ~~TODO: CounterClockwise.~~
- ~~TODO: Add IntelliJ + Cursive.~~
- ~~TODO: Add Emacs, Cider, nRepl, Clojure-mode.~~
- ~~TODO: Add vim.~~
- ~~TODO: Add Maven.~~
- ~~TODO: Add Datomic Free.~~

#### Bonus
- TODO: Nightcode
- TODO: Heroku gem installed for quick-and-dirty deploys
- ~~TODO: LightTable~~
- ~~TODO: Datomic auto-starts at boot time, with persistent storage under /var/datomic~~
- ~~TODO: Pretty icons on desktop.~~

#### Meta
- TODO: Document updating binaries.
- TODO: Relativize paths in `driver.sh`.
- TODO: Find way to DRY up username/password repetition.
- TODO: Find real place from which to serve editor binaries.
- TODO: Is there an ubuntu-desktop-minimal package?
- TODO: Is there a better means of configuring Cursive?
- ~~TODO: Desktop editor symlinks not currently visible.~~
- ~~TODO: Fix post-import network connectivity issue?~~
- ~~TODO: Drive this all from CI, triggered by Github commit notice.~~


### Debugging

Prepend `PACKER_LOG=1` to `driver.sh`'s invocation of packer to see Packer debug messages.

Shell scripts have xtrace enabled in order to print each command
executed to the console.

