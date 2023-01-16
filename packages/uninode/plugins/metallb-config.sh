#!/bin/sh

if [ -z "$HOST_IP" ]; then
  ip=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}')
else
  ip="$HOST_IP"
fi
cat - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: node-ip-pool
  namespace: metallb-system
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  addresses:
  - $ip/32
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: advertisement
  namespace: metallb-system
  annotations:
    argocd.argoproj.io/sync-wave: "1"
EOF
