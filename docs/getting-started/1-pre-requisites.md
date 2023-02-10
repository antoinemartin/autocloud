# Pre-requisites

## Software

-   [kubectl:material-open-in-new:](https://Kubernetes.io/docs/tasks/tools/){:target="\_blank"}
    to apply resources to your cluster.
-   [sops:material-open-in-new:](https://github.com/mozilla/sops){:target="\_blank"}
    for secrets management. [age:material-open-in-new:][age]{:target="\_blank"}
    is a nice addition if you want to use AGE keys to encrypt secrets
    (recommended).
-   [kustomize:material-open-in-new:](https://kustomize.io/){:target="\_blank"}
    for aggregating and adapting resources. `kubectl` includes `kustomize`
    (`kustomize` subcommand and `-k` option) but it only allows running [KRM
    functions] as docker containers. This creates an impractical dependency on
    docker. This is why we use the [Exec KRM functions] model. To use it,
    however, the `kustomize` standalone binary is required.
-   [krmfnbuiltin:material-open-in-new:][krmfnbuiltin]{:target="\_blank"} is a
    swiss army knife KRM function allowing us to perform structural
    modifications to the resources of the environment. Think of it as `sed`, but
    for Kubernetes resources. Also knows how to decrypt sops encrypted KRM
    resources.
-   [Kubeconform:material-open-in-new:](https://github.com/yannh/kubeconform){:target="\_blank"}
    performs validation of Kubernetes resources. It is useful to check
    kustomization output.

!!! todo

    Provide already configured environments:

    - Docker container (can be argocd custom image. age is missing)
    - WSL distribution (can be derived from the docker image)
    - LXC root filesystem

## Online git provider account

Autocloud is hosted on GitHub and currently uses the following features:

-   [OAuth Apps:material-open-in-new:](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app){:target="\_blank"}
    to provide authentication to the Argo CD Web UI.
-   [Webhook:material-open-in-new:](https://docs.github.com/en/developers/webhooks-and-events/webhooks/about-webhooks){:target="\_blank"}
    to trigger cluster update immediately.
-   [Deployment keys:material-open-in-new:](https://docs.github.com/en/developers/overview/managing-deploy-keys){:target="\_blank"}
    to allow repository read-only restricted access for Argo CD.

Gitlab provides the same features and can probably be used as well.

!!! info "Gittea support"

    Supporting Air gapped developments with a cluster hosted Gittea server is
    planned.

## Kubernetes cluster

To deploy autocloud, you need a Kubernetes cluster. Autocloud is originally used
and tested with a vanilla Kubernetes cluster created with [kubeadm], running on
an Alpine based VM or WSL2 distribution. The deployment of such a cluster is
made easy by using the [iknite] package. On Windows, [kaweezle] makes this
deployment even easier.

In such _mono-node_ deployment configuration, autocloud provides an [uninode]
kustomization and Argo CD application providing basic configuration (CNI,
storage, metrics, Load Balancer).

Most lightweight developer oriented Kubernetes distribution like [Kind], [K3s],
[MicorK8s] or [Rancher Desktop] as well as all managed clusters already provide
such services. Fortunately, autocloud provides an easy way to deactivate
[uninode].

!!! note

    In this documentation, we will use [K3s], that seems to be currently
    the most popular solution as an example.

## Cloud provider account(s)

If you want to get the most out of Autocloud, You will need at least the
following:

-   A registered domain name. Make sure that your domain name provider has an
    API that is known to [External DNS] and [Cert-Manager].
    [OVH:material-open-in-new:](https://www.ovhcloud.com/fr/domains/tld/){:target="\_blank"},
    for instance, offers domain names for 1,99€ (without VAT) on its `.ovh` TLD.
    [Cloudflare:material-open-in-new:](https://www.cloudflare.com/products/registrar/){:target="\_blank"}
    promises no markup on their end. With them a `.com` is less that 10$ a year.
-   To be able to run Autocloud behind a firewall _as if_ it was running in a
    cloud provider, a tunnelling solution is needed. Cloudflare has a free tier
    on its
    [tunnel offering:material-open-in-new:](https://www.cloudflare.com/products/tunnel/){:target="\_blank"}
    that you can use with a domain that has been registered with them.
    [Tailscale:material-open-in-new:]{:target="\_blank"} also offers a free
    tier. [inlets:material-open-in-new:](https://inlets.dev/){:target="\_blank"}
    and [ngrok:material-open-in-new:](https://ngrok.com/){:target="\_blank"} are
    not cheap. We provide simple Open Source solutions (sish, chisel) if the
    case that you can deploy software somewhere in the cloud.
-   S3 compatible storage. While you can use
    [Minio:material-open-in-new:]{:target="\_blank"}, external storage is useful
    for backups and shared storage. [Cloudflare][cloudflare r2] as a free tier
    for starters and doesn't charge for egress traffic. There are too other
    numerous solutions to list. Nowadays, everyonec is S3 compatible.

!!! note

    In this documentation, we will use [Cloudflare:material-open-in-new:](https://www.cloudflare.com/)
    as it provides the three components above. **This is not a recommendation**.
    Furthermore, autocloud provides kustomizations for some of the other
    providers (OVH, for instance).

## IDE Integration

Autocloud provides helpful additions if you are using Visual Studio Code as your
IDE:

-   Plugins recommendations.
-   Tasks (see `.vscode/tasks.json`).

Once you have all these elements, proceed to the
[GitOps setup:material-arrow-right:](../2-gitops-setup).

<!-- prettier-ignore-start -->

[KRM functions]: https://github.com/kubernetes-sigs/kustomize/blob/master/cmd/config/docs/api-conventions/functions-spec.md
[Exec KRM functions]: https://kubectl.docs.kubernetes.io/guides/extending_kustomize/exec_krm_functions/
[krmfnbuiltin]: https://github.com/kaweezle/krmfnbuiltin
[kubeadm]: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
[uninode]: https://github.com/antoinemartin/autocloud/tree/main/packages/uninode
[iknite]: https://github.com/kaweezle/iknite
[kaweezle]: https://www.kaweezle.com/
[Kind]: https://kind.sigs.k8s.io/
[K3s]: https://k3s.io/
[MicorK8s]: https://microk8s.io/
[Rancher Desktop]: https://rancherdesktop.io/
[age]: https://github.com/FiloSottile/age
[External DNS]: https://github.com/kubernetes-sigs/external-dns#status-of-providers
[Tailscale:material-open-in-new:]: https://tailscale.com/
[Minio:material-open-in-new:]: https://github.com/minio/minio
[Cert-Manager]: https://cert-manager.io/
[Cloudflare R2]: https://www.cloudflare.com/lp/pg-r2/
<!-- prettier-ignore-end -->
