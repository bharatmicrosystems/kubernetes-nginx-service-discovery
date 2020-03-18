#!/bin/sh
name=$1
echo $name
kubectl apply -f /opt/bin/ingress/$name.yaml
#
