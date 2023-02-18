# Environment adaptation

## Introduction

Adapting the environment involves the following tasks:

-   Adapt the secrets file `secrets/secrets.yaml` and the properties file
    `values.yaml` to the target environment.
-   Apply the defined properties to the applications and kustomizations. That
    means make the structural replacements in the resources for the defined
    properties.
-   Select the applications to be deployed in the target environment.

The secrets are in `secrets/secrets.yaml` and the properties in `values.yaml`.
They live in separate files for several reasons:

-   The secrets are encrypted using sops whereas the properties are kept in
    plain text.
-   The properties are applied **before** committing. Secrets are opaque so
    having any value in the files is not that important. To the contrary, having
    actual values for other properties allows browsing of the repo without the
    need to always refer to the centralized `values.yaml`. Therefore, the
    applications and kustomizations contain the actual property values.
    _Applying_ from a centralized file is just a convenience to ease adaptation
    and avoid oversights (see the
    [properties documentation](/user-guide/properties)).
-   The kustomizations contain plain text **fake** secrets. They are
    **replaced** with actual values **in the cluster** while the kustomizations
    are built. Unencrypted values are injected in the kustomization by
    `krmfnbuiltin` (more information in the [user guide](/user-guide/secrets)).

## Adapt secrets and properties

First you need an unencrypted secrets file. If you are comming from
[:material-arrow-left:the previous step](../3-change-encryption-key) this is
already the case. If not, issue the following command:

=== "Shell"

    ```bash
    $ sops -d secrets/secrets.yaml > secrets/secrets.dec.yaml
    $
    ```

=== "PowerShell"

    ```powershell
    ...
    PS> sops -d secrets/secrets.yaml > secrets/secrets.dec.yaml
    PS>
    ```

### Cluster identifier and domain name

The first properties of the `values.yaml` file contain global information about
the cluster:

```yaml
data:
    cluster:
        id: klasmikloud
        dnsZone: klasmik.com
        argocd:
            domainPrefix: argocd-devenv
```

`id` is the identifier of the cluster. `dnsZone` is the global domain name used
by the cluster. `argocd.domainPrefix` allows the composition of the Argo CD UI
domain name. In our example, it will be `argocd-devenv.klasmik.com`.

### Secrets encryption key

Argo CD, When building kustomizations, need to have access to a decryption key
to be able to decrypt the `secrets/secrets.yaml` file in order to inject
secrets. This key is the key that you have created in
[the previous step](../3-change-encryption-key/) and that is located in
`~/.config/sops/age/keys.txt` (or `$env:APPDATA\sops\age\keys.txt` on Windows)

Put this key under `data.sops.age_key\.txt` in `secrets/secrets.dec.yaml`:

```yaml
# secrets/secrets.dec.yaml
data:
    #...
    sops:
        age_key.txt: |-
            # created: 2023-01-19T19:41:45Z
            # public key: age166k86d56ejs2ydvaxv2x3vl3wajny6l52dlkncf2k58vztnlecjs0g5jqq
            AGE-SECRET-KEY-15RKTPQCCLWM7EHQ8JEP0TQLUWJAECVP7332M3ZP0RL9R7JT7MZ6SY79V8Q
```

### Repositiory access

!!! info "Optional"

    This is only needed if your repository is private.

To allow Argo CD to access the private repository, you can either use a [deploy
key] or a [Personal Access Token][github-pat-docs]. The later is only
interesting for accessing several repositories with the same credentials but is
weaker in terms of security. For the initial setup, reading access to the
autocloud repo is the only thing that we need. So for now, we will move forward
with a deploy key.

Create a SSH key with the following command:

=== "Shell"

    ```bash
    $ ssh-keygen -N "" -C autocloud -q -t ed25519 -f autocloud
    $ cat autocloud.pub
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOqETmwadG+AtnC3HvdT66SIcilJIZdaRIrSRETHK1fU autocloud
    $
    ```

=== "PowerShell"

    ```powershell
    PS> # Note the backquotes before the double quotes
    PS> ssh-keygen.exe -q -C autocloud -t ed25519 -N `"`" -f autocloud
    PS> type autocloud.pub
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOqETmwadG+AtnC3HvdT66SIcilJIZdaRIrSRETHK1fU autocloud
    PS>
    ```

And then add it to the repo with the github CLI:

```console
>  gh repo deploy-key add autocloud.pub --title autocloud
```

You can also do it on github.com. Go to the following URL:

```bash
# In our case, https://github.com/klasmik/klasmikloud/settings/keys/new
https://github.com/<organization>/<project>/settings/keys/new
```

And enter the public key:

![add deploy key](../img/add_deploy_key.png)

!!! info

    Argo CD will only use this key to clone the repository. Allowing write
    access is not required.

Now test the key:

=== "Shell"

    ```bash
    $ ssh -i ./autocloud git@github.com
    PTY allocation request failed on channel 0
    Hi klasmik/klasmikloud! You've successfully authenticated, but GitHub does not provide shell access.
    Connection to github.com closed.
    $
    ```

=== "PowerShell"

    ```powershell
    PS> ssh -i autocloud git@github.com
    PTY allocation request failed on channel 0
    Hi klasmik/klasmikloud! You've successfully authenticated, but GitHub does not provide shell access.
    Connection to github.com closed.
    PS>
    ```

Now save the private key in the `secrets/secrets.dec.yaml` in the
`github.ssh_key` key:

<!-- prettier-ignore-start -->
```yaml
data:
    # ...
    github:
        # ...
        ssh_key: |-
            -----BEGIN OPENSSH PRIVATE KEY-----
            b3BlbnNza...
            ... SpbRCCLhgXt42GirPwlUAAAACWF1dG9jbG91ZAECAwQ= 
            -----END OPENSSH PRIVATE KEY-----
```
<!-- prettier-ignore-end -->

### Argo CD Authentication

The Argo CD Autocloud installation comes with a local admin user and with Dex to
allow SSO from an exiting OIDC source. In its initial configuration the SSO is
done through github with all users of the specified organization as admins.

#### Local admin password

Choose an admin password (hard to guess, easy to remember) and put it in the
`secrets/secrets.dec.yaml` file under the `data.argocd.admin_password` key:

```yaml
# secrets/secrets.dec.yaml
data:
    # ...
    argocd:
        admin_password: password
```

#### Github OIDC authentication

!!! info "Optional"

    This is only needed if your want to authenticate to Argo CD with a github
    account.

More details are available in the [GitHub documentation about OAuth
Apps][github-oauth-apps].

Go to
`https://github.com/organizations/<organization>/settings/applications/new` and
create the OAuth application according to the following:

![OAuth application creation](../img/github_oauth_application.png)

Use the prefix (here `argocd-devenv`) that you plan to use for the Argo CD Web
UI and the domain name (here `klasmik.com`) that you plan to use for the access
to the cluster through the cloud.

Once the application is created, copy the Client ID in the
`data.github.clientID` of the properties.yaml file:

```yaml
data:
    # ...
    github:
        # ...
        clientID: f3f29986cc0c4608ce03
```

Click on the `Generate a new client secret`.

![OAuth client ID and secret](../img/oauth_client_secret.png)

Copy the value in the `secrets/secrets.dec.yaml` file under the
`data.github.oauth_client_secret`:

```yaml
data:
    # ...
    github:
        # ...
        oidc_client_secret: d84...
```

Autocloud configures Argo CD to let in users pertaining to a particular
organization. You need to specify the organization name in the `values.yaml`
file under the `github` key:

```yaml
data:
    # ...
    github:
        organization: klasmik
```

### Argo CD Webhook update

!!! info "Optional"

    This is if you want _near realtime_ deployment and if Argo CD
    is accessible through internet.

Argo CD checks the git repositories every 3 minutes for updates. To trigger the
updates as soon as the modifications are pushed, it is convenient to add a
webhook to the repository. The webhook will notify Argo CD to trigger the
modification check immediately.

Create a webhook according to the [Argo CD webhook documentation]. Go to

```bash
# In our case, https://github.com/klasmik/klasmikloud/settings/hooks
https://github.com/<organization>/<epo>/settings/hooks
```

Click on the `Add webhook` button on the top right:

![GitHub Create webhook](../img/github_create_webhook.png)

Enter a secret. The same secret needs to be inserted in the
`secrets/secrets.dec.yaml` file in the `data.github.webhook_secret` key:

```yaml
data:
    # ...
    github:
        # ...
        webhook_secret: 3Ab...
```

### DNS provider API credentials

Autocloud currently supports two DNS providers: OVH and Cloudflare. Each of them
is configured in its respective `ovh` and `cloudflare` sections.

In `values.yaml`:

```yaml
# values.yaml
data:
    cloudflare:
        email: john@doe.me
        dnsZone: klasmik.com
    ovh:
        endpoint: ovh-eu
        applicationKey: iYrnuWulPIzRIYZP
        dnsZone: develop.cx
```

In `secrets.yaml`:

```yaml
data:
    cloudflare:
        apiKey: e...
    ovh:
        application_secret: E...
        consumer_key: l...
```

For OVH, the API access credentials can be created at the following address:
[https://www.ovh.com/auth/api/createToken](https://www.ovh.com/auth/api/createToken)

For Cloudflare, you need to retrieve your API token at the following page:
[https://dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens)

### Online presence

#### Cloudflare tunnel

To setup the cloudflare tunnel, the best option is from the command line with
the help of the `cloudflared` CLI. To install it, follow the instructions in the
[cloudflared documentation][cloudflared-install-page]

Start with login:

```console
> cloudflared tunnel login
Please open the following URL and log in with your Cloudflare account:

https://dash.cloudflare.com/argotunnel?callback=https%3A%2F%2Flogin.cloudflareaccess.org%2F_P_LYLgTz4vuQtxb_BpRhZ3-0KipIrOlyZoX8XxhyFQ%3D

Leave cloudflared running to download the cert automatically.
2023-02-09T18:27:21Z INF Waiting for login...
```

Choose you domain name and validate it:

![cloudflare tunnel login](../img/cloudflare_tunnel_login.png)

the login ends in the terminal:

```console
...
2023-02-09T18:27:21Z INF Waiting for login...
You have successfully logged in.
If you wish to copy your credentials to a server, they have been saved to:
/root/.cloudflared/cert.pem
>
```

Then create the tunnel:

```console
> cloudflared tunnel create klasmikloud
Tunnel credentials written to /root/.cloudflared/b3d4c50f-94a7-4d2d-a5a2-b16dbdad6db6.json. cloudflared chose this file based on where your origin certificate was found. Keep this file secret. To revoke these credentials, delete the tunnel.

Created tunnel klasmikloud with id b3d4c50f-94a7-4d2d-a5a2-b16dbdad6db
>
```

The id printed goes in the `data.cloudflare.tunnel_id` property of the
`values.yaml` file:

```yaml
# values.yaml
data:
    # ...
    cloudflare:
        email: antoine@openance.com
        dnsZone: klasmik.com
        hostName: '*.klasmik.com'
        tunnel_id: b3d4c50f-94a7-4d2d-a5a2-b16dbdad6db
```

The contents of the json file mentioned in the command output (here
`/root/.cloudflared/b3d4c50f-94a7-4d2d-a5a2-b16dbdad6db6.json`) go in the
`secrets/secrets.yaml` file in the `data.cloudflare.credentials\.json` property:

```yaml
# secrets/secrets.dec.yaml
data:
    cloudflare:
        credentials.json: |
            {"AccountTag":"a...","TunnelSecret":"p...","TunnelID":"b3d4c50f-94a7-4d2d-a5a2-b16dbdad6db6"}
```

you also need to associate your domain name with the tunnel with the following
command:

```console
> cloudflared tunnel route dns klasmikloud argocd-devenv.klasmik.com
2023-02-09T19:00:16Z INF Added CNAME argocd-devenv.klasmik.com which will route to this tunnel tunnelID=b3d4c50f-94a7-4d2d-a5a2-b16dbdad6db6
>
```

If you go to the DNS configuration of your domain name, you will see the `CNAME`
record:

![tunnel CNAME record](../img/cloudflare_dns_cname.png)

!!! note "TLS termination"

    With this configuration, and in particular the fact that the CNAME is
    _proxied_, the TLS termination of the domain name is handled by cloudflare.

#### Sish

[sish] enables online presence for the cluster by using the ssh protocol. Sish
offers several advantages:

-   The client is a standard ssh client.
-   The server supports SNI. You can have multiple subdomains and domain names
    on the same server.
-   As authentication is done through ssh keys, you can leverage existing
    infrastructure. For instance you can use the github keys API to feed your
    server with authorized keys.

There is more information in the [sish component page](../components/sish.md).

For the configuration, you will need the following values:

```yaml
sish:
    hostname: develop.cx
    remote: argocd-devenv.develop.cx
    # This is the public key of the private ed25519 key in ../secrets/helm/sish.yaml
    host_key: AAAAC3NzaC1lZDI1NTE5AAAAIEAfLUpTj0fn5sJFW6agmLMsvEacMBvXocyzHLW+AOSQ
```

`hostname` is the address of the sish server. `remote` is the full domain name
that needs to be redirected locally. `host_key` is the public key of the host.

The only secret is the ssh private key to connect to the server:

```yaml
sish:
    ssh_key: |
        -----BEGIN OPENSSH PRIVATE KEY-----
        b3B...
        ...FBg==
        -----END OPENSSH PRIVATE KEY-----
```

This key needs to be registered in a github account so that the URL
`https://github.com/<account>.keys` returns the public key. The name of the
github account needs to be passed to the deployment of the `sish` helm chart in
the `auth.github_accounts` key.

### Other properties

At this point the other properties of the `values.yaml` files (`sish`...) can be
left as is.

## Committing current configuration

At this point you should commit the current configuration without forgetting to
encrypt the secrets.

=== "Shell"

    ```bash
    $ sops -e secrets/secrets.dec.yaml > secrets/secrets.yaml
    $ rm secrets/secrets.dec.yaml
    $ git add values.yaml secrets/secrets.yaml
    $ git commit -m "🔧 Platform values and secrets customization"
    $
    ```

=== "PowerShell"

    ```powershell
    PS> sops -e secrets\secrets.dec.yaml > secrets\secrets.yaml
    PS> Remove-Item secrets/secrets.dec.yaml
    PS> git add values.yaml secrets\secrets.yaml
    PS> git commit -m "🔧 Platform values and secrets customization"
    PS>
    ```

## Applying properties to kustomizations and applications

Apply the values to the current environment:

=== "Shell"

    ```bash
    $ kustomize fn run --enable-exec packages
    $ kustomize fn run --enable-exec apps
    $ git status
    On branch deploy/devenv
    Changes not staged for commit:
    (use "git add <file>..." to update what will be committed)
    (use "git restore <file>..." to discard changes in working directory)
            modified:   apps/available/apisix.yaml
            modified:   apps/available/applications-set.yaml
            modified:   apps/available/argocd.yaml
            modified:   apps/available/appstage-00-bootstrap.yaml
            modified:   apps/available/cert-manager.yaml
            modified:   apps/available/chisel-client.yaml
            modified:   apps/available/external-dns-cloudflare.yaml
            modified:   apps/available/external-dns-ovh.yaml
            modified:   apps/available/ingresses.yaml
            modified:   apps/available/sish.yaml
            modified:   packages/argocd/argocd-cm.yaml
            modified:   packages/argocd/autocloud-cm.yaml
            modified:   packages/cert-manager/letsencrypt-issuer.yaml
            modified:   packages/cloudflare-client/deployment.yaml
            modified:   packages/external-dns-cloudflare/external-dns-configmap.yaml
            modified:   packages/external-dns-cloudflare/external-dns-secret.yaml
            modified:   packages/external-dns-ovh/external-dns-configmap.yaml
            modified:   packages/external-dns-ovh/external-dns-secret.yaml
            modified:   packages/ingresses/argocd-ingress-cloudflare.yaml
            modified:   packages/ingresses/argocd-ingress.yaml
            modified:   packages/sish-client/sish-client.yaml

    no changes added to commit (use "git add" and/or "git commit -a"
    $ git commit -a -m "🔧 Applied platform values to applications and packages"
    $
    ```

=== "PowerShell"

    ```powershell
    PS> kustomize fn run --enable-exec packages
    PS> kustomize fn run --enable-exec apps
    PS> git status
    On branch deploy/devenv
    Changes not staged for commit:
    (use "git add <file>..." to update what will be committed)
    (use "git restore <file>..." to discard changes in working directory)
            modified:   apps/available/apisix.yaml
            modified:   apps/available/applications-set.yaml
            modified:   apps/available/argocd.yaml
            modified:   apps/available/appstage-00-bootstrap.yaml
            modified:   apps/available/cert-manager.yaml
            modified:   apps/available/chisel-client.yaml
            modified:   apps/available/external-dns-cloudflare.yaml
            modified:   apps/available/external-dns-ovh.yaml
            modified:   apps/available/ingresses.yaml
            modified:   apps/available/sish.yaml
            modified:   packages/argocd/argocd-cm.yaml
            modified:   packages/argocd/autocloud-cm.yaml
            modified:   packages/cert-manager/letsencrypt-issuer.yaml
            modified:   packages/cloudflare-client/deployment.yaml
            modified:   packages/external-dns-cloudflare/external-dns-configmap.yaml
            modified:   packages/external-dns-cloudflare/external-dns-secret.yaml
            modified:   packages/external-dns-ovh/external-dns-configmap.yaml
            modified:   packages/external-dns-ovh/external-dns-secret.yaml
            modified:   packages/ingresses/argocd-ingress-cloudflare.yaml
            modified:   packages/ingresses/argocd-ingress.yaml
            modified:   packages/sish-client/sish-client.yaml

    no changes added to commit (use "git add" and/or "git commit -a"
    PS> git commit -a -m "🔧 Applied platform values to applications and packages"
    PS>
    ```

## Selecting the applications to deploy at bootstrap

To understand how the cluster is bootstrapped, please read the relevant section
in the [Architecture page](../architecture.md#cluster-bootstrapping-and-stages).

What we will do for now is just add or remove the symbolic links to applications
manifests in the `apps/bootstrap` and `apps/default` directories to accommodate
our setup.

Taking K3s as an example, it provides out of the box the load balancer, storage
class, metrics and ingress controller. In consequence, we don't need to deploy
`uninode` nor `traefik`. We will remove them from the bootstrap stage in the
`apps/appstage-00-bootstrap` directory:

=== "Shell"

    ```bash
    $ rm apps/appstage-00-bootstrap/{traefik,uninode}.yaml
    $
    ```

=== "PowerShell"

    ```powershell
    PS> @('traefik', 'uninode') | % { remove-item apps\appstage-00-bootstrap\$_.yaml }
    PS>
    ```

!!! info

    The advantage of starting from a _naked_ cluster is that the base services
    are managed by Argo CD and can be updated with gitops.

In K3s, traefik is installed in the `kube-system` namespace while `uninode`
installs it in the `traefik` namespace. In consequence, we need to adapt the
domain names of the tunnels redirections:

```diff
--- a/packages/cloudflare-client/deployment.yaml
+++ b/packages/cloudflare-client/deployment.yaml
@@ -10,7 +10,7 @@ data:
     credentials-file: /credentials/credentials.json
     ingress:
     - hostname: "*.klasmik.com"
-      service: http://traefik.traefik.svc:80
+      service: http://traefik.kube-system.svc:80
     - service: http_status:404
 ---
 apiVersion: v1
--- a/packages/sish-client/sish-client.yaml
+++ b/packages/sish-client/sish-client.yaml
@@ -37,7 +37,7 @@ data:
       ServerAliveInterval 10
       ServerAliveCountMax 2
       RemoteCommand sni-proxy=true
-      RemoteForward argocd-devenv.develop.cx:443 traefik.traefik.svc:443
+      RemoteForward argocd-devenv.develop.cx:443 traefik.kube-system.svc:443
   known_hosts: |
     [develop.cx]:2222 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+3abW2y3T5dodnI5O1Z/2KlIdH3bwnbGDvCFf13zlh
 ---
```

Once you have committed your changes and pushed the branch, proceed to the
[Cluster deployment:material-arrow-right:](../5-cluster-deployment).

<!-- prettier-ignore-start -->

[github-oauth-apps]: https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app
[github-pat-docs]: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
[Argo CD webhook documentation]: https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/
[cloudflared-install-page]: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/#1-download-and-install-cloudflared
[sish]: https://github.com/antoniomika/sish
[deploy key]: https://docs.github.com/en/developers/overview/managing-deploy-keys#deploy-keys)
[argocd-user-management]: https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/
<!-- prettier-ignore-end -->
