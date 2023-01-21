# Bootstrapping

This page describes how the bootstrapping occurs.

<!-- prettier-ignore-start -->
!!! note "TODO"
    provide a schema of the bootstrapping process.
<!-- prettier-ignore-end -->

## Steps

1.  Deploy Argo CD.
2.  Wait for the Argo CD deployment to settle anddDeploy the bootstrap
    application.
3.  The Bootstrap Helm chart started by the bootstrap application deploys the
    following applications:

    -   Argo CD. The application points to the exact kustomization that has been
        deployed initially. This is what makes autocloud auto-managed. As Argo
        CD is _SOPS enabled_, this makes the secrets also self managed.

    -   Uninode. This happens only if the bootstrap application contained
        `uninode: True` in the values passed to Helm.
    -   Traefik. This instantiation can be customized through the values passed
        to the bootstrap application.
    -   `apps`. This application points to a subdirectory of the `apps`
        directory. More on this below.

4.  The applications or application sets present in the directory pointed by The
    `apps` application are deployed.

## Argo CD Deployment

## Bootstrap Helm Chart

The first thing that is deployed on the cluster is Argo CD.
