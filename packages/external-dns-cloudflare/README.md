# External DNS with Cloudflare configuration

[External DNS] automatically creates DNS entries for services and ingresses on
most popular DNS providers. This kustomization deploys it to work with OVH.

There is also a kustomization that [works with OVH](../external-dns-ovh/). The
present kustomization takes it as a base.

This kustomization works with **one** dns zone that can be configured with a KRM
function before commit. External DNS is configured to manage DNS entries with
TXT DNS records.

## Credentials

The Cloudflare API requires two elements:

-   Account email
-   API key

The API key can be created in you
[Cloudflare profile page](https://dash.cloudflare.com/profile/api-tokens).

You create these from an OVH account at the following address:
https://www.ovh.com/auth/api/createToken

The account email goes into `values/_properties.yaml` in the `cloudflare`
section, along with the domain zone to manage:

```yaml
cloudflare:
    email: antoine@openance.com
    dnsZone: autokube.net
```

The API key goes into `secrets/secrets.yaml`:

```yaml
cloudflare:
    apiKey: e...
```

[The secrets README](../../secrets/README.md) provides information on how to
edit the file.

The unencrypted credentials (i.e. API key and dns zone) are applied to the
kustomization before the commit with the following command:

```console
> kustomize fn run --enable-exec --fn-path values packages/external-dns-cloudflare
```

Please go to the [Values README](../../values/README.md) for more information.

<!-- prettier-ignore-start -->
[External DNS]: https://github.com/kubernetes-sigs/external-dns
<!-- prettier-ignore-end -->
