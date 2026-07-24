### Kubernetes

This directory contains all Kubernetes manifests developed during the DevOps learning journey.

The manifests are intentionally simple and use NGINX as the workload, allowing each Kubernetes concept to be demonstrated independently before being integrated into the complete devops-api-stack application.

## Structure

Each directory focuses on a single Kubernetes concept, making it easier to study, test and understand each feature independently.

Examples include:

- Deployments
- Services
- ConfigMaps
- Secrets
- Storage
- Networking
- Scheduling
- Security
- Health Checks
- Multi-container Pods

## Learning Approach

Every manifest in this repository was created as part of the Kubernetes learning path.

The objective is not to deploy a production-ready application, but to provide small, focused examples that demonstrate one Kubernetes feature at a time.

Once the Kubernetes section is complete, these concepts will be combined into the full devops-api-stack application.

## How to execute

```
kubectl apply -f affinity/
kubectl apply -f configmaps/
kubectl apply -f deployments/
kubectl apply -f gateway/
kubectl apply -f ingress/
kubectl apply -f initcontainers/
kubectl apply -f liveness/
kubectl apply -f multicontainer/
kubectl apply -f namespaces/
kubectl apply -f networkpolicy/
kubectl apply -f nodes/
kubectl apply -f persistentvolume/
kubectl apply -f persistentvolumeclaim/
kubectl apply -f rbac/
kubectl apply -f readiness/
kubectl apply -f routes/
kubectl apply -f scheduling/
kubectl apply -f secrets/
kubectl apply -f serviceaccounts/
kubectl apply -f services/
kubectl apply -f startup/
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
- StatefulSets
- Headless Service
- Dynamic Provisioning
- Deployment vs StateFulSets

## Kubernetes Scheduling & Security

- Node Selector
- Node Affinity
- Node Taints
- Pod Tolerations
- RBAC
- Service Accounts
- Troubleshooting

## Kubernetes Multi-Container Pods

- Sidecar Pattern
- Shared Network Namespace
- Shared Volumes
- localhost Communication
- Container Isolation

## Kubernetes Health Checks

- Liveness Probes
- Readiness Probes
- Startup Probes
- HTTP Probes
- Health Check Lifecycle


