# kubernetes-nginx-service-discovery
This project is to support using kubernetes ingress resources to route traffic using nginx to non-kubernetes endpoints
![Kubernetes Design](readme.png)
## Pre-Requisites
An ingress controller running within the kubernetes cluster
For more details with regards to setup see https://github.com/kubernetes/ingress-nginx

An example setup is present in the repo. This exposes the Nginx Ingress controller via a node port, and an NGINX Load Balancer sits in front of the NodePort to provide a single load balanced endpoint to the setup. It also exposes the DNS server as a NodePort and NGINX Load Balancer described in the nginx.conf file caters to the DNS configuration as well.

If you are using a cloud provided kubernetes setup and can expose the ingress-controller and dns-server as a load balancer service instead of a NodePort service as descried. 

In any situation you should arrive with a DNS Server Load Balanacer IP and an Ingress Controller Load Balancer IP.

If you want to use the example setup do the following
```
git clone https://github.com/bharatmicrosystems/kubernetes-nginx-service-discovery.git
kubectl apply -f kubernetes-nginx-service-discovery/ingress/mandatory.yaml
kubectl apply -f kubernetes-nginx-service-discovery/ingress/service-nodeport.yaml
```

You would then need to spin up a new instance of a VM where you need to install nginx and copy the nginx.conf file to /etc/nginx/nginx.conf. The nginx.conf file assumes that you have a three node cluster with node01, node02, and node03 as the host names for the worker nodes, you need to modify the nginx.conf file according to your setup.

Steps for installing NGINX is present on https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/

## Quick Start using Kubernetes Manifests
```
git clone https://github.com/bharatmicrosystems/kubernetes-nginx-service-discovery.git
sed -i "s/example.com/<YOUR DOMAIN>/g" kubernetes-nginx-service-discovery/bind-dns-server/dns-server.yaml
sed -i "s/dns_loadbalancer_ip_value/<YOUR DNS LOAD BALANCER IP>/g" kubernetes-nginx-service-discovery/bind-dns-server/dns-server.yaml
sed -i "s/ingress_loadbalancer_ip_value/<YOUR INGRESS LOAD BALANCER IP>/g" kubernetes-nginx-service-discovery/bind-dns-server/dns-server.yaml
kubectl apply -f kubernetes-nginx-service-discovery/bind-dns-server/dns-server.yaml
kubectl apply -f kubernetes-nginx-service-discovery/nginx-load-balancer/nginx.yaml
```
Run the following on each of your worker nodes (if you want to use /etc/resolv.conf) or make an equivalent entry on the coredns configuration
```
sed -i "1 i\nameserver <YOUR DNS LOAD BALANCER IP>\noptions timeout:1" /etc/resolv.conf
```
CoreDNS configuration (if not modifying /etc/resolv.conf
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . 172.16.0.1
        cache 30
        loop
        reload
        loadbalance
    }
+    <YOUR DOMAIN HERE>:53 {
+        errors
+        cache 30
+        forward . <YOUR DNS LOAD BALANCER IP>
+    }
```

## Testing the setup
```
sed -i "s/example.com/<YOUR DOMAIN>/g" kubernetes-nginx-service-discovery/nginx-load-balancer/ingress.yaml
kubectl apply -f kubernetes-nginx-service-discovery/nginx-load-balancer/ingress.yaml
curl -v http://nginx.<YOUR DOMAIN>
```
