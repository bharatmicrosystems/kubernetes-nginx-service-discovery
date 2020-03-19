#!/bin/bash
/usr/sbin/nginx
while true; do
  kubectl get ingress --show-labels|grep backend-host|awk '{print $1}'| while read line; do
  #Get the ingress host
  ingress_host=$(kubectl get ingress $line | awk '{print $2}'|sed -n 2p)
  echo $ingress_host
  # Get the value of the backend-host
  backend_hosts=$(kubectl get ingress $line -o jsonpath='{.metadata.labels.backend-host}')
  backend_port=$(kubectl get ingress $line -o jsonpath='{.metadata.labels.backend-port}')
  echo $backend_hosts
  echo $backend_port
  flag=false
  if [ -f "/etc/nginx/vhosts/${ingress_host}.conf" ]; then
    echo "Entry for $ingress_host already exists"
    if grep -q ":$backend_port" "/etc/nginx/vhosts/${ingress_host}.conf"; then
      echo "Backend port $backend_port correct" 
      flag=true
    fi
  fi
  if $flag; then
    echo "Ingress file need not be generated"
  else
    cat <<EOF > /etc/nginx/vhosts/${ingress_host}.conf
    server {
        listen     80;
        server_name ingress_host;
        location / {
          proxy_pass http://ingress_host_backend_port;
          proxy_buffering off;
        }
    }
    upstream ingress_host_backend_port {
        # server servername:port;
    }
EOF
    sed -i "s/ingress_host/$ingress_host/g" /etc/nginx/vhosts/${ingress_host}.conf
    sed -i "s/backend_port/$backend_port/g" /etc/nginx/vhosts/${ingress_host}.conf
    sed -i "s/servername/${ingress_host}_servername/g" /etc/nginx/vhosts/${ingress_host}.conf
  fi
  for backend_host in $(echo $backend_hosts | sed "s/,/ /g")
   do
     if grep -q "$backend_host" "/etc/nginx/vhosts/${ingress_host}.conf"; then
       # Do nothing
       echo "Record for $backend_host already exists"
     else
       echo "Creating record for $backend_host"
       sed -i "s/# server ${ingress_host}_servername:port;/server $backend_host:$backend_port;\n        # server ${ingress_host}_servername:port;/g" /etc/nginx/vhosts/${ingress_host}.conf
       nginx -s reload
     fi
   done
done
sleep 10
done
