#!/usr/bin/env python
from __future__ import print_function

import cgi
import urlparse
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from subprocess import Popen, PIPE
import zipfile
import urllib
import json

class S(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def _setup_ingress(self, name, host, server_host, port):
        template_data = """---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: name_value
  annotations:
    nginx.ingress.kubernetes.io/add-base-url: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
  labels:
    backend-host: backend_hosts_value
    backend-port: "backend_port_value"
spec:
  rules:
  - host: host_value
    http:
      paths:
        - path: /
          backend:
            serviceName: nginx-load-balancer
            servicePort: 80
"""
        with open("/opt/bin/ingress/"+name+".yaml", "w+") as file:
            data = file.read()
            if (name not in data) or (host not in data) or (port not in data):
                data = template_data
                data = data.replace("name_value", name)
                data = data.replace('backend_hosts_value', '"'+server_host+'"#backend_hosts_value')
                data = data.replace("host_value", host)
                data = data.replace("backend_port_value", port)
            else:
                if (server_host not in data):
                    data = data.replace('"#backend_hosts_value', ','+server_host+'"#backend_hosts_value')
            try:
                file.write(data)
                file.close()
                file_name = '/opt/bin/ingress/'+name+'.yaml'
                arguments = ['/usr/bin/kubectl','apply', '-f', '%s' % file_name]
                self.wfile.write(arguments)
                p = Popen(arguments, stdin=PIPE, stdout=PIPE, stderr=PIPE, bufsize=-1)
                output, error = p.communicate()
                if p.returncode > 1:
                    self.send_response(550, message='Kubectl apply failure')
                    self.end_headers()
                    self.wfile.write(output)
                    self.wfile.write(error)
            finally:
                file.close()

    def do_POST(self):
        # self._set_headers()
        #ctype, pdict = cgi.parse_header(self.headers.getheader('content-type'))
        data_string = self.rfile.read(int(self.headers['Content-Length']))
        data = json.loads(data_string)
        try:
            for item in data:
                name = item['name']
                host = item['ingress_host']
                server_host = item['server_host']
                port = item['port']
                self._setup_ingress(name, host, server_host, port)
            output = 'OK'
            self.send_response(200)
            self.end_headers()
            self.wfile.write(output)
        except Exception as e:
            self.send_response(500)
            self.wfile.write(e)
def run(server_class=HTTPServer, handler_class=S, port=8997):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print('REST API Started on port %s...' % port)
    httpd.serve_forever()


if __name__ == "__main__":
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
