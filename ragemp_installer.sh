#!/bin/bash
ARCHIVENAME="ragemp.tar.gz"
INSTALLDIR="/opt/ragempServer"
ARCHIVEPATH=$INSTALLDIR/$ARCHIVENAME
echo "Installing Required Packages..."
echo 'deb http://httpredir.debian.org/debian testing main contrib non-free' > /etc/apt/sources.list.d/ragemp.list
apt-get update
apt-get install -y -t testing gcc wget curl software-properties-common gnupg libunwind8 icu-devtools curl libssl-dev
echo "Installing Nodejs and NPM"
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt-get install -y nodejs
echo "Creating Directories"
mkdir -p $INSTALLDIR
echo "Downloading Server Package"
wget -qO $ARCHIVEPATH "https://cdn.rage.mp/lin/ragemp-srv.tar.gz"
if [ -f $ARCHIVEPATH ]; then
  echo "Extracting"
  tar -xzf $ARCHIVEPATH -C $INSTALLDIR --strip-components=1
  echo "Setting Permissions on ServerFile"
  chmod +x "$INSTALLDIR/server"
  echo "Installing C# Bridge"
  wget -qO $INSTALLDIR/csharpbridge.tar.gz http://cdn.gtanet.work/bridge-package-linux.tar.gz
  tar -xzf $INSTALLDIR/csharpbridge.tar.gz -C $INSTALLDIR
  echo "Removing Downloaded Files"
  rm $ARCHIVEPATH
  rm $ARCHIVEPATH/csharpbridge.tar.gz
  echo "Done!"
else
  echo "Could not Download! Please try again!"
fi
