ISO_NAME=${ISO_NAME:-ubuntu-10.04.4-server-amd64.iso}

sudo apt-get install --assume-yes \
apt-proxy \
libxslt-dev

export UBUNTU_MIRROR=http://localhost:9999/ubuntu
