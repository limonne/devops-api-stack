#!/usr/bin/env bash

set -u

echo "=== Nodes ==="
kubectl get nodes -o wide

echo
echo "=== Pods not Running or Completed ==="
kubectl get pods -A \
  --field-selector='status.phase!=Running,status.phase!=Succeeded'

echo
echo "=== DaemonSets ==="
kubectl get daemonsets -A

echo
echo "=== API Server readiness ==="
kubectl get --raw='/readyz?verbose'

echo
echo "=== Kubernetes versions ==="
kubectl get nodes \
  -o custom-columns='NODE:.metadata.name,KUBELET:.status.nodeInfo.kubeletVersion,RUNTIME:.status.nodeInfo.containerRuntimeVersion,ARCH:.status.nodeInfo.architecture'
