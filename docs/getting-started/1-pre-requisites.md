# Pre-requisites

-   [kubectl](https://Kubernetes.io/docs/tasks/tools/){:target="\_blank"} to
    apply resources to your cluster.
-   [sops](https://github.com/mozilla/sops){:target="\_blank"} for secrets
    management. [age]{:target="\_blank"} is a nice addition if you want to use
    AGE keys to encrypt secrets (recommended).
-   [kustomize](https://kustomize.io/){:target="\_blank"} for aggregating and
    adapting resources. kubectl includes kustomize but it only allows running
    [KRM functions] as docker containers. This creates an impractical dependency
    on docker. This is why we use the [Exec KRM functions] model. To use it,
    however, the kustomize binary is required.
-   [krmfnsops]{:target="\_blank"} is a KRM function that decrypts SOPS
    encrypted resources in Kustomize. It is used both locally and by Argo CD to
    decrypt secrets.
-

!!! todo

    Provide already configured environments:

    - Docker container (can be argocd custom image. age is missing)
    - WSL distribution (can be derived from the docker image)
    - LXC root filesystem

## Kubernetes cluster

To deploy autocloud, you need a Kubernetes cluster. Autocloud is originally used
and tested with a vanilla Kubernetes cluster created with [kubeadm], running on
an Alpine based VM or WSL2 distribution. The deployment of such a cluster is
made easy by using the [iknite] package. On Windows, [kaweezle] makes this
deployment even easier.

In such _mono-node_ deployment configuration, autocloud provides an [uninode]
Argo CD application providing basic configuration (CNI, storage, metrics, Load
Balancer).

Most lightweight developer oriented Kubernetes distribution like [Kind], [K3s],
[MicorK8s] or [Rancher Desktop] as well as all managed clusters already provide
such services. Fortunately, autocloud provides an easy way to deactivate
[uninode].

In the following, we will use [K3s], that seems to be currently the most popular
solution as an example.

<!-- prettier-ignore-start -->

[KRM functions]: https://github.com/kubernetes-sigs/kustomize/blob/master/cmd/config/docs/api-conventions/functions-spec.md
[Exec KRM functions]: https://kubectl.docs.kubernetes.io/guides/extending_kustomize/exec_krm_functions/
[krmfnsops]: https://github.com/kaweezle/krmfnsops
[kubeadm]: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
[uninode]: https://github.com/antoinemartin/autocloud/tree/deploy/citest/packages/uninode
[iknite]: https://github.com/kaweezle/iknite
[kaweezle]: https://www.kaweezle.com/
[Kind]: https://kind.sigs.k8s.io/
[K3s]: https://k3s.io/
[MicorK8s]: https://microk8s.io/
[Rancher Desktop]: https://rancherdesktop.io/
[age]: https://github.com/FiloSottile/age

<!-- prettier-ignore-end -->
