# kubernetes-nginx-service-discovery
This project is to support using kubernetes ingress resources to route traffic using nginx to non-kubernetes endpoints

## Pre-Requisites
An ingress controller running within the kubernetes cluster
For more details with regards to setup see https://github.com/kubernetes/ingress-nginx

## Quick Start using Kubernetes Manifests
### Bare Metal setup
```
git clone https://github.com/bharatmicrosystems/kubernetes-nginx-service-discovery.git
sed -i "s/example.com/<COMMA SEPARATED DOMAINS>/g" /etc/resolv.conf
kubectl apply -f kubernetes-nginx-service-discovery/bind-dns-server/dns-server.yaml
kubectl apply -f kubernetes-nginx-service-discovery/nginx-load-balancer/nginx.yaml
```
Run the following on each of your worker nodes (if you want to use /etc/resolv.conf) or make an equivalent entry on the coredns configuration
```
sed -i "1 i\nameserver 127.0.0.1\noptions timeout:1" /etc/resolv.conf
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
+        forward . 127.0.0.1
+    }
```

## Testing the setup
```
kubectl apply -f kubernetes-nginx-service-discovery/nginx-load-balancer/ingress.yaml
curl -v http://nginx.example.com
```
