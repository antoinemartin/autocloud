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
-   The properties are applied **before** committing. The applications and
    kustomizations contain the actual property values. _Applying_ from a
    centralized file is just a convenience to ease adaptation (see the
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
        uninode: true
        dnsZone: klasmik.com
        argocd:
            domainPrefix: argocd-devenv
```

### Optional: create a deployment key

To allow Argo CD to access the private repository, you can either use a user SSH
key or a Personal Access Token. But in our case it's probably better to use a
deployment key limited to the repository.

Create a key with the following command:

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

Go to the following URL:

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

```yaml
data:
    # ...
    github:
        # ...
        ssh_key:
            -----BEGIN OPENSSH PRIVATE KEY-----
            b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
            ... SpbRCCLhgXt42GirPwlUAAAACWF1dG9jbG91ZAECAwQ= -----END OPENSSH
            PRIVATE KEY-----
```

### Optional: Create an OAuth Application for Argo CD Auth

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

### Optional: Create a webhook for Argo CD

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

## Applying properties to kustomizations and applications

## Selecting the applications to deploy at bootstrap

<!-- prettier-ignore-start -->

[OAuth application:material-open-in-new:]: https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app
[Autocloud repository]: https://github.com/antoinemartin/autocloud.git
[Argo CD webhook documentation]: https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/
[klasmik:material-open-in-new:]: https://github.com/klasmik
<!-- prettier-ignore-end -->
