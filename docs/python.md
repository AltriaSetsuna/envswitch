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

## Default Packages

`envswitch fetch python` installs the packages listed in:

```text
modules/python/default-packages.txt
```

The default list includes PDF readers, test tooling, numerical and data
libraries, Matplotlib, image and spreadsheet support, and common interactive
utilities.

EnvSwitch prefers:

```bash
uv pip install --python <python-prefix>/bin/python3 -r modules/python/default-packages.txt
```

If `uv` is unavailable, it falls back to:

```bash
<python-prefix>/bin/python3 -m pip install -r modules/python/default-packages.txt
```

The default package index is the Tsinghua PyPI mirror. Override it with
`ENVS_PYPI_INDEX_URL`.

Install only the interpreter:

```bash
envswitch fetch python --no-default-packages
envswitch fetch defaults --no-default-packages
```

Running `envswitch fetch python` again installs any missing packages from the
current list into the existing EnvSwitch Python prefix.

## Commands

```bash
envswitch fetch python
envswitch fetch python --no-default-packages
envswitch use python
envswitch use python 3.12.12
envswitch on python
envswitch off python
envswitch default python 3.12.12
envswitch link python 3.12.12 /path/to/python-prefix
```

Omitting the version from `fetch python` or `use python` selects the configured
default version. Default packages are installed unless
`--no-default-packages` is present.

The installed prefix must contain an executable `bin/python3`. EnvSwitch adds
`python` and `pip` symlinks for downloads it owns when only the `python3` and
`pip3` command names are present.
