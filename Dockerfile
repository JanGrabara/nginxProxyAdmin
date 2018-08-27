FROM valian/docker-nginx-auto-ssl
COPY ./nginx.conf /usr/local/openresty/nginx/conf/
COPY ./lua /lua
COPY ./configs /etc/nginx/conf.d
