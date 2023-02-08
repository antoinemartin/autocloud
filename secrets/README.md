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

-   Have all the actual secrets centralized and encrypted in one place (this
    kustomization, and in particular the `secrets.yaml` file).
-   Keep the _overlay_ principle of kustomize. That means that before
    kustomization, all the package resources, including secrets, are actual
    resources containing actual values, not placeholders. The only thing is that
    the secrets resources contain _fake_ secrets.
-   Provide a way to replace the secrets with the actual values when building
    the configurations. This is done through the kustomize plugin
    [krmfnbuiltin].

So all secrets (api keys, client secrets, ...) present in secrets resources of
the packages available in `packages/*`are actually **fake secrets**. When the
secret is a password, it is simply `password`.

The basic workflow with this kustomization when using secrets is the following:

-   Decrypt the secrets file.
-   Add the secret to the file.
-   Encrypt the secret file.
-   On the kustomization where the secret is used, use the `krmfnbuiltin`
    `ReplacementTransformer` with this kustomization as `source` to replace the
    fake secret by the actual secret.

## Pre-requisites

-   [sops]
-   [age]
-   [krmfnbuiltin]

### Encryption key setup

The following script shows how to create an new key for secrets encryption and
replace the sample key:

```bash
# Create a directory to contain keys
mkdir -p  ~/.config/sops/age
# Copy the sample key
cp sample_age_key.txt >~/.config/sops/age/keys.txt
# Generate a new key
age-keygen >>~/.config/sops/age/keys.txt
# get keys recipients
OLDRECIPIENT=$(age-keygen -y ~/.config/sops/age/keys.txt | head -1)
NEWRECIPIENT=$(age-keygen -y ~/.config/sops/age/keys.txt | tail -1)
# rotate keys
 for f in secrets/secrets.yaml secrets/helm/*; do
    sops -r -i --add-age $NEWRECIPIENT --rm-age $OLDRECIPIENT $f
done
# set new recipient when encrypting
sed -i -e "s/age: .*/age: $NEWRECIPIENT/" .sops.yaml
# remove old key
rm sample_age_key.txt
sed -i -e '1,3 d' ~/.config/sops/age/keys.txt
# commit modifications
git add -A && git commit -m "Changed encryption key"
```

## Usage

When a package needs a secret, decrypt the secrets file with the command:

```console
> sops -d secrets/secrets.yaml > secrets.dec.yaml
```

Add the secret to the `secrets.dec.yaml` file. You can use hierarchy:

```yaml
# secrets/secrets.yaml
apiVersion: autocloud.config.kaweezle.com/v1alpha1
kind: SopsGenerator
metadata:
    name: autocloud-secrets
    annotations:
        config.kubernetes.io/function: |
            exec:
              path: krmfnbuiltin
data:
    cloudflare:
        credentials.json: |
            ...
    ovh:
        application_secret: ...
        consumer_key: ...
```

Encrypt the file and remove the unencrypted file:

```console
> sops -e  secrets/secrets.dec.yaml > secrets/secrets.yaml
> rm -f secrets/secrets.dec.yaml
```

**NOTE:** `secrets/secrets.dec.yaml` is in `.gitignore`, so there is little risk
that you commit the unencrypted file. However, keeping the unencrypted file on
your disk is a security risk.

You can check that everything is ok by building the kustomization. It should
give you the unencrypted secrets provided the right key is present in
`~/.config/sops/age/keys.txt`:

```console
> kustomize build --enable-alpha-plugins --enable-exec secrets # unencrypted secrets will follow
apiVersion: config.kaweezle.com/v1alpha1
data:
  argocd:
  ...
```

In the kustomization package where the secret is being used, you need to:

-   Create a `krmfnbuiltin` `ReplacementTransformer` configuration to inject the
    secrets at the right place.
-   Add this transformer configuration to the `transformers:` section of your
    `kustomization.yaml` file

This is for example the secrets injection for the cloudflare client
kustomization:

```yaml
# packages/cloudflare-client/cloudflare-client-secrets-replacements.yaml
apiVersion: krmfnbuiltin.kaweezle.com/v1alpha1 # <-- avoid builtin
kind: ReplacementTransformer
metadata:
    name: cloudflare-client-secrets-replacements
    annotations:
        config.kubernetes.io/function: |
            exec:
              path: krmfnbuiltin
source: ../../secrets # <-- source kustomization. Secrets will come unencrypted from it.
replacements:
    # These are the replacements
    - source:
          name: autocloud-secrets
          fieldPath: data.cloudflare.credentials\.json
      targets:
          - select:
                kind: Secret
                name: cloudflared
            fieldPaths:
                - stringData.credentials\.json
```

And how it is integrated:

```yaml
# kustomization.yaml
transformers:
    - cloudflare-client-secrets-replacements.yaml
```

**Remark:** To keep the transformation for building and avoid kustomize picking
it while doing `kustomize fn run`, add the file to `.krmignore`:

```ignore
#.krmignore
*-secrets-replacements.yaml
```

## Possible evolutions

-   [ ] Have several secret files, one per concern (OVH, Cloudflare, ...). Would
        also allow to use different encryption keys.

<!-- prettier-ignore-start -->

[sops]: https://github.com/mozilla/sops
[sealed secrets]: https://github.com/bitnami-labs/sealed-secrets
[age]: https://github.com/FiloSottile/age
[krmfnbuiltin]: https://github.com/kaweezle/krmfnbuiltin
[bad practice]: https://github.com/GoogleContainerTools/kpt/issues/3131
<!-- prettier-ignore-end -->
