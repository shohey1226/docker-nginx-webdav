FROM ubuntu:18.04

ENV NGINX_VERSION 1.15.5
ENV OPENSSL_VERSION 1.1.1
ENV PCRE_VERSION 8.41
ENV ZLIB_VERSION 1.2.11

RUN apt-get update && \
    apt-get install -y make g++ wget libssl-dev libxslt-dev libgd-dev libgeoip-dev libpam-dev openssl apache2-utils && \
    cd /opt && \
    wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    tar xfz nginx-$NGINX_VERSION.tar.gz && \
    wget https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz && \
    tar xfz openssl-$OPENSSL_VERSION.tar.gz && \
    wget http://zlib.net/zlib-$ZLIB_VERSION.tar.gz && \
    tar xfz zlib-$ZLIB_VERSION.tar.gz && \
    wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$PCRE_VERSION.tar.bz2 && \
    tar xfj pcre-$PCRE_VERSION.tar.bz2 

RUN cd /opt && \ 
    wget https://github.com/arut/nginx-dav-ext-module/archive/v3.0.0.tar.gz && \
    tar xfz v3.0.0.tar.gz 
RUN cd /opt/nginx-$NGINX_VERSION && \
   	 ./configure --with-http_v2_module \
	--conf-path=/etc/nginx/nginx.conf \
	--with-zlib=../zlib-$ZLIB_VERSION \
	--with-pcre=../pcre-$PCRE_VERSION \
	--with-openssl=../openssl-$OPENSSL_VERSION \
	--with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' \
	--with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro' \
	--prefix=/usr/local/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--sbin-path=/sbin/nginx \
	--http-log-path=/var/log/nginx/access.log \
	--error-log-path=/var/log/nginx/error.log \
	--lock-path=/var/lock/nginx.lock \
	--pid-path=/run/nginx.pid \
	--with-debug \
	--with-pcre-jit \
	--with-ipv6 \
	--with-http_ssl_module \
	--with-http_stub_status_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_dav_module \
	--with-http_geoip_module \
	--with-http_gzip_static_module \
	--with-http_image_filter_module \
	--with-http_sub_module \
	--with-http_xslt_module \
	--with-mail \
	--with-mail_ssl_module \
	--add-module=../nginx-dav-ext-module-3.0.0  && \
    make && \
    make install 

#RUN apt-get update && apt-get install -y nginx nginx-extras apache2-utils openssl


VOLUME /etc/letsencrypt
EXPOSE 443
COPY webdav.conf /etc/nginx/conf.d/default.conf
#RUN rm /etc/nginx/sites-enabled/*
RUN useradd ubuntu
COPY nginx.conf /etc/nginx/nginx.conf
RUN openssl dhparam -out /etc/ssl/certs/dhparam.pem 1024 

COPY entrypoint.sh /
RUN chmod +x entrypoint.sh
CMD /entrypoint.sh && nginx -g "daemon off;"
