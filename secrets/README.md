# Secrets Kustomization

## Rationale

Secrets management in gitops is not simple. There are, among others, several
techniques:

-   Having [sops] or [sealed secrets] encrypted secret files in the packages
    configuration.
-   Having replacement patterns in the source files and a tool to replace them
    with the actual secret.

Having secrets, encrypted or by reference spread in all the kustomizations makes
the whole platform harder to maintain. Having replacement markers, would they be
comments or Urls, is considered a [bad practice].

The objectives we pursue with this kustomization are the following:

-   Have all the actual secrets centralized in one place (this kustomization).
-   Keep the _overlay_ principle of kustomize. That means having plain _fake_
    secrets in `packages/*` and `applications/*`.
-   Provide a way to replace the secrets with the actual values when building
    the configurations. This is done through the kustomize plugin [krmfnsops].

So all secrets (api keys, client secrets, ...) present in secrets resources of
the packages available in `packages/*`are actually fake secrets. When the secret
is a password, it is simply `password`.

The basic workflow with this kustomization when using secrets is the following:

-   Decrypt the secrets file.
-   Add the secret to the file.
-   Encrypt the secret file.
-   On the kustomization where the secret is used, import the secrets and make
    the replacement of the dumb secret with the actual secret.

## Pre-requisites

-   [sops]
-   [age]
-   [krmfnsops]

**TODO** Add some link to the actual setup documentation (mkdocs).

## Usage

When a package needs a secret, decypher the secrets with the command:

```console
> sops -d secrets/secrets.yaml > secrets.dec.yaml
```

Add the secret to the `secrets.dec.yaml` file. You can use hierarchy:

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
> sops -e  secrets/secrets.dec.yaml > secrets/secrets.yaml
> rm -f secrets/secrets.dec.yaml
```

**NOTE:** `secrets/secrets.dec.yaml` is in `.gitignore`, so there is little risk
that you commit the unencrypted file. However, keeping the unencrypted file on
your disk is a security risk.

In the kustomization package where the secret is being used, you need to do
three additions:

-   Import the secrets
-   Make the replacements
-   Remove the secrets

Example:

```yaml
# Import platform secrets. krmfnsops will decrypt them.
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
configuration cannot be applied to Kubernetes as it would contains an unknown
resource:

```yaml
apiVersion: autocloud.config.kaweezle.com/v1alpha1
kind: PlatformSecrets
```

## Possible evolutions

-   [ ] Have several secret files, one per concern (OVH, Cloudflare, ...). Would
        also allow to use different encryption keys.

<!-- prettier-ignore-start -->

[sops]: https://github.com/mozilla/sops
[sealed secrets]: https://github.com/bitnami-labs/sealed-secrets
[age]: https://github.com/FiloSottile/age
[krmfnsops]: https://github.com/kaweezle/krmfnsops
[bad practice]: https://github.com/GoogleContainerTools/kpt/issues/3131
<!-- prettier-ignore-end -->
