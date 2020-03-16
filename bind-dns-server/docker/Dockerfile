FROM centos:7
RUN yum install -y bind bind-utils
COPY kubernetes.repo /etc/yum.repos.d/
RUN yum install -y kubectl
COPY entrypoint.sh /tmp/
COPY named.conf.template /tmp/
COPY template-zone /tmp/
COPY rndc.conf /tmp/
RUN chmod +x /tmp/entrypoint.sh 
WORKDIR /tmp
EXPOSE 53/udp 53/tcp 10000/tcp

ENTRYPOINT ["/tmp/entrypoint.sh"]
