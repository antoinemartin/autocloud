# Environment adaption

## Secrets

The following table gives a summary of the current secrets and their purpose:

<!-- markdownlint-disable MD013 -->

| Secrets file                                         | Secret                                        | Secret key           | Purpose                  |
| ---------------------------------------------------- | --------------------------------------------- | -------------------- | ------------------------ |
| **packages/argocd/secrets.yaml** {: rowspan=9}       | github-private-repo-creds {: rowspan=4}       | `type`               | Type of credential (git) |
| `url`                                                | Base URL of repositories (https://github.com) |
| `username`                                           | Username (not used if token)                  |
| `password`                                           | Github Token                                  |
| argocd-sops-private-keys                             | `age_key.txt`                                 | Private AGE key      |
| argocd-secret {: rowspan=4}                          | `admin.password`                              | Local admin password |
| `admin.passwordMtime`                                | Password modification time (required)         |
| `webhook.github.secret`                              | Secret sent by github webhooks                |
| `dex.github.clientSecret`                            | OIDC github application secret                |
| **packages/cert-manager/secrets.yaml** {: rowspan=2} | ovh-api-credentials {: rowspan=2}             | `application_secret` | OVH application secret   |
| `consumer_key`                                       | OVH consumer key                              |
| **packages/chisel-client/secrets.yaml**              | chisel-client-auth                            | `AUTH`               | chisel auth with server  |
| **packages/sish-client/secrets.yaml**                | sish-ssh-credentials                          | `id_rsa`             | SSH private key          |

<!-- markdownlint-enable MD013 -->

### Change the bootstrap application Helm chart values

## `targetRevision` in applications
