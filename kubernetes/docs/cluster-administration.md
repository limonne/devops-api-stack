# Kubernetes Cluster Administration

## Cluster topology

| Node | Role | OS | Architecture | Kubernetes | Runtime |
|---|---|---|---|---|---|
| k8s-control-plane | Control Plane | Ubuntu 26.04 | amd64 | 1.35.7 | containerd 2.2.2 |
| k8s-worker-01 | Worker | Debian 12 | arm64 | 1.35.7 | containerd 1.6.20 |

## Networking

- CNI: Flannel
- Backend: VXLAN
- Cluster Pod CIDR: 10.244.0.0/16
- Control Plane PodCIDR: 10.244.0.0/24
- Worker PodCIDR: 10.244.1.0/24

## Cluster bootstrap

- kubeadm init
- Flannel installation
- kubeadm join
- TLS bootstrap
- Worker registration

## PKI

- Kubernetes CA
- API Server certificate
- etcd certificates
- kubelet client certificates

## etcd

- Static Pod
- Data directory: /var/lib/etcd
- Backup with etcdctl
- Validation and restore with etcdutl

## Upgrade history

- 1.33.13 → 1.34.10
- 1.34.10 → 1.35.7

## Validation

- Nodes Ready
- System Pods Running
- API Server readyz passed
- Worker scheduling tested
- DNS and Service connectivity tested
