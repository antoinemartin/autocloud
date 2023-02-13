# autocloud

[![stability-experimental](https://img.shields.io/badge/stability-experimental-orange.svg)](https://github.com/mkenney/software-guides/blob/master/STABILITY-BADGES.md#experimental)

Collection of Kustomizations, Helm Charts and Helmfiles to deploy a personal
developer platform.

## Welcome to Autocloud!

This repository contains the components allowing you to get a GitOps managed
Kubernetes cluster ready in minutes.

With a simple and elegant solution for the GitOps "Chicken and egg" problem, it
eases the bootstrapping of a Kubernetes environment.

To developers, Autocloud provides a development environment very close to
production.

For Devops and SREs, Autocloud is a blueprint that can be used as a base to
setup a GitOps based engineering platform.

## Features

-   Kubernetes distribution and _Clouder_ independent.
-   GitOps through [ArgoCD](https://argo-cd.readthedocs.io/).
-   Auto-managed. Once deployed, the base components are managed through GitOps.
-   No custom CLI or configuration. Use only the tools that
    [you already use](https://mrtn.me/autocloud/main/getting-started/1-pre-requisites/#software).
-   You can deploy it on your development laptop, on a managed cluster or on a
    cloud VM.
-   User management through GitHub or any other OIDC source.
-   Secrets management via [SOPS].
-   Simple architecture allowing components to be easily deactivated or
    replaced.
-   Ingress ([Traefik] or [apisix]) and Load Balancing provided.
-   Getting the best of Kustomize and Helm (and even Helmfile).
-   With online presence, your development machine can receive webhooks.

## Documentation

For extended documentation about the project and how to get started, please go
to the [Documentation](https://antoinemartin.github.io/autocloud/).

## Similar projects

[Argo CD Autopilot](https://argocd-autopilot.readthedocs.io/en/stable/) deploys
an Argo CD installation and creates the application allowing to auto-manage the
installation through a GitHub repository. However, it relies on a CLI that adds
a tool in your bag and doesn't provide solutions for ingress, authentication,
...

[Kubefirst](https://kubefirst.io/) also comes with a CLI. For local development,
it's tied with K3d, that means to K3s and docker. It's currently only compatible
with AWS. It also makes some other opinionated choices (Vault, ...). As with
Autopilot, the bootstrapping is not GitOps. It's handled by the CLI and You
don't get to review first what is going to happen.

<!-- prettier-ignore-start -->
[sops]: https://github.com/mozilla/sops
[traefik]: https://doc.traefik.io/traefik/
[apisix]: https://apisix.apache.org/
<!-- prettier-ignore-end -->
