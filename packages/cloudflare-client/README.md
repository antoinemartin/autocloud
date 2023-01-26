# Cloudflare tunnel client

This kustomization deploys a
[cloudflare tunnel client](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/).

## Pre-requisites

-   A cloudflare account
-   A domain name registered with Cloudflare.

In the following, we will assume that the name of the tunnel is `citest` and the
domain name `autokube.net`.

## Getting started

To setup your tunnel, you can follow
[this guide](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/).

To summarize:

```console
> apk add cloudflared
> cloudflared tunnel login
> cloudflared tunnel create citest
> cloudflared tunnel route dns citest citest.autokube.net
```

At this point, a file named `~/.cloudflared/<UUID>.json`, `<UUID>` being the
identifier of the tunnel has been created. In the following, we will assume that
it is `84857ed2-8b07-461a-a4eb-486409328bce`.

The contents of this JSON file will be the secret you use to connect to the
tunnel:

<!-- prettier-ignore-start -->

```json
{"AccountTag":"a54f6b2557d54a9bff5eef36482b7fe6","TunnelSecret":"...","TunnelID":"84857ed2-8b07-461a-a4eb-486409328bce"}
```

<!-- prettier-ignore-end -->

## configuration

### Adding the secret

You need to add the secret in `secrets/secret.yaml` file, under the key
`cloudflare.credentials\.json`:

```yaml
cloudflare:
    credentials.json: ...
```

Please refer to the secrets [README](../../secrets/README.md).

### Configmap configuration

At the beginning of the `deployment` file, you need to adapt the configuration
to your tunnel Id and domain name:

```yaml
data:
    config.yaml: |
        tunnel: 84857ed2-8b07-461a-a4eb-486409328bce
        credentials-file: /root/.cloudflared/credetials.json

        ingress:
        - hostname: "*.autokube.net"
          service: http://traefik.traefik.svc:80
        - service: http_status:404
```

## TODO

-   [ ] Provide a terraform module to create the tunnel.
-   [ ] Profinde a KRM function pipeline to personalize the tunnel id and domain
        name
