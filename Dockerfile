FROM nextcloud
ENV http_proxy=http://127.0.0.1:4448
COPY proxy.ini /usr/local/etc/php/conf.d/
COPY proxy.php /usr/src/nextcloud/config/proxy.php
