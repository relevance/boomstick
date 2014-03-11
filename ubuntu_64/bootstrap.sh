#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o pipefail
set -o nounset


SERVER=${SERVER:-https://s3.amazonaws.com/boomstick}

LEIN_URL=https://raw.github.com/technomancy/leiningen/stable/bin/lein

LIGHTTABLE_ARCHIVE=LightTableLinux64.tar.gz
LIGHTTABLE_URL=$SERVER/$LIGHTTABLE_ARCHIVE

COUNTERCLOCKWISE_ARCHIVE=ccw-0.23.0.STABLE001-linux.gtk.x86_64.zip
COUNTERCLOCKWISE_URL=$SERVER/$COUNTERCLOCKWISE_ARCHIVE

IDEA_ARCHIVE=ideaIC-133.818.tar.gz
IDEA_URL=$SERVER/$IDEA_ARCHIVE

CURSIVE_ARCHIVE=cursive-13-0.1.16.zip
CURSIVE_URL=$SERVER/$CURSIVE_ARCHIVE

DATOMIC_VERSION="datomic-free-0.9.4578"
DATOMIC_ARCHIVE=$DATOMIC_VERSION.zip
DATOMIC_URL=$SERVER/$DATOMIC_ARCHIVE
DATOMIC_RUN_DIR="/home/dev/$DATOMIC_VERSION"
DATOMIC_LOG_DIR="$DATOMIC_RUN_DIR/log"
DATOMIC_DATA_DIR="/var/datomic"


# Wait for SSH.
sleep 30


elapsed_summary=("Time spent on actions...")
previous_job=
log() {
  set +o xtrace
  echo; echo; echo "** $1"; echo; echo;

  # Store a running summary of elapsed times for each job.
  if [ -n "$previous_job" ]; then
    # Store time delta from last invocation.
    delta=$(($SECONDS-$last_start))
    h=$(($delta/3600))
    m=$(($delta%3600/60))
    s=$(($delta%60))
    previous_job_text="$(printf "%02d:%02d:%02d %s" $h $m $s "$previous_job")"
    elapsed_summary=("${elapsed_summary[@]}" "$previous_job_text")
  fi

  previous_job="$1"
  last_start=$SECONDS
  set -o xtrace
}

cleanup() {
  log "Boomstick bootstrap finished with exit code $?."

  set +o xtrace  # Prevent confusing double output.
  printf "\n\n\n"
  for item in "${elapsed_summary[@]}"; do
    printf "%s\n" "$item";
  done
  printf "\n\n\n"

  # Make VirtualBox wait for our printfs to finish.
  # Why is this necessary?
  sleep 10
}

trap cleanup EXIT


shortcut_text() {
cat <<-EOF
[Desktop Entry]
Version=1.0
Name=$1
Exec=$2
Icon=$3
Terminal=false
Type=Application
EOF
}

make_desktop_shortcut() {
  SHORTCUT=~/Desktop/$1.desktop
  shortcut_text $1 $2 $3 > $SHORTCUT
  chmod 755 $SHORTCUT
}


log "Installing apt-get packages."
sudo apt-get update

sudo apt-get -y install git
sudo apt-get -y install ubuntu-desktop # Something smaller?
sudo apt-get -y install curl
sudo apt-get -y install default-jre
sudo apt-get -y install openjdk-7-jdk
sudo apt-get -y install maven

# Support GuestAdditions in case of post-install kernel upgrade.
sudo apt-get -y install dkms

log "Installing lein."
curl -O $LEIN_URL
sudo mv lein /bin
sudo chmod 755 /bin/lein

log "Triggering lein self-install."
lein --help

log "Triggering up-front caching of Clojure and related jars."
lein new foo
cd foo
lein deps
cd ~
rm -rf foo

log "Cloning editor configs."
git clone https://github.com/relevance/boomstick-editor-configs.git editor_configs
cd editor_configs
log "Updating editor-config submodules."
git submodule init
git submodule update
cd ~


mkdir ~/Desktop/


# Test: lein new foo; emacs foo project.clj
# M-x cider-jack-in
# (+ 1 1)
log "Installing Emacs."
sudo add-apt-repository -y ppa:cassou/emacs
sudo apt-get update
sudo apt-get -y install emacs24
ln -s ~/editor_configs/emacs ~/.emacs.d
cp /usr/share/applications/emacs24.desktop ~/Desktop/
chmod 755 ~/Desktop/emacs24.desktop
cd ~

log "Triggering package install for Emacs."
emacs --kill

# TEST: lein new foo; cd foo; lein repl;
# vim foo/project.clj, :Connect, localhost:<REPL-PORT>, cqc, (+ 1 1)
log "Installing vim."
sudo apt-get install -y vim vim-gnome
ln -s ~/editor_configs/vim/.vimrc ~/.vimrc
make_desktop_shortcut gvim $(which gvim) /usr/share/pixmaps/vim-32.xpm
vim +BundleInstall +qall

# TEST: Launch LightTable. ctrl+space to open the Commands item.
# Into the input box, type 'repl' and choose 'Instarepl: Open a Clojure
# Instarepl'. Into that Instarepl, type (+ 1 1) and wait for deps.
log "Installing LightTable."
mkdir -p editors
cd editors
curl -O $LIGHTTABLE_URL
tar xzvf $LIGHTTABLE_ARCHIVE
make_desktop_shortcut LightTable \
                      $(pwd)/LightTable/LightTable \
                      $(pwd)/LightTable/core/img/lticon.png
cd ~

# TEST:launch ccw, choose 'New Clojure project', give it a name.
# In the Package Explorer, drill into the new project and
# select project.clj. Click 'Run > Run' and select as
# Clojure Application. Eval (+ 1 1) in REPL.
log "Installing Counterclockwise."
mkdir -p editors/counterclockwise
cd editors/counterclockwise
curl -O $COUNTERCLOCKWISE_URL
unzip -q $COUNTERCLOCKWISE_ARCHIVE
make_desktop_shortcut CounterClockwise \
                      $(pwd)/Counterclockwise \
                      $(pwd)/icon.xpm
cd ~

# TEST: lein new foo; Launch Cursive and select 'Import Project'.
# Should have "Leiningen project" as dialog text at top. Navigate to
# 'foo' project directory and hit OK. Accept defaults on all dialogs;
# SDK should be filled in already. Wait for indexing to finish; click
# Run > Edit Configurations, click left-hand +,
# choose 'Clojure REPL > Local', accept defaults.
# Click green Play triangle at upper-right-hand corner.
# Should launch a REPL that can evaluate (+ 1 1)
log "Installing Cursive."
mkdir -p editors
cd editors
curl -O $IDEA_URL
tar xzvf $IDEA_ARCHIVE
mv idea-IC-133.818 cursive

CURSIVE_WRAPPER=$(pwd)/cursive/cursive.sh
cat > $CURSIVE_WRAPPER <<EOF
#!/bin/bash
JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64 $(pwd)/cursive/bin/idea.sh
EOF
chmod 755 $CURSIVE_WRAPPER
make_desktop_shortcut Cursive \
                      $CURSIVE_WRAPPER \
                      $(pwd)/cursive/bin/idea.png

curl -O $CURSIVE_URL
ln -s ~/editor_configs/cursive ~/.IdeaIC13
mkdir -p ~/.IdeaIC13/config/plugins
unzip $CURSIVE_ARCHIVE -d ~/.IdeaIC13/config/plugins
cd ~

log "Installing Datomic Free."
mkdir tmp
cd tmp
curl -O $DATOMIC_URL
unzip -q $DATOMIC_ARCHIVE -d ~/
cd $DATOMIC_RUN_DIR
bin/maven-install
cd ~
rm -rf tmp

log "Configuring Datomic service."
ORIG_DATOMIC_TRANSACTOR_PROPERTIES_FILE=$DATOMIC_RUN_DIR/config/samples/free-transactor-template.properties
CUSTOM_DATOMIC_TRANSACTOR_PROPERTIES_FILE=$DATOMIC_RUN_DIR/transactor.conf

sed '/^data-dir=/d' "$ORIG_DATOMIC_TRANSACTOR_PROPERTIES_FILE" > "$CUSTOM_DATOMIC_TRANSACTOR_PROPERTIES_FILE"
echo "data-dir=${DATOMIC_DATA_DIR}" >> "$CUSTOM_DATOMIC_TRANSACTOR_PROPERTIES_FILE"

# No quotes around 'EOF' hereword to expand the 'env' variables.
# Backslash escapes in front of 'exec' variables so they do not expand.
sudo bash -c "cat > /etc/init/datomic.conf" <<EOF
env RUN_USER="root"
env RUN_DIR="$DATOMIC_RUN_DIR"
env RUN_CMD="$DATOMIC_RUN_DIR/bin/transactor $CUSTOM_DATOMIC_TRANSACTOR_PROPERTIES_FILE"
env RUN_LOG="$DATOMIC_LOG_DIR"

description "datomic transactor"

start on filesystem or runlevel [2345]
stop on runlevel [!2345]

start on (started network-interface
or started network-manager
or started networking)

stop on (stopping network-interface
or stopping network-manager
or stopping networking)

# Keep the process alive, limit to 5 restarts in 60s
respawn
respawn limit 5 60

script
    exec sudo -u \${RUN_USER} sh -c "\${RUN_CMD} >> \${RUN_LOG} 2>&1"
end script
EOF

log "Correcting permissions in ~dev"
sudo chown -R dev ~dev
sudo chgrp -R dev ~dev


log "Installing Guest Additions."
mount -o loop ~/VBoxGuestAdditions.iso /mnt
# Script exits with non-zero code even when successful.
/mnt/VBoxLinuxAdditions.run || true
umount /mnt

log "Removing default net rules."
rm /etc/udev/rules.d/70-persistent-net.rules
