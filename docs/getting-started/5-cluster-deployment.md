# Cluster deployment

Because this is GitOps, the bootstrapping is done by deploying what has been
pushed:

<!-- markdownlint-disable MD013 -->

=== "Shell"

    ```bash
    $ kustomize build --enable-alpha-plugins --enable-exec \
    > "https://github.com/<user>/autocloud//packages/argocd/?ref=mydeploymentbranch" \
    > | kubectl apply -f
    ```

=== "PowerShell"

    ```powershell
    PS> kustomize build --enable-alpha-plugins --enable-exec \
    > "https://github.com/<user>/autocloud//packages/argocd/?ref=mydeploymentbranch" \
    > | kubectl apply '-f'
    ```

<!-- markdownlint-enable MD013 -->
