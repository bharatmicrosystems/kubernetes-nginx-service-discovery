# kubernetes-nginx-service-discovery
This project is to support using kubernetes ingress resources to route traffic using nginx to non-kubernetes endpoints

## Pre-Requisites
An ingress controller running within the kubernetes cluster
For more details with regards to setup see https://github.com/kubernetes/ingress-nginx

## Quick Start using Kubernetes Manifests
```
git clone https://github.com/bharatmicrosystems/kubernetes-nginx-service-discovery.git
kubectl apply -f kubernetes-nginx-service-discovery/bind-dns-server/dns-server.yaml
kubectl apply -f kubernetes-nginx-service-discovery/nginx-load-balancer/nginx.yaml
```
## Testing the setup
```
kubectl apply -f kubernetes-nginx-service-discovery/nginx-load-balancer/ingress.yaml
curl -v http://nginx.example.com
```
