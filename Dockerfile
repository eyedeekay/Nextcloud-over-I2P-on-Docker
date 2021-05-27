FROM nextcloud
ENV http_proxy=http://172.17.0.1:4448
# COPY proxy.ini /usr/local/etc/php/conf.d/
COPY proxy.php /usr/src/nextcloud/config/proxy.config.php
# to test: http_proxy=http://172.17.0.1:4448 curl http://zzz.i2p