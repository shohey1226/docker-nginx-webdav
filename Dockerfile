FROM ubuntu:18.04

RUN apt-get update && apt-get install -y nginx nginx-extras apache2-utils openssl

VOLUME /etc/letsencrypt
EXPOSE 443
COPY webdav.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/*
RUN sed -i 's/www-data/ubuntu/g' /etc/nginx/nginx.conf
RUN openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

COPY entrypoint.sh /
RUN chmod +x entrypoint.sh
CMD /entrypoint.sh && nginx -g "daemon off;"
