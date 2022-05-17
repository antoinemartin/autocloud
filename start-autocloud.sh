#!/bin/sh

# This script starts a mono node cluster using this repo. It has been used 
# successfully on Windows with Wsl-Alpine: https://www.powershellgallery.com/packages/Wsl-Alpine/1.1.1

# We assume the secret key is available with
# export SOPS_AGE_KEY=AGE-SECRET-KEY-...#
#
# Examples:
# 
# export SOPS_AGE_KEY=$(gopass.exe show github.com/kaweezle/iknite/age_key | tail -1 | openssl base64 -d -A)
#
# or
# 
# export SOPS_AGE_KEY_FILE=/mnt/Users/.../age.txt
#
# To use you own secrets, clone this repo and personalize the 
# ignition/argocd/secrets.yaml file

# Hopefully this will be integrated soon in kaweezle: https://kaweezle.com

set -ueo pipefail

# Add the Kaweezle APK repository
wget -qO - "https://github.com/kaweezle/iknite/releases/download/v0.1.18/kaweezle-devel@kaweezle.com-c9d89864.rsa.pub" > /etc/apk/keys/kaweezle-devel@kaweezle.com-c9d89864.rsa.pub
grep -q kaweezle $@/etc/apk/repositories || echo https://kaweezle.com/repo/ >> $@/etc/apk/repositories 

# Add some minimal dependencies
apk --update add krmfnsops k9s openssl iknite

# Start the cluster and deploy ArgoCD...
export IKNITE_KUSTOMIZE_DIRECTORY="https://github.com/antoinemartin/autocloud//ignition/argocd/?ref=main"
# If the cluster is already started (kaweezle), use configure instead of start
iknite -v debug -w 120 start

# Now deploy the app of apps. ArgoCD will take care of the rest
kubectl apply -f https://raw.githubusercontent.com/antoinemartin/autocloud/main/apps-app-uninode.yaml

# Open access to the ArgoCD UI (soon to be superseded by real URL)
pwd=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | openssl base64 -d -A)
echo
echo "===> Now login on http://localhost:8080 with login admin and password $pwd <==="
echo
kubectl port-forward svc/argocd-server -n argocd 8080:443
