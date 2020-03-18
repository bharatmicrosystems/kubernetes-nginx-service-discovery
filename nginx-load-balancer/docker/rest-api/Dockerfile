FROM python:2.7
MAINTAINER Gaurav Agarwal

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.4/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/bin/kubectl

COPY server.py /opt/bin/server.py
COPY entrypoint.sh /opt/bin/entrypoint.sh
RUN chmod +x /opt/bin/server.py
RUN chmod +x /opt/bin/entrypoint.sh
RUN mkdir -p /opt/bin/ingress
# Set working directory
WORKDIR /opt/bin

EXPOSE 8997
CMD ["/opt/bin/entrypoint.sh"]
#
