# Change the secrets encryption key

The secrets on the main branch are fake secrets ciphered by a _known key_
located at the root of the project with the name `sample_age_key.txt`. You may
want to use it for testing but it's better to change the key **before** playing
with the secrets file.

Start by making the _known key_ known to sops by putting it in its well-known
location:

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
    other key that SOPS understands. Check the [SOPS documentation]{:target="\_blank"}.
    You can also add other type of keys later on. We recommend to continue to
    use Age at this stage.

Then you need to create your own key:

=== "Shell"

    ```bash
    $ age-keygen >> ~/.config/sops/age/keys.txt
    Public key: age1...
    ```

=== "PowerShell"

    ```powershell
    ...
    PS> age-keygen >> $env:APPDATA\sops\age\keys.txt
    Public key: age1...
    ```

To replace the secrets encryption, use the public key of your new key with the
following command:

=== "Shell"

    ```bash
    $ find . -name 'secrets.yaml' -exec sops -r -i \
    > --add-age age1... \
    > --rm-age age166k86d56ejs2ydvaxv2x3vl3wajny6l52dlkncf2k58vztnlecjs0g5jqq \
    > {} \;
    ```

=== "PowerShell"

    ```powershell
    ...
    PS> Get-ChildItem . -Filter 'secrets.yaml' -Recurse | `
    > % { &sops '-r' '-i' `
    > '--add-age' age1... `
    > '--rm-age' age1fs48f8rw9gj49ss5fapsy8euqln0dtrc5yg35fuq7c930jtkveps2swvt6 `
    > $_.FullName }
    ```

At this point, you can delete the known key on your branch and commit the
modifications

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

!!! warning

    From now on, you should forget the old key and make sure that you keep the
    new key safe.

    To remove the old key from the SOPS configuration:


    === "Shell"

        ```bash
        >  sed -i -e '1,3 d' ~/.config/sops/age/keys.txt
        ```

    === "PowerShell"

        ```PowerShell
        PS> Get-Content $env:APPDATA\sops\age\keys.txt | Select-Object -Skip 3 `
        > | Set-Content $env:APPDATA\sops\age\keys.txt
        ```

    You should consider saving the new key, in something like gopass for instance.

<!-- prettier-ignore-start -->

<!-- markdownlint-disable-line -->[SOPS documentation]: https://github.com/mozilla/sops

<!-- prettier-ignore-end -->
