#!/usr/bin/env bash

set -o errexit
set -x

# Docker desktop after 31259 refuses to install using root
DOCKER_URL=https://download.docker.com/mac/stable/31259/Docker.dmg
curl -O -sSL $DOCKER_URL
open -W Docker.dmg && cp -r /Volumes/Docker/Docker.app /Applications

export HOMEBREW_NO_AUTO_UPDATE=1

# Get docker in first so we can install it and work on other things
brew cask install ngrok

sudo /Applications/Docker.app/Contents/MacOS/Docker --quit-after-install --unattended
nohup /Applications/Docker.app/Contents/MacOS/Docker --unattended &

brew tap drud/ddev
brew unlink python@2 || true

brew install mysql-client zip makensis jq expect coreutils golang ddev mkcert osslsigncode ghr gnu-getopt
brew link mysql-client zip makensis jq expect coreutils golang ddev mkcert osslsigncode ghr gnu-getopt

brew link --force mysql-client
# These links are required for osslsigncode to work
brew link libgsf glib pcre

# Get the Plugins for NSIS
curl -fsSL -o /tmp/EnVar-Plugin.zip https://github.com/GsNSIS/EnVar/releases/latest/download/EnVar-Plugin.zip && sudo unzip -o -d /usr/local/share/nsis /tmp/EnVar-Plugin.zip
curl -fsSL -o /tmp/INetC.zip https://github.com/DigitalMediaServer/NSIS-INetC-plugin/releases/latest/download/INetC.zip && sudo unzip -o -d /usr/local/share/nsis/Plugins /tmp/INetC.zip

# homebrew sometimes removes /usr/local/etc/my.cnf.d
mkdir -p /usr/local/etc/my.cnf.d

mkcert -install

pip3 install yq

curl -fsSL -o /tmp/gotestsum.tgz https://github.com/gotestyourself/gotestsum/releases/download/v0.3.2/gotestsum_0.3.2_darwin_amd64.tar.gz && tar -C /usr/local/bin -zxf /tmp/gotestsum.tgz gotestsum

# gotestsum
GOTESTSUM_VERSION=0.3.2
curl -fsSL -o /tmp/gotestsum.tgz https://github.com/gotestyourself/gotestsum/releases/download/v${GOTESTSUM_VERSION}/gotestsum_${GOTESTSUM_VERSION}_darwin_amd64.tar.gz && tar -C /usr/local/bin -zxf /tmp/gotestsum.tgz gotestsum

sudo bash -c "cat <<EOF >/etc/exports
${HOME} -alldirs -mapall=$(id -u):$(id -g) localhost
/private/var -alldirs -mapall=$(id -u):$(id -g) localhost
EOF"

LINE="nfs.server.mount.require_resv_port = 0"
FILE=/etc/nfs.conf
grep -qF -- "$LINE" "$FILE" || ( sudo echo "$LINE" | sudo tee -a $FILE > /dev/null )

sudo nfsd enable && sudo nfsd restart

timeout -v 10m bash -c 'while ! docker ps 2>/dev/null ; do
  sleep 5
  echo "Waiting for docker to come up: $(date)"
done'
