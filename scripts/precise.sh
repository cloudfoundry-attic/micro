ISO_NAME=${ISO_NAME:-ubuntu-12.04.2-server-amd64.iso}

sudo apt-get install --assume-yes \
apt-cacher

export UBUNTU_MIRROR=http://localhost:3142/archive.ubuntu.com/ubuntu
