
index:
	@echo "<!DOCTYPE html>" > index.html
	@echo "<html>" >> index.html
	@echo "<head>" >> index.html
	@echo "  <title>NextCloud over I2P using Docker</title>" >> index.html
	@echo "  <link rel=\"stylesheet\" type=\"text/css\" href =\"home.css\" />" >> index.html
	@echo "</head>" >> index.html
	@echo "<body>" >> index.html
	markdown README.md | tee -a index.html
	@echo "</body>" >> index.html
	@echo "</html>" >> index.html

auto:
	docker build -t nextcloud-i2p .
	docker rm -f nextcloud-i2p; true
	docker run -d --restart=always \
	    -p 127.0.0.1:8080:80 \
	    -v nextcloud:/var/www/html \
	    --env-file .env \
	    --name nextcloud-i2p nextcloud-i2p