# Design

EnvSwitch separates project logic from installed GCC, CUDA Toolkit, and Python
packages. The repository is organized around modules, where each module owns its
version manifest, installation directory, default version, and environment
application rules.

## Goals

- Keep GCC, CUDA Toolkit, and Python states independent.
- Support one-command enable and disable flows for the current user.
- Persist state across new terminals and SSH reconnects.
- Avoid editing system directories or requiring root privileges.
- Keep large local GCC, CUDA, and Python installs out of git.
- Preserve compatibility with the previous GCC source scripts.

## State Model

EnvSwitch stores user state under:

```text
~/.config/EnvSwitch/config
~/.config/EnvSwitch/state
~/.config/EnvSwitch/profile.sh
```

`config` records the project root and default versions. `state` uses version 2
and stores an enabled flag plus selected version for every tool:

```bash
ENVS_STATE_VERSION='2'
ENVS_GCC_ENABLED='0'
ENVS_GCC_VERSION='12'
ENVS_CUDA_ENABLED='1'
ENVS_CUDA_VERSION='12.8'
ENVS_PYTHON_ENABLED='1'
ENVS_PYTHON_VERSION='3.12.12'
ENVS_LAST_ENABLED_MODULES='cuda python'
```

`ENVS_LAST_ENABLED_MODULES` lets global `envswitch off` pause all tools and
global `envswitch on` restore the previous combination. Tool-specific commands
only mutate the requested module.

Version 1 state is migrated automatically. A legacy enabled state maps to GCC
and CUDA enabled, while Python starts disabled to avoid changing the user's
interpreter during an upgrade.

## Shell Integration

`envswitch install` writes a managed block to shell startup files:

```bash
# >>> EnvSwitch >>>
export PATH="<repo>/bin:$PATH"
[ -r "$HOME/.config/EnvSwitch/profile.sh" ] && source "$HOME/.config/EnvSwitch/profile.sh"
# <<< EnvSwitch <<<
```

For bash, the block is inserted before the common non-interactive guard so
`bash -lc` and SSH login workflows can still see the command and environment.

The generated profile defines a shell function named `envswitch`. After commands
that change state, the function re-sources the generated profile so the current
terminal updates immediately.

## Environment Cleanup

The generated profile removes paths under:

```text
modules/gcc/versions/*/bin
modules/cuda/versions/*/{bin,lib64,extras/CUPTI/lib64}
modules/python/versions/*/bin
```

before applying the selected environment. This prevents duplicate `PATH` and
CUDA `LD_LIBRARY_PATH` entries and allows `envswitch off` to cleanly remove
managed paths without damaging unrelated user environment values.

GCC library directories are intentionally not exported globally through
`LD_LIBRARY_PATH`; the conda-forge compiler drivers already run correctly by
absolute path, and global GCC library paths can make unrelated programs load the
wrong `libtinfo`, `libstdc++`, or runtime support libraries.

For build tools, EnvSwitch does export GCC compile/link-time search paths through
`LIBRARY_PATH`, `PKG_CONFIG_PATH`, and `CMAKE_PREFIX_PATH`.

Managed compiler, CUDA, and Python variables are only cleared when they point
into this project tree. EnvSwitch does not set `PYTHONHOME`, `PYTHONPATH`, or
`VIRTUAL_ENV`.

## Installed Artifacts

All `modules/*/versions/*` directories are ignored by git except for `.gitkeep`
placeholders. `envswitch fetch` populates those directories from download
providers, and `envswitch link` can register an existing install with a symlink.

The default download sources are:

- GCC uses the Tsinghua conda-forge mirror with micromamba, mamba, conda, or an
  EnvSwitch-bootstrapped private micromamba in the user's cache.
- CUDA Toolkit uses NVIDIA's China CDN and NVIDIA's toolkit-only runfile
  installer.
- Python uses a pinned `python-build-standalone` release and verifies its SHA256
  before extraction.

CUDA can also be fetched from NVIDIA's global host with `--source global`, from
the Tsinghua CUDA mirror with `--source tuna`, or from Tsinghua Anaconda mirrors
with `--provider conda`.

## Command Semantics

- `envswitch use <tool> [version]` enables only that tool. An omitted version
  selects the configured default.
- `envswitch on <tool>` enables the tool's selected version, falling back to its
  default.
- `envswitch off <tool>` disables only that tool.
- `envswitch off` records the enabled set and disables all tools.
- `envswitch on` restores the recorded set. When no set has been recorded, it
  enables the default versions that are already installed.
- `envswitch default <tool> <version>` changes the default but does not
  implicitly change an enabled tool's selected version.
