# Autocloud: GitOps Kubernetes Bootstrapper

![GitHub](https://img.shields.io/github/license/antoinemartin/autocloud)

Welcome to Autocloud!

This repository contains the components allowing you to get a GitOps managed
Kubernetes cluster ready in minutes.

Its main purpose is to ease the bootstrapping of a Kubernetes development
environment that resembles as much as possible to a real production one.

It tries to solve the GitOps "Chicken and egg" problem and provide a simple
solution for developers.

## Features

-   GitOps through ArgoCD.
-   Auto-managed. Once deployed, the base components are managed through GitOps.
-   No custom CLI. Use only the tools that you would use for devops.
-   You can deploy it on your development laptop, on a managed cluster or even
    on a cloud VM.
-   User management through GitHub (Other OIDC sources are possible).
-   Secrets management via SOPS.
-   Simple architecture allowing components to be easily deactivated or
    replaced.
-   Ingress (Traefik) and Load Balancing provided.
-   Allow a mixed usage of Kustomize and Helm (and even Helmfile).
-   Your development machine can receive webhooks.

## Similar projects

[Argo CD Autopilot](https://argocd-autopilot.readthedocs.io/en/stable/) deploys
an Argo CD installation and creates the application allowing to auto-manage the
installation through a GitHub repository. However, it relies on a CLI that adds
a tool in your bag and doesn't provide solutions for ingress, authentication,
...
