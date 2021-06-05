#! /usr/bin/env sh

## We only need to know if we're on Debian to uninstall
if [ -z $I2PROUTER ]; then
  test "/usr/sbin/i2prouter" && DEBIAN="yes"
fi
## End of router discovery section

## Discover the platform, set NEXTCLOUD_CONFIG
uname -a | grep -i darwin && NEXTCLOUD_CONFIG="$HOME/Library/Preferences/Nextcloud/nextcloud.cfg"
uname -a | grep -i linux && NEXTCLOUD_CONFIG="$HOME/.config/Nextcloud/nextcloud.cfg"
## End of platform discovery section

## Remove the files
if [ $DEBIAN = "yes" ]; then
  sudo rm -f "$NEXTCLOUD_CONFIG"
  sudo rm -f "/var/lib/i2p/i2p-config/i2ptunnel.config.d/Nextcloud-HTTP-Proxy.config"
else
  rm -f "$NEXTCLOUD_CONFIG"
  rm -f "$HOME/.i2p/i2ptunnel.config.d/Nextcloud-HTTP-Proxy.config"
fi
## end of uninstall section.
