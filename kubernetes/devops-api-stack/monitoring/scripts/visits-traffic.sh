#!/bin/bash

set -e

for request in {1..120}; do
  curl \
    -sS \
    --max-time 5 \
    -o /dev/null \
    -w 'HTTP %{http_code}\n' \
    -H 'Host: devops-api.lab' \
    http://192.168.1.163:30080/api/visits

  sleep 1
done
