# Modified version of https://github.com/chatwork/dockerfiles/blob/master/argocd-helmfile/Dockerfile
# to include last version of kustomize and krmfnsops, a ksops like
FROM argoproj/argocd:v2.5.4

LABEL version="2.5.4-0.144.0"
LABEL maintainer="antoine@openance.com"

# Switch to root for the ability to perform install
USER root

ARG HELMFILE_VERSION=v0.144.0
ARG HELM_VERSION=v3.11.0
ARG HELM_LOCATION="https://get.helm.sh"
ARG HELM_FILENAME="helm-${HELM_VERSION}-linux-amd64.tar.gz"
ARG KUBECTL_VERSION=v1.26.0
ARG SOPS_VERSION=v3.7.3
ARG HELM_DIFF_VERSION=3.6.0
ARG HELM_SECRETS_VERSION=4.2.2
ARG KUSTOMIZE_VERSION=v4.5.7
ARG KRMFNSOPS_VERSION=v0.1.6
ARG KRMFNBUILTIN_VERSION=v0.0.2
ARG AGE_VERSION=v1.1.1

# Install tools needed for your repo-server to retrieve & decrypt secrets, render manifests
# (e.g. curl, awscli, gpg, sops)

# helm
# helmfile, sops, kubectl
RUN apt-get update && \
    apt-get install -y curl gpg apt-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # kubectl
    curl -sLo /usr/local/bin/kubectl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    # helm
    curl -sLO ${HELM_LOCATION}/${HELM_FILENAME} && \
    tar zxvf ${HELM_FILENAME} && mv ./linux-amd64/helm /usr/local/bin/ && \
    rm ${HELM_FILENAME} && rm -r ./linux-amd64 && \
    # helmfile
    curl -sLo /usr/local/bin/helmfile -L https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64 && \
    # sops
    curl -sLo /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64 && \
    # Kustomize
    curl -sL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz | tar zxf - && \ 
    mv kustomize /usr/local/bin && \
    # krmfnsops
    curl -sLo /usr/local/bin/krmfnsops https://github.com/kaweezle/krmfnsops/releases/download/${KRMFNSOPS_VERSION}/krmfnsops_${KRMFNSOPS_VERSION}_linux_amd64 && \
    # krmfnbuiltin
    curl -sLo /usr/local/bin/krmfnbuiltin https://github.com/kaweezle/krmfnbuiltin/releases/download/${KRMFNBUILTIN_VERSION}/krmfnbuiltin_${KRMFNBUILTIN_VERSION}_linux_amd64 && \
    # Age
    curl -sL https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz | tar zxf - && \ 
    mv age/age* /usr/local/bin && rm -rf age && \
    chmod +x /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helmfile && \
    chmod +x /usr/local/bin/kustomize && \
    chmod +x /usr/local/bin/krmfnsops && \
    chmod +x /usr/local/bin/krmfnbuiltin && \
    chmod +x /usr/local/bin/sops

# Switch back to non-root user
USER argocd

RUN helm plugin install https://github.com/databus23/helm-diff --version v${HELM_DIFF_VERSION} && \
    helm plugin install https://github.com/jkroepke/helm-secrets --version v${HELM_SECRETS_VERSION} && \
    helm plugin install https://github.com/mumoshu/helm-x  && \
    helm plugin install https://github.com/aslafy-z/helm-git.git
