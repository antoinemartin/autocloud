# Secrets Kustomization

## Rationale

Having secrets, encrypted or by reference spread in all the kustomizations makes
the whole platform harder to maintain. Having replacement markers, would they be
comments or Urls, is considered a [bad practice].

The idea is to provide a centralized management of secrets while keeping the
_overlay_ principle of kustomize.

So apart from external services credentials, all secrets present are actually
working `password1234` like credentials.

The objectives we pursue with this kustomization are the following:

- Have plain _dumb_ secrets in `packages/*` and `applications/*`.
- Have all the actual secrets located in one place (this kustomization).
- Provide a way to replace the secrets with the actual values when building the
  configurations.

The basic workflow with this kustomization when using secrets is the following:

- Decrypt the secrets file.
- Add the secret to the file.
- Encrypt the secret file.
- On the kustomization where the secret is used, import the secrets.
- Make the replacement of the dumb secret with the actual secret.

## Pre-requisites

- [sops]
- [age]
- [krmfnsops]

**TODO** Add some link to the actual setup documentation (mkdocs).

## Usage

When a package needs a secret, decypher the secrets with the command:

```console
> sops -d -i secrets/secrets.yaml
```

Add the secret to the file. You can use hierarchy:

```yaml
apiVersion: autocloud.config.kaweezle.com/v1alpha1
kind: PlatformSecrets
metadata:
  name: autocloud-secrets
  annotations:
    config.kubernetes.io/function: |
      exec:
        path: krmfnsops
data:
  cloudflare:
    credentials.json: |
      ...
  ovh:
    application_secret: ...
    consumer_key: ...
```

Encrypt the file:

```console
> sops -e -i secrets/secrets.yaml
```

In the package where the secret is being used, you need to do three additions:

- Import the secrets
- Make the replacements
- Remove the secrets

Example:

```yaml
# Import decoded platform secrets
generators:
  - ../../secrets

# Replace secrets in configuration
replacements:
  - source:
      name: autocloud-secrets
      fieldPath: data.cloudflare.credentials\.json
    targets:
      - select:
          kind: Secret
          name: cloudflared
        fieldPaths:
          - stringData.credentials\.json

# Remove secrets
transformers:
  - ../../secrets/remove
```

**Remark:** If you forget the removal part of the kustomization, your
configuration will be rejected by Kubernetes as it would contains an unknown
resource:

```yaml
apiVersion: autocloud.config.kaweezle.com/v1alpha1
kind: PlatformSecrets
```

## Possible evolutions

- [ ] Have several secret files, one per concern (OVH, Cloudflare, ...). Would also allow to use different encryption keys.

<!-- prettier-ignore-start -->

[sops]: https://github.com/mozilla/sops
[age]: https://github.com/FiloSottile/age
[krmfnsops]: https://github.com/kaweezle/krmfnsops
[bad practice]: https://github.com/GoogleContainerTools/kpt/issues/3131
<!-- prettier-ignore-end -->
