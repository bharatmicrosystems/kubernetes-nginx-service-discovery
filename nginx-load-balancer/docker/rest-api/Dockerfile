FROM python:2.7
FROM rmg/centos-jdk:8u131
MAINTAINER Gaurav Agarwal, gaurav.a.agarwal@capgemini.com

COPY server.py /opt/bin/server.py
COPY getResponse.sh /opt/bin/getResponse.sh
COPY entrypoint.sh /opt/bin/entrypoint.sh
RUN chmod +x /opt/bin/getResponse.sh
RUN chmod +x /opt/bin/server.py
RUN chmod +x /opt/bin/entrypoint.sh
# Set working directory
WORKDIR /opt/bin

EXPOSE 8997
CMD ["/opt/bin/entrypoint.sh"]
#
