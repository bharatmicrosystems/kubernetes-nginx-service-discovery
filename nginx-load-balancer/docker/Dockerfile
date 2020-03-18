FROM centos:7

RUN rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
COPY kubernetes.repo /etc/yum.repos.d/
RUN yum install -y kubectl

RUN yum install -y telnet nginx

COPY nginx.conf /etc/nginx/
RUN cat /etc/nginx/nginx.conf

COPY entrypoint.sh /usr/sbin/

RUN chmod +x /usr/sbin/nginx
RUN chmod +x /usr/sbin/entrypoint.sh

RUN mkdir -p /etc/nginx/vhosts
RUN mkdir -p /tmp/ingress

EXPOSE 80 443

ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
#CMD /usr/sbin/nginx -g "daemon off;"
