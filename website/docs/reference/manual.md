# Manual

![](/assets/puro_icon_small.png)

## Introduction

Puro2 is a powerful tool for installing and upgrading [Flutter](https://flutter.dev/) versions, it is essential for
developers that work on multiple projects or have slower internet.

### *Why do we need another version manager?*

Flutter is typically installed by cloning the flutter/flutter repository, checking out the desired version, and letting
the `bin/flutter` shell script download pre-built engine binaries. This workflow is great for people working on the
framework, but regular app developers end up downloading hundreds of megabytes more data than necessary.

Puro2 significantly improves this process by downloading both the framework code and engine in parallel, caching the
engine, and caching the git history. These optimizations result in a 20% faster initial setup (including installing
Puro2 itself) and 50-95% faster upgrades.

### Installation

Puro2 is distributed as a precompiled executable (you do not need Dart installed), see the quick installation
instructions at [https://puro2.phntm.xyz/](https://puro2.phntm.xyz/)

When you install Puro2, it places itself in `~/.puro` (`%userprofile%\.puro` on Windows) including all caches, git
repos, engine builds, configuration, etc.

Puro2 will automatically add Flutter and itself to the PATH, warning you if there are existing Dart or Flutter
installations that could interfere. A standalone version is also available if you don't want Puro2 messing with your
profile.

At most once a day, the tool will automatically check for updates and prompt you to run `puro2 upgrade-puro2` if one is
available, this can be disabled by adding `enableUpdateCheck: false` to `~/.puro/prefs.json`.

## Environments

### Listing environments

Puro2 comes with three environments by default:

```
$> puro2 ls
[i] Environments:
    * stable (not installed)
      beta   (not installed)
      master (not installed)

    Use `puro2 create <name>` to create an environment, or `puro2 use <name>` to switch
```

The asterisk next to `stable` tells us it's the global default, we can invoke it with the `puro2 flutter` command:

```
$> puro2 flutter --version
Flutter 3.7.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision b06b8b2710 (4 days ago) • 2023-01-23 16:55:55 -0800
Engine • revision b24591ed32
Tools • Dart 2.19.0 • DevTools 2.20.1
```

Running that command automatically installed the default environment and invoked the flutter tool, great!

### Switching the default

We can switch the default with `puro2 use -g`:

```
$> puro2 use -g beta
[✓] Set global default environment to `beta`
```

This also updates a symlink at `~/.puro/envs/default` to point to `~/.puro/envs/beta`, which is added to the PATH
automatically during installation:

```
$> flutter --version
Flutter 3.7.0-1.5.pre • channel beta • https://github.com/flutter/flutter.git
Framework • revision 099b3f4bf1 (7 days ago) • 2023-01-20 18:35:12 -0800
Engine • revision 45c5586f2a
Tools • Dart 2.19.0 (build 2.19.0-444.6.beta) • DevTools 2.20.1
```

Running `puro2 ls` again shows the versions we installed and the new default:

```
$> puro2 ls               
[i] Environments:
      stable (stable / 3.7.0 / b06b8b2710)
    * beta   (beta / 3.7.0-1.5.pre / 099b3f4bf1)
      master (not installed)
``` 

### Switching specific projects

The `puro2 use` command switches the environment of the current project:

```
$> puro2 use beta
[✓] Switched to environment `beta`
```

You may notice this command creates a `.puro.json`, this file tells Puro2 which environment to use, and is automatically
gitignored:

```json
{
  "env": "beta"
}
```

Puro2 will detect VSCode and Android Studio (IntelliJ) configuration files and adjust them to use the right version of
Dart and Flutter, you can manually control this behavior with `--intellij --vscode` or `--no-intellij --no-vscode`.

To ignore the global and project defaults, you can pass `-e <name>` to most commands:

```
$> puro2 -e stable flutter --version
Flutter 3.7.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision b06b8b2710 (4 days ago) • 2023-01-23 16:55:55 -0800
Engine • revision b24591ed32
Tools • Dart 2.19.0 • DevTools 2.20.1
```

### Finding versions

The `puro2 releases` command prints recent releases on the stable and beta channels:

```
$> puro2 releases
[i] Latest stable releases:
    Flutter 3.7.0          | 3d  | b06b8b2710 | Dart 2.19.0
    Flutter 3.3.10         | 1mo | 135454af32 | Dart 2.18.6
    Flutter 3.3.9          | 2mo | b8f7f1f986 | Dart 2.18.5
    Flutter 3.3.8          | 3mo | 52b3dc25f6 | Dart 2.18.4
    Flutter 3.3.7          | 3mo | e99c9c7cd9 | Dart 2.18.4
    Flutter 3.0.5          | 7mo | f1875d570e | Dart 2.17.6
    Flutter 2.10.5         | 9mo | 5464c5bac7 | Dart 2.16.2
    Flutter 2.8.1          | 1y  | 77d935af4d | Dart 2.15.1
    Flutter 2.5.3          | 1y  | 18116933e7 | Dart 2.14.4
    Flutter 2.2.3          | 2y  | f4abaa0735 | Dart 2.13.4

    Latest beta releases:
    Flutter 3.7.0-1.5.pre  | 4d  | 099b3f4bf1 | Dart 2.19.0
    Flutter 3.7.0-1.4.pre  | 2w  | 686fe913dc | Dart 2.19.0
    Flutter 3.7.0-1.3.pre  | 3w  | 9b4416aaa7 | Dart 2.19.0
    Flutter 3.7.0-1.2.pre  | 1mo | c29b09b878 | Dart 2.19.0
    Flutter 3.7.0-1.1.pre  | 2mo | e599f02c7a | Dart 2.19.0
    Flutter 3.6.0-0.1.pre  | 2mo | 75927305ff | Dart 2.19.0
    Flutter 3.4.0-34.1.pre | 4mo | 71520442d4 | Dart 2.19.0
    Flutter 3.3.0-0.5.pre  | 5mo | 096162697a | Dart 2.18.0
    Flutter 3.1.0          | 8mo | bcea432bce | Dart 2.18.0
    Flutter 2.13.0-0.4.pre | 9mo | 25caf1461b | Dart 2.17.0
```

By default, this command shows the absolute latest 5 releases followed by the latest of the previous 5 major versions.
Pass it `--all` to show all releases unfiltered.

### Creation

The `puro2 create` command is used to create new environments.

If you add a release channel, puro2 will query the latest version on that channel and download it:

```
$> puro2 create my_env stable       
[✓] Created new environment at `/home/ping/.puro/envs/my_env/flutter`
```

You can also create one from a version, commit, or branch like `3.3.6`, `d9111f6` or `Hixie-patch-3`.

Forks are supported with the `--fork` option:

```
$> puro2 create my_env --fork git@github.com:your-username/flutter.git
[✓] Created new environment at `/home/ping/.puro/envs/my_env/flutter`
```

### Deletion

The `puro2 rm` command simply deletes environments:

```
$> puro2 rm my_env                                                 
[✓] Deleted environment `my_env`
```

Note that this does not delete any cached data that this environment depends on, this is why re-creating environments
after deletion usually takes less than a second.

We can manually delete unused caches with the `puro2 gc` command:

```
$> puro2 gc                                                        
[✓] Cleaned up caches and reclaimed 2.7GB
```
