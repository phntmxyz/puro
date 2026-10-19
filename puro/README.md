# About

Puro2 is a powerful tool for installing and upgrading [Flutter](https://flutter.dev/) versions, it is essential for any
developers that work on multiple projects or have slower internet.

Puro2 is a community-maintained fork of [Puro](https://github.com/pingbird/puro), originally created by pingbird.
It is maintained by [phntm](https://github.com/phntmxyz) and is not affiliated with or endorsed by the original author.

With Puro2 you can:

* Use different versions of Flutter at the same time
* Download new versions twice as fast with significantly less disk space and internet bandwidth
* Use versions globally or per-project
* Automatically configure IDE settings with a single command

## Installation

Puro2 is distributed as a precompiled executable (you do not need Dart installed), see the quick installation
instructions at https://puro2.phntm.xyz/

## Quick start

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

![](https://puro2.phntm.xyz/assets/install_time_comparison.svg)

This also translates into much lower network usage:

![](https://puro2.phntm.xyz/assets/network_usage_comparison.svg)

## How it works

Puro2 achieves these performance gains with a few smart optimizations:

* Parallel git clone and engine download
* Global cache for git history
* Global cache for engine versions

With other approaches, each Flutter repository is in its own folder, requiring you to download and store the git history, engine, and framework of each version:

![](https://puro2.phntm.xyz/assets/storage_without_puro.png)

Puro2 implements a technology similar to GitLab's [object deduplication](https://docs.gitlab.com/ee/development/git_object_deduplication.html) to avoid downloading the same git objects over and over again. It also uses symlinks to share the same engine version between multiple installations:

![](https://puro2.phntm.xyz/assets/storage_with_puro.png)
