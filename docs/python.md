# Python Module

The Python module lives at:

```text
modules/python/
```

The default version is:

```text
modules/python/default -> versions/python-3.12.12
```

Python installations are local artifacts and are ignored by git. The default
installer downloads a pinned, relocatable `python-build-standalone` archive and
verifies its SHA256 checksum before extraction.

The bundled download definition currently targets Linux x86_64. Other
architectures require a manifest entry with the matching asset and checksum.

## Environment

When enabled, the Python module sets:

```bash
ENVS_PYTHON_HOME
```

It prepends `$ENVS_PYTHON_HOME/bin` to `PATH`. EnvSwitch intentionally does not
set `PYTHONHOME`, `PYTHONPATH`, or `VIRTUAL_ENV`, because those variables can
break virtual environments and Python package discovery.

If a virtual environment is already active, `envswitch use python` prints a
warning. Deactivate the virtual environment before changing the base Python
when deterministic interpreter selection matters.

## Commands

```bash
envswitch fetch python
envswitch use python
envswitch use python 3.12.12
envswitch on python
envswitch off python
envswitch default python 3.12.12
envswitch link python 3.12.12 /path/to/python-prefix
```

Omitting the version from `fetch python` or `use python` selects the configured
default version.

The installed prefix must contain an executable `bin/python3`. EnvSwitch adds
`python` and `pip` symlinks for downloads it owns when only the `python3` and
`pip3` command names are present.
