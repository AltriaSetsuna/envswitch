# CUDA Toolkit Module

The CUDA toolkit module lives at:

```text
modules/cuda/
```

Available versions:

```text
modules/cuda/versions/cuda-12.8
```

This directory is a local install and is ignored by git.

The default version is selected by:

```text
modules/cuda/default -> versions/cuda-12.8
```

## Exports

When enabled, the CUDA module sets:

```bash
ENVSWITCH_CUDA_HOME
CUDA_HOME
CUDA_PATH
```

It also prepends:

```text
$CUDA_HOME/bin
$CUDA_HOME/lib64
$CUDA_HOME/extras/CUPTI/lib64
```

when those directories exist.

## Downloads

The default CUDA provider is the NVIDIA runfile downloaded from NVIDIA's China
CDN. It installs only the toolkit into the current user's repo checkout; it does
not install drivers and does not require conda.

Use NVIDIA's global download host:

```bash
envswitch fetch cuda 12.8 --source global
```

Try the Tsinghua CUDA mirror explicitly:

```bash
envswitch fetch cuda 12.8 --source tuna
```

Use the conda package provider through Tsinghua Anaconda mirrors:

```bash
envswitch fetch cuda 12.8 --provider conda
```

Register an existing toolkit without copying it:

```bash
envswitch link cuda 12.8 /path/to/cuda-prefix
```

## Notes

CUDA versions must contain an executable `bin/nvcc`. This keeps `envswitch on`
from silently enabling an incomplete toolkit directory.

Use:

```bash
envswitch fetch cuda 12.8
envswitch use cuda 12.8
envswitch default cuda 12.8
```
