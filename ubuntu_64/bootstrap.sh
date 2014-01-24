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
sudo apt-get -y install git
sudo apt-get -y install ubuntu-desktop # Something smaller?
sudo apt-get -y install curl
sudo apt-get -y install default-jre


log "Installing lein."
curl -O https://raw.github.com/technomancy/leiningen/stable/bin/lein
sudo mv lein /bin
sudo chmod u+x /bin/lein


# TEST: launch ccw, new clojure project, run > run, as Clojure Application. get REPL?
mkdir -p editors/counterclockwise
cd editors/counterclockwise
log "Installing Counterclockwise."
curl -O $SRV/ccw-0.23.0.STABLE001-linux.gtk.x86_64.zip
unzip ccw-0.23.0.STABLE001-linux.gtk.x86_64.zip
ln -s $(pwd)/Counterclockwise ~/Desktop/
cd ~


