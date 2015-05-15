FROM centos:latest
MAINTAINER wangxiaomo <wxm4ever+docker@gmail.com>

RUN yum update -y
RUN yum install -y gcc glibc glibc-common gd gd-devel xinetd openssl openssl-devel tar make perl vim
RUN useradd -s /sbin/nologin nagios
RUN mkdir /usr/local/nagios
RUN chown -R nagios.nagios /usr/local/nagios

RUN mkdir /source

ADD packages/nagios-cn-3.2.3.tar.bz2 /source
WORKDIR /source/nagios-cn-3.2.3
RUN ./configure --prefix=/usr/local/nagios
RUN make all
RUN make install
RUN make install-init
RUN make install-commandmode
RUN make install-config

ADD packages/nagios-plugins-2.0.3.tar.gz /source
WORKDIR /source/nagios-plugins-2.0.3
RUN ./configure --prefix=/usr/local/nagios
RUN make && make install

ADD conf/nagios/cgi.cfg /usr/local/nagios/etc/cgi.cfg
ADD conf/nagios/nagios.cfg /usr/local/nagios/etc/nagios.cfg
ADD conf/nagios/objects /usr/local/nagios/etc/objects
ADD conf/nagios/servers /usr/local/nagios/etc/servers

ADD packages/httpd-2.4.10.tar.gz /source
WORKDIR /source/httpd-2.4.10
RUN yum install -y apr-util-devel apr apr-docs apr-devel apr-util
RUN ./configure --prefix=/usr/local/apache2
RUN make && make install

ADD packages/php-5.5.15.tar.gz /source
WORKDIR /source/php-5.5.15
RUN yum install -y libxml2-devel
RUN ./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache2/bin/apxs --disable-fileinfo
RUN make && make install

RUN yum install -y net-tools httpd-tools
RUN htpasswd -b -c /usr/local/nagios/etc/htpasswd admin 890821
ADD conf/httpd.conf /usr/local/apache2/conf/httpd.conf

ADD packages/nrpe-2.13.tar.gz /source
WORKDIR /source/nrpe-2.13
RUN ./configure
RUN make all
RUN make install-plugin

RUN yum install -y python-setuptools
RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor
ADD conf/supervisord.conf /etc/supervisord.conf

EXPOSE 80
CMD ["/usr/bin/supervisord"]
