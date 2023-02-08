# Applications directory

## Configuration

### `applications.yaml`

The `applications.yaml` replacement performs the `repoURL` and `targetRevision`
in all applications that are marked with the
` autocloud/local-application: "true"` annotation.

This the transformation you want to perform after forking/branching the
repository.

You can apply it with the command:

```console
> kustomize fn run --enable-exec apps
```
