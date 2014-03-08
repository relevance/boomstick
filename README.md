## Boomstick
![](resources/boom.png)

Boomstick tries to make it easier to explore Clojure and Datomic by generating an Ubuntu image containing a selection of Clojure editors, Datomic, and supporting software.

Editors:
- Emacs (CLI and GUI)  
- Vim (CLI and GUI)  
- LightTable
- CounterClockwise  
- Cursive  

These editors are all pre-configured for editing Clojure.

Software:
- Datomic Free  
- Leiningen  
- Maven  


#### Mission Statement

* Provide a VirtualBox image that anyone can download or
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



## Usage

Run `driver.sh` and STAND BACK.



## Building the Stick

As detailed below, executing `driver.sh` will upload files to install
a VM image to the following URLs. Download these files and copy them
to USB sticks for users to enjoy.

https://s3.amazonaws.com/boomstick/image/importer.sh  
https://s3.amazonaws.com/boomstick/image/boomstick.ovf  
https://s3.amazonaws.com/boomstick/image/boomstick-disk1.vmdk  

It would be nifty to include the mbrainz dataset for later perusal.

http://s3.amazonaws.com/mbrainz/datomic-mbrainz-backup-20130611.tar



## Using the Stick

Users can slot the USB sticks into their Linux or OSX computers,
browse the filesystem and execute the `importer.sh` file.

`importer.sh` will import the provided VM into the local VirtualBox
library. The VM can then be started via the VirtualBox Manager interface.

username/password: dev/dev

Assumptions:

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) is already
  installed on the host computer.  
- VBoxManage is in the PATH.  



## Program Flow

`driver.sh` will...

- Launch packer to build a new Ubuntu VM named 'boomstick'.  
 - Run `ubuntu_64/bootstrap.sh` to finish provisioning the new VM.  
 - The new VM comprises an OVF file and a VMDK file.  
   - These will be placed into `./output-virtualbox-iso`.  
- Upload the VM and the importer script to Cognitect's 'boomstick/images' bucket on S3.  

Binaries are pulled both from apt repositories and from http://boomstick.s3.amazonaws.com/.

Editor configs are fetched from https://github.com/relevance/boomstick-editor-configs.

Assumptions:

- [Packer](http://www.packer.io/) is in your path.
- [s3cmd](http://s3tools.org/download) is configured and in your path.

#### AWS Integration

The VM files will be uploaded to Cognitect's 'boomstick/images' bucket and will be publicly readable.

Uploading is restricted to the 'boomstick' user; `s3cmd` must find
the corresponding IAM credentials at `~/.s3cfg`.

Skip this upload by prepending SKIP_UPLOAD=1 when executing `driver.sh`.



## Making Changes to Boomstick

#### Updating the driver

Make changes to the files in https://github.com/relevance/boomstick
and execute `driver.sh` to update the VM files.

#### Updating the installed software

Ensure `ubuntu_64/bootstrap.sh` has an up-to-date install routine for
the desired software. Software not in apt will
need to be available at http://boomstick.s3.amazonaws.com/.

Then, execute `driver.sh` to update the VM files.

#### Updating the editor configs

Make changes to the files in https://github.com/relevance/boomstick-editor-configs
and execute `driver.sh` to update the VM files.



## Next steps

#### Softwares
- ~~TODO: Add mbrainz dataset.~~
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
- ~~TODO: Document updating binaries.~~
- ~~TODO: Relativize paths in `driver.sh`.~~
- TODO: Find way to DRY up username/password repetition.
- ~~TODO: Find real place from which to serve editor binaries.~~
- ~~TODO: Is there an ubuntu-desktop-minimal package?~~
- TODO: Is there a better means of configuring Cursive?
- ~~TODO: Desktop editor symlinks not currently visible.~~
- ~~TODO: Fix post-import network connectivity issue?~~
- ~~TODO: Drive this all from CI, triggered by Github commit notice.~~



## Debugging the Driver

Prepend `PACKER_LOG=1` to `driver.sh`'s invocation of packer to see Packer debug messages.

Shell scripts have xtrace enabled in order to print each command
executed to the console.



## Jenkins

Using the git plugin, Jenkins can be configured to learn of changes to
a Git repo and then update the VM files.

A webhook can be configured on Github to notify Jenkins when an update
has been made to a repo. The git plugin responds to such a
notification by doing a git fetch against the configured repo, and, if
finding new changes, executing the build.

The Multiple SCMs plugin will trigger a build on an update to either
the boomstick or boomstick-editor-configs repos provided the repos
are configured for notifications as above.

#### Recommended Jenkins Configuration

- Add Git plugin  
- Add Multiple SCMs plugin  
  - Check 'Source Code Management > Multiple SCMs'.  
    - Add repo: https://github.com/relevance/boomstick  
      - Local subdirectory for repo: boomstick  
    - Add repo: https://github.com/relevance/boomstick-editor-configs  
      - Local subdirectory for repo: boomstick-editor-configs  
- Add AnsiColor plugin  
  - Check 'Build Environment > Color ANSI Console Output'.  
    - Under 'ANSI Color Map' choose 'xterm'.  
  - Colorizes output of VirtualBox build.  
- Check 'Build Triggers' > 'Poll SCM'.  
  - Leave 'Schedule' unconfigured.  
  - Allows builds to be triggered via webhook or [manual URL
    request](http://127.0.0.1:8080/git/notifyCommit?url=https://github.com/relevance/boomstick).  
- Add a 'Build > Execute shell > Command' of `boomstick/driver.sh`.  
- Add 'Post-build Actions > E-Mail Notification' pointing to your
  email address.
  
