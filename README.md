# autocloud

[![stability-wip](https://img.shields.io/badge/stability-wip-lightgrey.svg)](https://github.com/mkenney/software-guides/blob/master/STABILITY-BADGES.md#work-in-progress)
[![stability-experimental](https://img.shields.io/badge/stability-experimental-orange.svg)](https://github.com/mkenney/software-guides/blob/master/STABILITY-BADGES.md#experimental)

Collection of Kustomizations, Helm Charts and Helmfiles to deploy a personal
developer platform.

## Platform properties

The `values.yaml` file provides a convenient way to apply platform wide
properties to the different elements of the repository.

Instead of having Helm charts with templates hard to read and maintain, we keep
simple kustomizations and provides structural transformations to modify them.

The structural transformations are performed by [KRM functions], and in
particular by [krmfnbuiltin] that provides all kustomize builtin transformations
and more.

The customization works with the following elements:

-   A `values.yaml` KRM resource file that contains the global properties of the
    platform.
-   A set of transformers configurations performing replacements of existing
    values with the ones coming from `values.yaml`. Those configurations are
    present in each package (`*-values-replacements.yaml` file) and in the
    `apps/functions` directory.

With this, the workflow is the following:

-   Fork this repository or create a branch.
-   Edit the `values.yaml` and change the properties according to the desired
    configuration. In particular, change the `git.repoURL` and
    `git.targetRevision` properties.
-   Edit the `secrets/secrets.yaml` file accordingly (see the [secrets README]).
-   Apply the configuration with the following commands:

```console
> kustomize fn run --enable-exec apps
> # Or do it on individual packages (packages/one, ...)
> kustomize fn run --enable-exec packages
```

-   Commit the current modifications:

```console
> git add -A && git commit -m "Apply new platform properties"
```

And then from this point select the ArgoCD applications to install.

## Defining properties

Let's look at the `values.yaml` file header part:

```yaml
# values.yaml
apiVersion: autocloud.config.kaweezle.com/v1alpha1
# Non standard kind to prevent application to a kubernetes cluster
kind: PlatformValues
metadata:
    # We will use this name to "source" replacement values
    name: autocloud-values
    annotations:
        # Remove this at the end of the transformation
        config.kaweezle.com/local-config: 'true'
        # Tells krmfnbuiltin to inject this resource in the transformation
        config.kaweezle.com/inject-local: 'true'
        # Tells kustomize to use krmfnbuiltin as KRM function
        config.kubernetes.io/function: |
            exec:
              path: krmfnbuiltin
data:
```

It has a non standard kind `PlatformValues`. This will prevent it to be applied
by mistake to a cluster. The `config.kubernetes.io/function` annotation tells
kustomize to pipe the resources through [krmfnbuiltin].
`config.kaweezle.com/inject-local` tells [krmfnbuiltin] to just _inject_ the
contents of this configuration in the output so that the following
transformations can reference it. Last, `config.kaweezle.com/local-config`
annotation will allow us in the `zz_cleanup.yaml` transformations to remove the
properties from the resources before saving them back to the directory.

Now let's look at de `data` part of the file:

```yaml
data:
data:
  cluster:
    id: autocloud
    uninode: true
    ...
  git:
    repoURL: https://github.com/antoinemartin/autocloud.git
    targetRevision: main
  github:
    organization: ...
    ...
  cloudflare:
    ...
  ovh:
    ...
  sish:
    ...
  chisel:
    ...
```

You have several sections with some identifiers defined for each of them.
Ideally, each property here is only defined once. You may use anchors if needed.

## Applying the properties

The properties are applied to a directory with the following command:

```console
> # on the root directory
> kustomize fn run --enable-exec DIR
```

Kustomize will apply the functions present in the `DIR` directory to itself,
recursively.

### IMPORTANT: Avoiding directories and files

`kustomize fn run` tries to interpret all files visited as KRM resources. But
Helm Charts are not compliant, as well as some other files (patches...). It also
reformats the files, and in particular remove blank lines. That's something that
we don't want for instance with `kustomization.yaml` files.

You can prevent a file or directory from being taken into account by adding it
in `apps/.krmignore` or `packages/.krmignore`:

```gitignore
# packages/.krmignore
# Don't process kustomization and schema files
kustomization.yaml
# Helm Charts
sish/
# Extra
cert-manager/cert-manager.yaml
```

Also, kustomize loads all resources before processing them. If two files contain
a resource with the same id, it will complain that the resource has been added
twice. In that case, first try to change the name of one of the resources. If
this is not possible, add one of the files to `.krmignore`.

## Writing package replacements

When you add a package configuration to the project, it is convenient to provide
at the same time a replacement transformer configuration in order to allow
others to simply branch and customize the project.

The file containing the configuration should be named
`*-values-replacements.yaml`.

Your replacement function configuration should start with the following:

```yaml
# Selecting transformer kind in krmfnbuiltin
apiVersion: builtin
kind: ReplacementTransformer
metadata:
    # be a good KRM citizen, give it an explicit name
    name: argocd-replacement-transformer
    annotations:
        # Without this annotation, kustomize fn run will skip this function
        config.kubernetes.io/function: |
            exec:
              path: krmfnbuiltin
replacements:
```

Then it contains the structured replacements from the properties. Example:

```yaml
- source:
      name: autocloud-values
      fieldPath: data.github.clientID
  targets:
      - select:
            kind: ConfigMap
            name: argocd-cm
        fieldPaths:
            - data.dex\.config.!!yaml.connectors.[id=github].config.clientID
```

In the above, we get the `data.github.clientID` from the `values.yaml` file and
_inject_ it in the Argo CD config map. If the value is `myid`, the
`packages/argocd/argocd-cm.yaml` file would be modified:

```yaml
dex.config: |
    connectors:
      # GitHub example
      - type: github
        id: github
        name: GitHub
        config:
          clientID: myid    # <--------- The change is here
          clientSecret: $dex.github.clientSecret
```

Please go to the [krmfnbuiltin documentation] for details.

### Replacement guidelines

-   **All** replacements are performed each time the `kustomize fn run` command
    is applied. In consequence, keep your `targets` as specific as possible. If
    needed, you can add `annotationSelector` to select the proper resource kind
    subset (see [applications.yaml](apps/functions/applications.yaml) for
    instance).
-   [krmfnbuiltin] provides an extended `ReplacementTransformer` that can make
    complex replacements like regexp replacements in embedded yaml content
    (`data.someValue.!!yaml.some.property.!!regex.property=(\S+).1`). However,
    these are hard to understand. It may be better to extract the value in a
    config map and inject it in some other way (env variable...)

<!-- prettier-ignore-start -->
[krmfnbuiltin documentation]: https://github.com/kaweezle/krmfnbuiltin#extended-replacement-in-structured-content
[krmfnbuiltin]: https://github.com/kaweezle/krmfnbuiltin
[KRM functions]: https://kubectl.docs.kubernetes.io/guides/extending_kustomize/exec_krm_functions/
[secrets README]: ../secrets/README.md
<!-- prettier-ignore-end -->
