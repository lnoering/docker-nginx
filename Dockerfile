FROM centos:7

MAINTAINER "Leonardo H. Noering" <lnoering@gmail.com>

ENV NGINX_VERSION=1.11.9 \
	NGINX_USER=nginx \
    NGINX_SITECONF_DIR=/etc/nginx/sites-enabled \
    NGINX_LOG_DIR=/var/log/nginx \
    NGINX_TEMP_DIR=/var/lib/nginx \
    NGINX_SETUP_DIR=/var/cache/nginx

RUN yum update --exclude=iputils -y

RUN yum install centos-release-scl -y
RUN yum install devtoolset-3-gcc-c++ devtoolset-3-binutils -y
RUN yum install wget curl unzip gcc-c++ pcre-devel zlib-devel penssl-devel GeoIP GeoIP-devel openssl-devel.x86_64 -y
RUN yum clean all

RUN yum install -y \
	initscripts \
	make

WORKDIR ${NGINX_SETUP_DIR}

RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -P ${NGINX_SETUP_DIR}
RUN	tar -xzf nginx-${NGINX_VERSION}.tar.gz

WORKDIR ${NGINX_SETUP_DIR}/nginx-${NGINX_VERSION}

RUN ./configure \
--prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--user=nginx \
--group=nginx \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-http_geoip_module \
--with-cc=/opt/rh/devtoolset-3/root/usr/bin/gcc

RUN make
RUN make install

RUN mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig

COPY data/nginx.conf /etc/nginx/nginx.conf
COPY data/nginx /etc/init.d/nginx
COPY data/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
RUN chmod +x /etc/init.d/nginx
RUN PROC=$( grep "model name" /proc/cpuinfo | wc -l)
RUN sed -i -e 's/worker_processes  4;/worker_processes  '"$PROC"';/g' /etc/nginx/nginx.conf

RUN adduser nginx -d /dev/null -s /bin/false
RUN chkconfig --add nginx
RUN chkconfig --level 345 nginx on
RUN chkconfig nginx on

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]