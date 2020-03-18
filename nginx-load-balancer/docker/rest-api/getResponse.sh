#!/bin/sh
name=$1
echo $name
cat /opt/bin/ingress/$name.yaml
kubectl apply -f /opt/bin/ingress/$name.yaml
#
