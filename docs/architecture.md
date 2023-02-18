# Architecture

The following diagram shows the architecture:

![architecture](./img/architecture.png)

-   [Github] (or [Gitlab]) provides the gitops repository as well as the
    authentication through OIDC.
-   If the cluster doesn't have a direct access to the internet, which is the
    case if it is running on your development machine behind a firewall, a
    [cloudflare tunnel] (or [sish]) provides online presence.
-   The tunnel redirects HTTP/HTTPS traffic to [traefik] (or [apisix]) that acts
    as an ingress controller.
-   [External DNS] and [Cert-Manager] manage the domain name routing and the
    let's encrypt certificates generation and renewal.
-   When running on a vanilla kubernetes created by [kubeadm], uninode provides
    the basic services (Ingress, Load balancer, storage, metrics...).

## Cluster bootstrapping and stages

The following diagram summarizes the bootstrapping of the cluster:

```mermaid
---
title: Cluster bootstrap
---
flowchart TD
  A[Start] --> AA[Apply Argo CD kustomization];
  AA --> B{{Deploy Argo CD}};
  B --> C>End];
  C --> |Yes| D([+app appstage-00-bootstrap]);
  D --> E([+app traefik app]);
  D --> E2([+app argocd app]);
  E2 -.-> B;
  D --> F([+app uninode]);
  E --> dtr{{Deploy traefik}}
  F --> dml{{Deploy MetalLB}}
  F --> dfl{{Deploy Flannel}}
  F --> dls{{Deploy Local storage}}
  F --> dms{{Deploy Metrics server}}
  dml --> end2>End];
  dfl --> end2>End];
  dls --> end2>End];
  dms --> end2>End];
  dtr --> end2>End];
  end2 --> online([+app appstage-01-online])
  online --> cmapp([+app cert-manager])
  online --> ednsapp([+app external-dns])
  online --> ingapp([+app ingresses])
  online --> cldapp([+app cloudflare-client])
  cmapp --> dcm{{Deploy Cert Manager}}
  ednsapp --> dedns{{Deploy External DNS}}
  ingapp --> ding{{Deploy Ingresses}}
  cldapp --> dcld{{Deploy Cloudflare client}}
  dcm --> end3>End];
  dedns --> end3>End];
  ding --> end3>End];
  dcld --> end3>End];
  end3 --> xxx([+app appstage-02-xxx])
  xxx --> follow([...])

```

The bootstrapping of the cluster is like a domino:

1.  First the Argo CD kustomization is applied from outside the cluster.
2.  In the kustomization, there is a job that waits for the deployment of Argo
    CD to settle. When it's done, it adds the `appstage-00-bootstrap`
    application.
3.  The `appstage-00-bootstrap` application points to a directory containing
    other applications. One of them points back to the Argo CD kustomization in
    the repo. Since it has already been deployed, nothing happens. But in the
    future if Argo CD detects a change in the kustomization in the repo, it will
    _auto apply_ it to itself.
4.  The other applications of the `apps/appstage-00-bootstrap` directory install
    base services that are required to go further: `uninode` installs what is
    needed on a development cluster to use Storage, LoadBalanced services,
    Network and Auto-scaling. `traefik` provides the ingress controller.
5.  After the previous applications have settled, the `appstage-01-online`
    application is inserted to start the next stage. This application point to
    another _applications_ directory, `apps/appstage-01-online`, containing the
    second stage of base services:
    -   `ingresses` deploy ingresses to access Argo CD from internet.
    -   `cert-manager` deploys cert-manager.
    -   `external-dns-ovh` deploys external DNS using OVH API for OVH domains.
    -   `external-dns-cloudflare` deploys external DNS using Cloudflare API for
        Cloudflare domains.
    -   `cloudflare-client` installs the Cloudflare tunnel client.
    -   `sish-client` installs the sish tunnel client.

At this point, Argo CD _auto manages_ the cluster and is ready to accept new
stages.

A new stage can be created by creating a `apps/appstage-02-whatever` directory
and adding applications symbolic links to it. Then, in `apps/available`, create
a file named `appstage-02-whatever.yml` defining the `appstage-02-whatever`
pointing to the previous created directory. To finish, add a symbolic link to
this file in `apps/appstage-02-online` and commit it. This will bootstrap the
new stage.

<!-- prettier-ignore-start -->

[External DNS]: https://github.com/kubernetes-sigs/external-dns#status-of-providers
[Cert-Manager]: https://cert-manager.io/
[github]: https://github.com
[gitlab]: https://gitlab.com
[cloudflare tunnel]: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/
[sish]: https://github.com/antoniomika/sish
[traefik]: https://doc.traefik.io/traefik/
[apisix]: https://apisix.apache.org/
[kubeadm]: https://kubernetes.io/docs/reference/setup-tools/kubeadm/
<!-- prettier-ignore-end -->
