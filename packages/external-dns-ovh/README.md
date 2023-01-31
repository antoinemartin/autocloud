# External DNS with OVH configuration

[External DNS] automatically creates DNS entries for services and ingresses on
most popular DNS providers. This kustomization deploys it to work with OVH.

There is also a kustomization that
[works with Cloudflare](../external-dns-cloudflare/).

This kustomization works with **one** dns zone that can be configured with a KRM
function before commit. External DNS is configured to manage DNS entries with
TXT DNS records.

## Credentials

The OVH API requires three elements:

-   Application key
-   Secret application key
-   Consumer key

You create these from an OVH account at the following address:
https://www.ovh.com/auth/api/createToken

The application key goes into `values/_properties.yaml` in the `ovh` section,
along with the domain zone to manage:

```yaml
ovh:
    applicationKey: 4KyIjUiRpDo4lpqY
    dnsZone: holepunch.in
```

The other two elements go into `secrets/secrets.yaml`:

```yaml
ovh:
    application_secret: E...
    consumer_key: l...
```

[The secrets README](../../secrets/README.md) provides information on how to
edit the file.

The unencrypted credentials (i.e. application key and dns zone) are applied to
the kustomization before the commit with the following command:

```console
> kustomize fn run --enable-exec --fn-path values packages/external-dns-ovh
```

Please go to the [Values README](../../values/README.md) for more information.

<!-- prettier-ignore-start -->
[External DNS]: https://github.com/kubernetes-sigs/external-dns
<!-- prettier-ignore-end -->
