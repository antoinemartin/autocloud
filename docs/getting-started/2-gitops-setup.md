<!-- markdownlint-disable MD014 -->

# Setup the GitOps environment

!!! todo

    Provide a Terraform script for this.

Setting up you GitOps environment involves the following tasks:

-   Fork (public) or Import (private) the [Autocloud
    repository:material-open-in-new:]{:target="\_blank"} on your personal
    account or organization.
-   Create a deployment branch that will be tracked by Argo CD.

There are other tasks, potentially optional, related to te repository, but as
they involve credentials, they are covered after
[changing the encryption keys](../3-change-encryption-key) in
[the environment adaptation](../4-environment-adaptation):

-   Create a
    [deployment key:material-open-in-new:](https://docs.github.com/en/developers/overview/managing-deploy-keys){:target="\_blank"}
    on the repository if the repository is going to be private.
-   Create an [OAuth Application:material-open-in-new:]{:target="\_blank"} on
    your account or organization to allow github based authentication on Argo
    CD. This is optional.
-   Creating a
    [webhook:material-open-in-new:](https://docs.github.com/en/developers/webhooks-and-events/webhooks/about-webhooks){:target="\_blank"}
    for the repository for faster updates.

!!! info

    In the following, we are going to assume that the destination is an
    organization named [klasmik:material-open-in-new:] and that the repository,
    named `klasmikloud` is being kept private.

## Fork the repository

If you don't plan to make your repository private, fork the public [Autocloud
repository:material-open-in-new:]{:target="\_blank"} into your own account or
organization:

![fork Autocloud](../img/fork_autocloud.png)

In the case you want to make the repo private, it's better to
[import it:material-open-in-new:](https://github.com/new/import){:target="\_blank"}
instead. Click on the :material-plus::material-menu-down: icon in the top right
corner and choose _Import repository_:

![import Autocloud](../img/import_autocloud.png)

## Clone the repository and create a deployment branch

Following the
[GitOps principles:material-open-in-new:](https://github.com/open-gitops/documents/blob/main/PRINCIPLES.md){:target="\_blank"},
each deployment lives in its own branch. Clone the repository and create a
deployment branch for your development environment (replace
`klasmik/klasmikloud` with your organization and project name):

=== "Shell"

    ```bash
    $ git clone git@github.com:klasmik/klasmikloud.git
    $ cd klasmikloud
    $ git checkout -b deploy/devenv
    $
    ```

=== "PowerShell"

    ```bash
    PS> git clone git@github.com:klasmik/klasmikloud.git
    PS> cd klasmikloud
    PS> git checkout -b deploy/devenv
    PS>
    ```

Once on the proper branch, you can now continue and
[change the encryption key:material-arrow-right:](../3-change-encryption-key).

<!-- prettier-ignore-start -->

[OAuth application:material-open-in-new:]: https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app
[Autocloud repository:material-open-in-new:]: https://github.com/antoinemartin/autocloud.git
[klasmik:material-open-in-new:]: https://github.com/klasmik

<!-- prettier-ignore-end -->
