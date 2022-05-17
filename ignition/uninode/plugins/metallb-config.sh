#!/bin/sh

if [ -z "$HOST_IP" ]; then
  ip=$(kubectl cluster-info | head -1 | sed -E '1 s#.*https://(.*):.*#\1#g')
else
  ip="$HOST_IP"
fi
cat - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: config
  namespace: metallb-system
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - $ip/32
EOF
