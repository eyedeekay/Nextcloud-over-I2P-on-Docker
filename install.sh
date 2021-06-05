#! /usr/bin/env sh


## First, we need to find the I2P Router we will need to restart
## after the install
if [ -z $I2PROUTER ]; then
  I2PROUTER=$(which i2prouter)
fi

if [ -z $I2PROUTER ]; then
  test "$HOME/i2p/i2prouter" && I2PROUTER="$HOME/i2p/i2prouter"
fi

if [ -z $I2PROUTER ]; then
  test "/usr/sbin/i2prouter" && DEBIAN="yes"
fi
## End I2P Router Discovery Phase

## Check the platform, set NEXTCLOUD_CONFIG variable to Linux
## or OSX location
uname -a | grep -i darwin && NEXTCLOUD_CONFIG="$HOME/Library/Preferences/Nextcloud/nextcloud.cfg"
uname -a | grep -i linux && NEXTCLOUD_CONFIG="$HOME/.config/Nextcloud/nextcloud.cfg"
## End platform discovery section

## Check if the I2P proxy is configured by looking for the 
## port number in the NextCloud default configuration. Only
## copy if it's not found.
grep 7671 "$NEXTCLOUD_CONFIG" || cp nextcloud.cfg "$NEXTCLOUD_CONFIG"
## Check if the Nextcloud HTTP Proxy is already set up.
## If it isn't present, copy it over. If it needs to be
## copied, restart the router at the end of the script.
if [ "$DEBIAN" = yes ]; then
  sudo cp Nextcloud-HTTP-Proxy.config /var/lib/i2p/i2p-config/i2ptunnel.config.d/Nextcloud-HTTP-Proxy.config
else
  test "$HOME/.i2p/i2ptunnel.config.d/Nextcloud-HTTP-Proxy.config" || RESTART=yes
  test "$HOME/.i2p/i2ptunnel.config.d/Nextcloud-HTTP-Proxy.config" || cp Nextcloud-HTTP-Proxy.config "$HOME/.i2p/i2ptunnel.config.d/Nextcloud-HTTP-Proxy.config"
fi
## End of Install section.

## If the config file hasn't been copied previously, or if
## proxy.i2p isn't reachable over the proxy, perform a restart.
http_proxy=http://127.0.0.1:7671 curl http://proxy.i2p || RESTART=yes
http_proxy=http://127.0.0.1:7671 curl http://proxy.i2p && RESTART=no

if [ "$RESTART" = "yes" ]; then
  if [ "$DEBIAN" = "yes" ]; then
    sudo service i2p restart
  else
    $I2PROUTER graceful
    sleep 15s
    $I2PROUTER start
  fi
fi
## End restart section
