#=========================================================================#
# Default Web Domain Template                                             #
# DO NOT MODIFY THIS FILE! CHANGES WILL BE LOST WHEN REBUILDING DOMAINS   #
# https://docs.hestiacp.com/admin_docs/web.html#how-do-web-templates-work #
#=========================================================================#

server {
	listen      %ip%:%web_port%;
	server_name %domain_idn% %alias_idn%;
	root        %docroot%;
	index       index.php index.html index.htm;
	access_log  /var/log/nginx/domains/%domain%.log combined;
	access_log  /var/log/nginx/domains/%domain%.bytes bytes;
	error_log   /var/log/nginx/domains/%domain%.error.log error;

	ssl_certificate      %ssl_pem%;
	ssl_certificate_key  %ssl_key%;
	ssl_stapling on;
	ssl_stapling_verify on;

	include %home%/%user%/conf/web/%domain%/nginx.forcessl.conf*;

	# Pass requests that don't refer directly to files in the filesystem to index.php
	location / {
	  try_files $uri $uri/ /index.php?$query_string;
	}

	location ~ \.php$ {
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		try_files $uri =404;
		fastcgi_pass %backend_lsnr%;
		fastcgi_index index.php;
		include /etc/nginx/fastcgi_params;
		include %home%/%user%/conf/web/%domain%/nginx.fastcgi_cache.conf*;
	}

	#Uncomment the following lines if you are not using a `public` directory
	#to prevent sensitive resources from being exposed.
	location ~* ^/(\.git|composer\.(json|lock)|auth\.json|config\.php|flarum|storage|vendor) {
	   deny all;
	   return 404;
	}

	# The following directives are based on best practices from H5BP Nginx Server Configs
	# https://github.com/h5bp/server-configs-nginx

	# Expire rules for static content
	location ~* \.(?:manifest|appcache|html?|xml|json)$ {
	  add_header Cache-Control "max-age=0";
	}

	location ~* \.(?:rss|atom)$ {
	  add_header Cache-Control "max-age=3600";
	}

	location ~* \.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|mp4|ogg|ogv|webm|htc)$ {
	  add_header Cache-Control "max-age=2592000";
	  access_log off;
	}

	location ~* \.(?:css|js)$ {
	  add_header Cache-Control "max-age=31536000";
	  access_log off;
	}

	location ~* \.(?:ttf|ttc|otf|eot|woff|woff2)$ {
	  add_header Cache-Control "max-age=2592000";
	  access_log off;
	}

	# Gzip compression
	gzip on;
	gzip_comp_level 5;
	gzip_min_length 256;
	gzip_proxied any;
	gzip_vary on;
	gzip_types
		application/atom+xml
		application/javascript
		application/json
		application/ld+json
		application/manifest+json
		application/rss+xml
		application/vnd.geo+json
		application/vnd.ms-fontobject
		application/x-font-ttf
		application/x-web-app-manifest+json
		application/xhtml+xml
		application/xml
		font/opentype
		image/bmp
		image/svg+xml
		image/x-icon
		text/cache-manifest
		text/css
		text/javascript
		text/plain
		text/vcard
		text/vnd.rim.location.xloc
		text/vtt
		text/x-component
		text/x-cross-domain-policy;

	location /error/ {
		alias   %home%/%user%/web/%domain%/document_errors/;
	}

	location /vstats/ {
		alias   %home%/%user%/web/%domain%/stats/;
		include %home%/%user%/web/%domain%/stats/auth.conf*;
	}

	include     /etc/nginx/conf.d/phpmyadmin.inc*;
	include     /etc/nginx/conf.d/phppgadmin.inc*;
	include     %home%/%user%/conf/web/%domain%/nginx.conf_*;
}
