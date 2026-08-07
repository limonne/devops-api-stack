#!/usr/bin/env bash

set -u

INTERVAL="${INTERVAL:-5}"
LOG_PREFIX="[website-controller]"

log() {
  printf '%s %s\n' "$LOG_PREFIX" "$*"
}

update_status() {
  local namespace="$1"
  local name="$2"
  local phase="$3"
  local ready_replicas="$4"

  local current_status
  current_status="$(
    kubectl get website "$name" \
      -n "$namespace" \
      -o jsonpath='{.status.phase}|{.status.readyReplicas}' \
      2>/dev/null || true
  )"

  local desired_status="${phase}|${ready_replicas}"

  if [[ "$current_status" != "$desired_status" ]]; then
    kubectl patch website "$name" \
      -n "$namespace" \
      --subresource=status \
      --type merge \
      -p "{
        \"status\": {
          \"phase\": \"${phase}\",
          \"readyReplicas\": ${ready_replicas}
        }
      }" >/dev/null

    log "${namespace}/${name}: status=${phase}, ready=${ready_replicas}"
  fi
}

reconcile_website() {
  local namespace="$1"
  local name="$2"
  local uid="$3"
  local image="$4"
  local replicas="$5"
  local enabled="$6"
  local message="$7"

  local deployment="website-${name}"
  local service="website-${name}"

  if [[ "$enabled" != "true" ]]; then
    kubectl delete deployment "$deployment" \
      -n "$namespace" \
      --ignore-not-found >/dev/null

    kubectl delete service "$service" \
      -n "$namespace" \
      --ignore-not-found >/dev/null

    update_status "$namespace" "$name" "Disabled" 0

    log "${namespace}/${name}: aplicação desativada"
    return
  fi

  local safe_message
  safe_message="${message//\\/\\\\}"
  safe_message="${safe_message//\"/\\\"}"

  cat <<MANIFEST | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: Deployment

metadata:
  name: ${deployment}
  namespace: ${namespace}

  labels:
    app.kubernetes.io/name: ${name}
    app.kubernetes.io/managed-by: website-operator

  ownerReferences:
    - apiVersion: lab.devops/v1alpha1
      kind: Website
      name: ${name}
      uid: ${uid}
      controller: true
      blockOwnerDeletion: true

spec:
  replicas: ${replicas}

  selector:
    matchLabels:
      app.kubernetes.io/name: ${name}

  template:
    metadata:
      labels:
        app.kubernetes.io/name: ${name}

      annotations:
        lab.devops/message: "${safe_message}"

    spec:
      containers:
        - name: nginx
          image: ${image}

          ports:
            - name: http
              containerPort: 80

          env:
            - name: WEBSITE_NAME
              value: "${name}"

            - name: WEBSITE_MESSAGE
              value: "${safe_message}"

          readinessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 2
            periodSeconds: 5

          resources:
            requests:
              cpu: 20m
              memory: 16Mi

            limits:
              cpu: 100m
              memory: 64Mi

---
apiVersion: v1
kind: Service

metadata:
  name: ${service}
  namespace: ${namespace}

  labels:
    app.kubernetes.io/name: ${name}
    app.kubernetes.io/managed-by: website-operator

  ownerReferences:
    - apiVersion: lab.devops/v1alpha1
      kind: Website
      name: ${name}
      uid: ${uid}
      controller: true
      blockOwnerDeletion: true

spec:
  type: ClusterIP

  selector:
    app.kubernetes.io/name: ${name}

  ports:
    - name: http
      port: 80
      targetPort: http
MANIFEST

  local ready_replicas
  ready_replicas="$(
    kubectl get deployment "$deployment" \
      -n "$namespace" \
      -o jsonpath='{.status.readyReplicas}' \
      2>/dev/null || true
  )"

  ready_replicas="${ready_replicas:-0}"

  local phase="Reconciling"

  if [[ "$ready_replicas" == "$replicas" ]]; then
    phase="Ready"
  fi

  update_status \
    "$namespace" \
    "$name" \
    "$phase" \
    "$ready_replicas"

  log "${namespace}/${name}: reconciliado image=${image} replicas=${replicas}"
}

log "controller iniciado; intervalo=${INTERVAL}s"

while true; do
  while IFS=$'\t' read -r \
    namespace \
    name \
    uid \
    image \
    replicas \
    enabled \
    message
  do
    [[ -z "${name:-}" ]] && continue

    reconcile_website \
      "$namespace" \
      "$name" \
      "$uid" \
      "$image" \
      "$replicas" \
      "$enabled" \
      "$message"

  done < <(
    kubectl get websites \
      --all-namespaces \
      -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{.metadata.uid}{"\t"}{.spec.image}{"\t"}{.spec.replicas}{"\t"}{.spec.enabled}{"\t"}{.spec.message}{"\n"}{end}' \
      2>/dev/null || true
  )

  sleep "$INTERVAL"
done
