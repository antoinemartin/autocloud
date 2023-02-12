# Change the secrets encryption key

All the platform secrets are located in the `secrets/secrets.yaml` and encrypted
with [sops :material-open-in-new:]{:target="\_blank"}.

On the main branch this file is encrypted by a _sample age key_ located at the
root of the project (`sample_age_key.txt`) and contains fake secrets. While you
can use this sample key for testing, it's better to change it **before** doing
anything with the secrets file.

Start by making the _sample age key_ reachable to sops by putting it in its
well-known location:

=== "Shell"

    ```bash
    $ mkdir -p ~/.config/sops/age
    $ cat sample_age_key.txt >> ~/.config/sops/age/keys.txt
    ```

=== "PowerShell"

    ```powershell
    PS> New-Item -Path $env:APPDATA\sops\age -ItemType Directory
    PS> Copy-Item .\sample_age_key.txt $env:APPDATA/sops/age/keys.txt
    ```

!!! note

    The following shows a rotation with a new Age key. Note that you can use any
    other key that sops understands. Check the [sops documentation:material-open-in-new:]{:target="\_blank"}.
    You can also add other type of keys later on. We recommend to continue to
    use age at this stage.

Then create your own key:

=== "Shell"

    ```bash
    $ age-keygen >> ~/.config/sops/age/keys.txt
    Public key: age1...
    ```

=== "PowerShell"

    ```powershell
    PS> age-keygen >> $env:APPDATA\sops\age\keys.txt
    Public key: age1...
    ```

??? tip "Derive the age key from a ssh key"

    The age key can be derived from a ssh key. This is convenient as a SSH key
    may be used to access the repository.

    The [ssh-to-age] project provides a command to convert an existing ed25519
    ssh key into a valid age key:

    ```bash
    $ go install github.com/Mic92/ssh-to-age/cmd/ssh-to-age@latest
    $ ssh-to-age -private-key -i ~/.ssh/id_ed25519 >> ~/.config/sops/age/keys.txt
    $ NEWKEY=$(ssh-to-age -i ~/.ssh/id_ed25519.pub)
    ```

    Note that at the time of this writing, there is a [PR in sops](https://github.com/mozilla/sops/pull/1134)
    adding native ssh key support to sops.

Replace the secrets encryption by using the public key of your new key
(recipient in age parlance) with the following commands:

=== "Shell"

    ```bash
    $ OLDKEY=$(age-keygen -y ~/.config/sops/age/keys.txt | head -1)
    $ NEWKEY=$(age-keygen -y ~/.config/sops/age/keys.txt | tail -1)
    $ for f in secrets/secrets.yaml secrets/helm/*; do \
    > sops -r -i \
    > --add-age $NEWKEY \
    > --rm-age $OLDKEY \
    > $f ; done
    $
    ```

=== "PowerShell"

    ```powershell
    PS> $OLDKEY=age-keygen.exe -y $env:APPDATA\sops\age\keys.txt | Select-Object -First 1
    PS> $NEWKEY=age-keygen.exe -y $env:APPDATA\sops\age\keys.txt | Select-Object -Last 1
    PS> $(ls .\secrets\secrets.yaml;ls .\secrets\helm\*) | `
    > % { &sops '-r' '-i' '--add-age' $NEWKEY '--rm-age' $OLDKEY $_.FullName }
    PS>
    ```

Now change the recipient in the `.sops.yaml` sops configuration file in order to
use the new key for encryption from now on:

=== "Shell"

    ```bash
    $ sed -i -e "s/age: .*/age: $NEWKEY/" .sops.yaml
    $
    ```

=== "PowerShell"

    ```powershell
    ...
    PS> $(get-content .\.sops.yaml | % { $_ -replace 'age: .*', "age: $NEWKEY" }) | `
    > Set-Content .\.sops.yaml
    PS>
    ```

At this point, you can delete the sample key on your branch and commit the
modifications:

=== "Shell"

    ```bash
    $ rm sample_age_key.txt
    $ git add -A
    $ git commit -m "🔐 Secrets encryption key modification"
    ```

=== "PowerShell"

    ```powershell
    ...
    PS> Remove-Item sample_age_key.txt
    PS> git add -A
    PS> git commit -m "🔐 Secrets encryption key modification"
    ```

From now on, you should forget the old key and make sure that you keep the new
key **safe**. A good idea is to save it in some kind of secure password manager
like [gopass:material-open-in-new:](https://www.gopass.pw/){:target="\_blank"}.

To remove the old key from the sops well-known location, issue the following
command:

=== "Shell"

    ```bash
    >  sed -i -e '1,3 d' ~/.config/sops/age/keys.txt
    ```

=== "PowerShell"

    ```PowerShell
    PS> Get-Content $env:APPDATA\sops\age\keys.txt | Select-Object -Skip 3 `
    > | Set-Content $env:APPDATA\sops\age\keys.txt
    ```

Test that your environment is correct by decrypting the secrets file:

=== "Shell"

    ```bash
    $ sops -d secrets/secrets.yaml > secrets/secrets.dec.yaml
    $
    ```

=== "PowerShell"

    ```powershell
    ...
    PS> sops -d secrets/secrets.yaml > secrets/secrets.dec.yaml
    PS>
    ```

!!! tip ".gitignore safe"

    the project `.gitignore` file contains the `*.dec.yaml` pattern. Therefore,
    there is no risk of committing an unencrypted secrets file as long as you
    keep it named like that.

You can also build the secrets kustomization. It will print out all the
unencrypted secrets to the terminal:

=== "Shell"

    ```bash
    $ kustomize build --enable-alpha-plugins --enable-exec secrets
    ...
    ```

=== "PowerShell"

    ```powershell
    ...
    PS> kustomize build --enable-alpha-plugins --enable-exec secrets
    ...
    ```

Now that you can manage properly secured credentials, move on to the
[environment adaptation:material-arrow-right:](../4-environment-adaptation)

<!-- prettier-ignore-start -->

[SOPS documentation:material-open-in-new:]: https://github.com/mozilla/sops
[SOPS :material-open-in-new:]: https://github.com/mozilla/sops
[ssh-to-age]: https://github.com/Mic92/ssh-to-age

<!-- prettier-ignore-end -->
