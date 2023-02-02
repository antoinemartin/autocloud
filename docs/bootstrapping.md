# Bootstrapping stages

This page describes how the bootstrapping occurs.

!!! note "TODO"

    provide a schema of the bootstrapping process.

## Steps

1.  Deploy Argo CD by deploying the `packages/argocd` kustomization.
2.  Wait for the Argo CD deployment to settle and deploy the `bootstrap`
    application.
3.  The `bootstrap` application directory contains the following applications:

    -   Argo CD. The application points to the exact kustomization that has been
        deployed initially. This is what makes autocloud auto-managed. As Argo
        CD is _SOPS enabled_, this makes the secrets also self managed.

    -   Uninode. This happens only if the bootstrap application directory still
        has a symbolic link to `apps/available/uninode.yaml`.
    -   Traefik.
    -   `apps`. This application points to the subdirectory `apps/default` of
        the `apps` directory. More on this below.

4.  The applications or application sets present in the directory pointed by The
    `apps` (`apps/default`) application are deployed.

## Argo CD Deployment

## Bootstrap Helm Chart

The first thing that is deployed on the cluster is Argo CD.
