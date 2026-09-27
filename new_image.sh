#!/bin/bash

set -e

FILE="kubernetes/devops-api-stack/overlays/lab/kustomization.yaml"

# Read current image tag
OLD_TAG=$(grep -m1 'newTag:' "$FILE" | awk '{print $2}')

# Build new image tag from the current commit
NEW_COMMIT=$(git rev-parse --short=7 HEAD)
NEW_TAG="sha-$NEW_COMMIT"

echo "Current tag: $OLD_TAG"
echo "New tag:     $NEW_TAG"

# Check that the image exists before changing the manifest
docker buildx imagetools inspect \
  "ghcr.io/limonne/devops-api-stack:$NEW_TAG" \
  >/dev/null

# Backup the current manifest
cp "$FILE" "$HOME/kustomization.yaml_ori"

# Replace the current tag
sed -i "s/$OLD_TAG/$NEW_TAG/" "$FILE"

# Show the rendered version and image
kubectl kustomize \
  kubernetes/devops-api-stack/overlays/lab |
  rg -n \
    'APP_VERSION:|image: ghcr.io/limonne/devops-api-stack'

# Validate with the API server
kubectl apply \
  --dry-run=server \
  -k kubernetes/devops-api-stack/overlays/lab

echo
echo "Check the output before apply"
printf 'Press ENTER to apply or CTRL+C to stop: '
read -r answer

# Apply the new image
kubectl apply \
  -k kubernetes/devops-api-stack/overlays/lab

kubectl -n devops-api rollout status \
  deployment/backend \
  --timeout=180s

kubectl -n devops-api get deployment,pods \
  -o wide

kubectl -n devops-api get deployment/backend \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
