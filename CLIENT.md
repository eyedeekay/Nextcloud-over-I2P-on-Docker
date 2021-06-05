Configuring your NextCloud Client for I2P
=========================================

**This is a guide for configuring NextCloud Desktop to use**
**I2P at all times. It will clear your existing NextCloud**
**settings and pre-configure your client to use I2P.**

This is a guide for configuring Nextcloud Clients. To set up
your own hidden NextCloud server, check out [the setup guide](index.html).

NextCloud Desktop provides convenient options for configuring
an `HTTP` or `SOCKS5` proxy by passing flags at the terminal,
setting it up via the GUI, or by making alterations to a
configuration file. I prefer to make alterations to the
configuration file, so that all the changes are made before I
ever need to run NextCloud, and so that I can keep it conveniently
packaged and configure it on multiple systems, or even redistribute
it to others as the case may be.

TL:DR
=====

On Linux or OSX:

```bash
sudo apt-get install nextcloud-desktop git
git clone https://github.com/eyedeekay/Nextcloud-over-I2P-with-Docker
cd Nextcloud-over-I2P-with-Docker
make install
```

On Windows(WIP):

 - Download: [This file:](https://github.com/eyedeekay/Nextcloud-over-I2P-on-Docker/archive/refs/heads/main.zip)
 - Unzip it
 - Double-click `install.bat`

Locating your Configuration File*
---------------------------------

The Nextcloud Client reads a configuration file. You can locate
this configuration file as follows:

**On Linux distributions:**

```bash
$HOME/.config/Nextcloud/nextcloud.cfg
```

**On Microsoft Windows systems:**

```powershell
%APPDATA%\Nextcloud\nextcloud.cfg
```

**On macOS systems:**

```bash
$HOME/Library/Preferences/Nextcloud/nextcloud.cfg 
```

*Literally copied wholesale from here: [Advanced Usage](https://docs.nextcloud.com/desktop/2.6/advancedusage.html)
because NextCloud Client is very conveniently documented.

Making the Changes
------------------

If you are running your own NextCloud service, it is fine to use
the HTTP Proxy at `127.0.0.1:4444`. Simply add the following lines
to your `nextcloud.cfg` file as follows:

```ini
[Proxy]
host=127.0.0.1
needsAuth=false
port=4444
type=3
user=
```

However, if you are using someone else's NextCloud service, or are
connecting to many NextCloud services at the same time, you may
want to set up an HTTP Proxy just for NextCloud. Follow the [HTTP Proxy Setup Instructions](https://eyedeekay.github.io/HTTP-Proxy-For-Your-Application),
to set up a new HTTP Proxy tunnel, and alter the configuration
above to match your chosen port.

Packaging it?
-------------

That's all fine, but can we do even better? I think so. What we need
to completely pre-configure NextCloud-over-I2P on the client side
are two files. One is the `nextcloud.cfg` file which we've already
discussed, and the other will go into `i2ptunnel.config.d`. We'll make
this all happen automatically. On Linux, we'll use a shell script to
check if the files are already set up and automatically re-start the
I2P router.

```bash
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
```

Since we're only changing configuration files in the user's $HOME,
it will not require root unless I2P is running as a system service.

And an accompanying un-install script.

```sh
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
```

After reviewing the configuration files:

```ini
[Proxy]
host=127.0.0.1
needsAuth=false
port=7671
type=3
user=
```

and

```ini
description=HTTP proxy for using Nexcloud
i2cpHost=127.0.0.1
i2cpPort=7654
interface=127.0.0.1
listenPort=7671
name=I2P HTTP Proxy
option.i2cp.closeIdleTime=1800000
option.i2cp.closeOnIdle=false
option.i2cp.destination.sigType=7
option.i2cp.leaseSetEncType=4,0
option.i2cp.newDestOnResume=false
option.i2cp.reduceIdleTime=900000
option.i2cp.reduceOnIdle=true
option.i2cp.reduceQuantity=1
option.i2p.streaming.connectDelay=1000
option.i2ptunnel.httpclient.SSLOutproxies=false.i2p
option.inbound.backupQuantity=3
option.inbound.length=2
option.inbound.lengthVariance=0
option.inbound.nickname=shared clients
option.inbound.quantity=3
option.outbound.backupQuantity=3
option.outbound.length=2
option.outbound.lengthVariance=0
option.outbound.nickname=shared clients
option.outbound.priority=10
option.outbound.quantity=3
option.persistentClientKey=false
privKeyFile=nextcloud-privKeys.dat
proxyList=false.i2p
sharedClient=false
startOnLoad=true
type=httpclient
```

You can install, very simply, by running the scripts in this
repository, like so:

```bash
sudo apt-get install nextcloud-desktop git
git clone https://github.com/eyedeekay/Nextcloud-over-I2P-with-Docker
cd Nextcloud-over-I2P-with-Docker
make install
```

Voila, automatic NextCloud server configuration which works well on Linux
and OSX.

Windows(WIP)
------------

