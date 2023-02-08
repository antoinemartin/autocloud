# Argo CD Kustomization

## Values

This replacement is also a base replacement that your want to perform just after
forking/branching. It performs the following replacements:

-   Apply `github.clientID` for github authentication in ArgoCD.
-   Apply `github.organization` to the organization allowed to sign in.
-   Apply `repoURL` and `targetRevision` to the autocloud configmap in order for
    the bootstrap application inserted after initialization to point to the
    right repo/branch.
