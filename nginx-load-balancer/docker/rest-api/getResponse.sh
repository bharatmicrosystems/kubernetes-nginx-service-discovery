#!/bin/sh
name=$1
kubectl apply -f /opt/bin/ingress/$name.yaml
#
