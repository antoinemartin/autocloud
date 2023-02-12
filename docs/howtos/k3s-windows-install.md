# Install K3s on Windows

This how-to uses the alpine root filesystem of the
[Wsl-Manager](https://github.com/antoinemartin/PowerShell-Wsl-Manager) project.

## Pre-requisites

You need to have WSL working on your machine. On recent Windows (11+), issue the
command:

```powershell
PS> wsl --install
...
```

More information is available in the
[Microsoft documentation](https://learn.microsoft.com/en-us/windows/wsl/install).

## Create the WSL distribution

First download the root filesystem and create the WSL distribution:

```powershell
PS> ([System.Net.WebClient]::new()).DownloadFile("https://github.com/antoinemartin/PowerShell-Wsl-Manager/releases/latest/download/miniwsl.alpine.rootfs.tar.gz", "$PWD/alpine.tgz")
PS> wsl --import myk3s . alpine.tgz
PS>
```

## Install K3S

Connect to the WSL distribution and install K3s:

```bash
PS> wsl -d myk3s
[powerlevel10k] fetching gitstatusd .. [ok]
❯
# curl is needed
> apk add curl
...
# install K3s without starting it
>  curl -sfL https://get.k3s.io | sed -e 's/sourcex/./g' | INSTALL_K3S_SKIP_START="true" sh -
[INFO]  Finding release for channel stable
[INFO]  Using v1.25.6+k3s1 as release
[INFO]  Downloading hash https://github.com/k3s-io/k3s/releases/download/v1.25.6+k3s1/sha256sum-amd64.txt
[INFO]  Downloading binary https://github.com/k3s-io/k3s/releases/download/v1.25.6+k3s1/k3s
[INFO]  Verifying binary download
[INFO]  Installing k3s to /usr/local/bin/k3s
[INFO]  Skipping installation of SELinux RPM
[INFO]  Creating /usr/local/bin/kubectl symlink to k3s
[INFO]  Creating /usr/local/bin/crictl symlink to k3s
[INFO]  Creating /usr/local/bin/ctr symlink to k3s
[INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
[INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
[INFO]  env: Creating environment file /etc/rancher/k3s/k3s.env
[INFO]  openrc: Creating service file /etc/init.d/k3s
[INFO]  openrc: Enabling k3s service for default runlevel
```

You can now start K3s:

```bash
# start openrc. K3s will start...
> openrc default
 * Caching service dependencies ...           [ ok ]
 * Starting k3s ...                           [ ok ]
 # List nodes
 >  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
 >  kubectl get nodes
NAME              STATUS   ROLES                  AGE    VERSION
laptop-vkhdd5jr   Ready    control-plane,master   112s   v1.25.6+k3s1
# Get deployment status
> kubectl -n kube-system rollout status deployments,statefulsets,daemonsets
deployment "local-path-provisioner" successfully rolled out
deployment "coredns" successfully rolled out
deployment "traefik" successfully rolled out
deployment "metrics-server" successfully rolled out
daemon set "svclb-traefik-114ab381" successfully rolled out
>

```

## Stop K3S

To stop K3s properly, you need to use the `k3s-killall.sh` script:

```powershell
PS> wsl -d myk3s k3s-killall.sh
PS> wsl --terminate myk3s
...
```

## Re-start K3s

To restart K3s, issue the following command:

```powershell
PS> wsl -d myk3s openrc default
...
```

## Access K3s from Windows

You can run `k3s kubectl` in the WSL distribution from Windows:

```powershell
PS> wsl -d myk3s k3s kubectl get pods -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   helm-install-traefik-crd-752lw            0/1     Completed   0          11m
kube-system   helm-install-traefik-g68pt                0/1     Completed   1          11m
kube-system   traefik-66c46d954f-6bmr6                  1/1     Running     0          11m
kube-system   local-path-provisioner-79f67d76f8-wrpt4   1/1     Running     0          11m
kube-system   svclb-traefik-114ab381-c2bql              2/2     Running     0          11m
kube-system   metrics-server-5f9f776df5-pp6r6           1/1     Running     0          11m
kube-system   coredns-597584b69b-hm8qq                  1/1     Running     0          11m
PS>
```

You can also integrate the k3s config in your current configuration:

```powershell
PS> # Point to the K3s kubeconfig
PS> $env:KUBECONFIG="\\wsl$\myk3s\etc\rancher\k3s\k3s.yaml"
PS>
PS> # Check that the context is here
PS> kubectl config get-contexts
CURRENT   NAME      CLUSTER   AUTHINFO   NAMESPACE
*         default   default   default
PS>
PS> # Rename the context
PS> kubectl config rename-context default myk3s
Context "default" renamed to "myk3s".
PS>
PS># Flatten with the current configuration
PS> $env:KUBECONFIG="$env:KUBECONFIG;$env:USERPROFILE/.kube/config"
PS> kubectl config view --flatten >config.new
PS>
PS> # Check that the contexts are there
PS> $env:KUBECONFIG="$PWD\config.new"
PS> kubectl config get-contexts
CURRENT   NAME               CLUSTER                        AUTHINFO                                        NAMESPACE
...
          kaweezle           kaweezle                       kaweezle
*         myk3s              default                        default
          rancher-desktop    rancher-desktop                rancher-desktop
...
PS>
PS> # Change the hostname
PS> (Get-Content .\config.new | % { $_ -replace '127.0.0.1', 'localhost' }) | Set-Content config.new
PS>
PS> # Check everything is Ok
PS> kubectl get pods -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS      AGE
kube-system   helm-install-traefik-crd-752lw            0/1     Completed   0             42m
kube-system   helm-install-traefik-g68pt                0/1     Completed   1             42m
kube-system   svclb-traefik-114ab381-c2bql              2/2     Running     2 (32m ago)   42m
kube-system   local-path-provisioner-79f67d76f8-wrpt4   1/1     Running     1 (32m ago)   42m
kube-system   traefik-66c46d954f-6bmr6                  1/1     Running     1 (32m ago)   42m
kube-system   coredns-597584b69b-hm8qq                  1/1     Running     1 (32m ago)   42m
kube-system   metrics-server-5f9f776df5-pp6r6           1/1     Running     1 (32m ago)   42m
PS>
PS> # Move the file in the standard place
PS> Move-Item $env:USERPROFILE\.kube\config $env:USERPROFILE\.kube\config.bak
PS> Move-Item .\config.new $env:USERPROFILE\.kube\config
PS>
PS> # Use it from the standard place
PS> $env:KUBECONFIG=$null
PS>  kubectl get nodes
NAME              STATUS   ROLES                  AGE   VERSION
laptop-vkhdd5jr   Ready    control-plane,master   47m   v1.25.6+k3s1
PS>
```
