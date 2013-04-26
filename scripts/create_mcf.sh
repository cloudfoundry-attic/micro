#!/usr/bin/env bash

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables

STEMCELLS_DIR=${STEMCELLS_DIR:-/var/vcap/store/stemcells}
RELEASES_DIR=${REPOS_DIR:-/var/vcap/store/releases}
REPOS_DIR=${REPOS_DIR:-/var/vcap/store/repos}

CF_RELEASE_BRANCH=${CF_RELEASE_BRANCH:-master}
CF_RELEASE_DIR=${CF_RELEASE_DIR:-$RELEASES_DIR/cf-release/$CF_RELEASE_BRANCH}
MICRO_DIR=${MICRO_DIR:-${REPOS_DIR}/micro}
BOSH_DIR=${BOSH_DIR:-${REPOS_DIR}/bosh}

CF_RELEASE_GIT=${CF_RELEASE_GIT:-https://github.com/cloudfoundry/cf-release.git}
MICRO_GIT=${MICRO_GIT:-https://github.com/cloudfoundry/micro.git}
MICRO_BRANCH=${MICRO_BRANCH:-master}
BOSH_GIT=${BOSH_GIT:-https://github.com/cloudfoundry/bosh.git}

UBUNTU_RELEASE=`lsb_release -c -s`
UPGRADE=${UPGRADE:-}

if [[ "$(which ovftool)X" == "X" ]]; then
  echo "Please download ovftool to your local machine, upload to this VM and install; then re-run this script"
  echo "Download link: http://www.vmware.com/support/developer/ovf/"
  exit 1
fi

mkdir -p $STEMCELLS_DIR
mkdir -p $RELEASES_DIR
mkdir -p $REPOS_DIR

# run Ubuntu release specific steps
. ${UBUNTU_RELEASE}.sh

sudo apt-get install --assume-yes \
build-essential \
debootstrap \
kpartx \
libpq-dev \
libssl-dev \
libxml2-dev \
libsqlite3-dev \
libxslt-dev \
zip \
zlib1g-dev

cd ${STEMCELLS_DIR}
if [[ ! -f ${ISO_NAME} ]]; then
  wget http://releases.ubuntu.com/${UBUNTU_RELEASE}/${ISO_NAME}
fi
export UBUNTU_ISO=${STEMCELLS_DIR}/${ISO_NAME}


# Install a gem if $UPGRADE or if gem not yet installed
function install_gem() {
  gem_name=$1
  if [[ ("${UPGRADE}X" != "X") || "$(gem list $gem_name | grep $gem_name)X" == "X" ]]; then
    gem install $gem_name --no-ri --no-rdoc
  else
    echo gem $gem_name already installed
  fi
}

install_gem linecache19
install_gem therubyracer
install_gem bosh_cli
install_gem bundler

$(which rbenv > /dev/null) && rbenv rehash || true

if [[ ! -d ${CF_RELEASE_DIR} ]]; then
  echo "Cloning cf-release repository..."
  git clone -b ${CF_RELEASE_BRANCH} ${CF_RELEASE_GIT} ${CF_RELEASE_DIR}
else
  echo "Updating cf-release repository..."
  cd ${CF_RELEASE_DIR}
  git pull origin ${CF_RELEASE_BRANCH}
fi

echo "Creating cf-release bosh release..."
cd ${CF_RELEASE_DIR}
# Remove when https://github.com/cloudfoundry/cf-release/pull/25 gets merged.
sed -i 's#git@github.com:#https://github.com/#g' .gitmodules
sed -i 's#git://github.com#https://github.com#g' .gitmodules
git submodule foreach --recursive git submodule sync && git submodule update --init --recursive
bosh -n --color create release --force --with-tarball

if [[ ! -d ${MICRO_DIR} ]]; then
  echo "Cloning micro repository..."
  git clone -b ${MICRO_BRANCH} ${MICRO_GIT} ${MICRO_DIR}
else
  echo "Updating micro repository..."
  cd ${MICRO_DIR}
  git pull origin ${MICRO_BRANCH}
fi
cd ${MICRO_DIR}/micro
rm -rf .bundle
bundle install
bundle exec rake assets:precompile

if [[ ! -d ${BOSH_DIR} ]]; then
  echo "Cloning bosh repository..."
  git clone ${BOSH_GIT} ${BOSH_DIR}
else
  echo "Updating bosh repository..."
  cd ${BOSH_DIR}
  git pull origin master
fi
cd ${BOSH_DIR}
rm -rf .bundle
bundle install

CPI=vsphere
MANIFEST=${MANIFEST:-$MICRO_DIR/deploy/manifest.yml}
LATEST_RELEASE=`ls -t ${CF_RELEASE_DIR}/dev_releases/*.tgz | head -1`

bundle exec rake stemcell:mcf[$CPI,$MANIFEST,$LATEST_RELEASE,$MICRO_DIR]
