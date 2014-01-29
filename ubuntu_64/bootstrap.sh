# Wait for SSH.
sleep 30


# Automate. How do we want to store these binaries?
# S3? Will downloading them all make builds take a long time?
# For now, cd srv && python -m SimpleHTTPServer
SRV=http://10.0.1.13:8000


log() {
  echo; echo; echo "** $1"; echo; echo;
}


sudo apt-get update
sudo apt-get dist-upgrade

sudo apt-get -y install git
sudo apt-get -y install ubuntu-desktop # Something smaller?
sudo apt-get -y install curl
sudo apt-get -y install default-jre
sudo apt-get -y install maven
# Support GuestAdditions in case of post-install kernel upgrade.
sudo apt-get -y install dkms


log "Installing lein."
curl -O https://raw.github.com/technomancy/leiningen/stable/bin/lein
sudo mv lein /bin
sudo chmod u+x /bin/lein


mkdir ~/Desktop/
sudo chown dev ~/Desktop
sudo chgrp dev ~/Desktop


# TEST: launch ccw, new clojure project, run > run, as Clojure Application. get REPL?
log "Installing Counterclockwise."
mkdir -p editors/counterclockwise
cd editors/counterclockwise
curl -O $SRV/ccw-0.23.0.STABLE001-linux.gtk.x86_64.zip
unzip ccw-0.23.0.STABLE001-linux.gtk.x86_64.zip
ln -s $(pwd)/Counterclockwise ~/Desktop/
cd ~


log "Installing Datomic Free."
DATOMIC_VERSION="datomic-free-0.9.4470"
DATOMIC_RUN_DIR="/home/dev/$DATOMIC_VERSION"
mkdir tmp
cd tmp
curl -L -O $SRV/$DATOMIC_VERSION.zip
unzip $DATOMIC_VERSION.zip -d ~/
cd $DATOMIC_RUN_DIR
bin/maven-install
cd ~
rm -rf tmp


log "Configuring Datompic service."
DATOMIC_LOG_DIR="$DATOMIC_RUN_DIR/log"
DATOMIC_DATA_DIR="/var/datomic"
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


log "Installing Guest Additions."
mount -o loop ~/VBoxGuestAdditions.iso /mnt
/mnt/VBoxLinuxAdditions.run
umount /mnt


log "Removing default net rules."
rm /etc/udev/rules.d/70-persistent-net.rules
