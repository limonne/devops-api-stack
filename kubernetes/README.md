### Kubernetes

This section will contain all kubernetes infraestructure for this project.

## Structure

Inside the Kubernetes folder you can find Namespace, Deployments, Services and Docs

## How to execute

```
kubectl apply -f namespaces/
kubectl apply -f deployments/
kubectl apply -f services/
kubectl apply -f gateway/
kubectl apply -f ingress/
kubectl apply -f networkpolicy/
kubectl apply -f persistentvolume/
kubectl apply -f persistentvolumeclaim/
kubectl apply -f routes/
kubectl apply -f statefulsets/
kubectl apply -f storageclass/
kubectl apply -f volumes/
```

## Kubernetes Networking

- ClusterIP Services
- NodePort Services
- CoreDNS
- Ingress NGINX
- Gateway API
- Gateway Controller
- HTTPRoute
- Network Policies

## Kubernetes Storage

- Persistent Volume
- Persistent Volume Claim
- Storage Class
- Volumes
- StateFulSets
- Headless Service
- Dynamic Provisioning
- Deployment vs StateFulSets
