---
hide:
- navigation
---

# About

Puro2 is a powerful tool for installing and upgrading [Flutter](https://flutter.dev/) versions, it is essential for
developers that work on multiple projects or have slower internet.

Puro2 is a community-maintained fork of [Puro](https://github.com/pingbird/puro), originally created by pingbird.
It is maintained by [phntm](https://github.com/phntmxyz) and is not affiliated with or endorsed by the original author.

With Puro2 you can:

* Use different versions of Flutter at the same time
{ ^ .star-list }
* Download new versions twice as fast with significantly less disk space and internet bandwidth
* Use versions globally or per-project
* Automatically configure IDE settings with a single command

## Installation

=== "Windows"

    Puro2 can be installed on Windows with PowerShell (as your current user, **do not use administrator**):

    ```ps1
    Invoke-WebRequest -Uri "https://github.com/phntmxyz/puro2/releases/latest/download/puro2-windows-x64.exe" -OutFile "$env:temp\puro2.exe"; &"$env:temp\puro2.exe" install-puro2 --promote
    ```

    Or as a standalone executable (not recommended):

    [:material-console: Standalone](https://github.com/phntmxyz/puro2/releases/latest/download/puro2-windows-x64.exe){ .md-button }

    ---
        
    note: Flutter requires [git](https://git-scm.com/) which can be installed at [https://git-scm.com/download/win](https://git-scm.com/download/win)

=== "Linux"

    Puro2 can be installed on Linux with the following command:

    ```sh
    curl -o- https://puro2.phntm.xyz/install.sh | bash
    ```

    Or as a standalone executable (not recommended):

    [:material-console: Standalone](https://github.com/phntmxyz/puro2/releases/latest/download/puro2-linux-x64){ .md-button }

    ---

    note: Flutter requires [git](https://git-scm.com/) which can be installed with most package managers e.g. apt:

    ```sh
    sudo apt install git
    ```

=== "Mac"

    Puro2 can be installed on Mac with the following command:

    ```sh
    curl -o- https://puro2.phntm.xyz/install.sh | bash
    ```

    Or as a standalone executable (not recommended):

    [:material-console: Standalone](https://github.com/phntmxyz/puro2/releases/latest/download/puro2-darwin-arm64){ .md-button }

    ---

    note: Flutter requires [git](https://git-scm.com/) which can be installed with [Homebrew](https://brew.sh/) for macOS:

    ```sh
    brew install git
    ```

<script src="/javascript/os_detect.js"></script>

## Quick Start

After installing Puro2 you can run `puro2 flutter doctor` to install the latest stable version of Flutter, if you want to
switch to beta you can run `puro2 use -g beta` and then `puro2 flutter doctor` again.

And that's it, you're ready to go!

Puro2 uses the concept of "environments" to manage Flutter versions, these can either be tied to a specific version /
release channel, or a named environment that can be upgraded independently.

Environments can be set globally or per-project, the global environment is set to `stable` by default.

Cheat sheet:

```
# Create a new environment "foo" with the latest stable release
puro2 create foo stable

# Create a new environment "bar" with with Flutter 3.13.6
puro2 create bar 3.13.6

# Switch "bar" to a specific Flutter version
puro2 upgrade bar 3.10.6

# List available environments
puro2 ls

# List available Flutter releases
puro2 releases

# Switch the current project to use "foo"
puro2 use foo

# Switch the global default to "bar"
puro2 use -g bar

# Remove puro2 configuration from the current project
puro2 clean

# Delete the "foo" environment
puro2 rm foo

# Run flutter commands in a specific environment
puro2 -e foo flutter ...
puro2 -e foo dart ...
puro2 -e foo pub ...
```

See the full command list at https://puro2.phntm.xyz/reference/manual/

## Performance

Puro2 implements a few optimizations that make installing Flutter as fast as possible.
First-time installations are 20% faster while improving subsequent installations by a whopping 50-95%:

![](assets/install_time_comparison.svg)

This also translates into much lower network usage:

![](assets/network_usage_comparison.svg)

## How it works

Puro2 achieves these performance gains with a few smart optimizations:

* Parallel git clone and engine download
* Global cache for git history
* Global cache for engine versions

With other approaches, each Flutter repository is in its own folder, requiring you to download and store the git history, engine, and framework of each version:

![](assets/storage_without_puro.png)

Puro2 implements a technology similar to GitLab's [object deduplication](https://docs.gitlab.com/ee/development/git_object_deduplication.html) to avoid downloading the same git objects over and over again. It also uses symlinks to share the same engine version between multiple installations:

![](assets/storage_with_puro.png)
