#!/usr/bin/env bash
# Compatibility wrapper. Prefer:
#   envswitch use gcc 11
ENVSWITCH_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
export TOOLCHAIN_ROOT="$ENVSWITCH_ROOT/modules/gcc/versions/gcc-11"
export PATH="$TOOLCHAIN_ROOT/bin:$PATH"
export CC="$TOOLCHAIN_ROOT/bin/x86_64-conda-linux-gnu-gcc"
export CXX="$TOOLCHAIN_ROOT/bin/x86_64-conda-linux-gnu-g++"
export CMAKE_C_COMPILER="$CC"
export CMAKE_CXX_COMPILER="$CXX"
export CMAKE_ARGS="-DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"
case ":${LD_LIBRARY_PATH:-}:" in
    *":$TOOLCHAIN_ROOT/lib:"*) ;;
    *) export LD_LIBRARY_PATH="$TOOLCHAIN_ROOT/lib:${LD_LIBRARY_PATH:-}" ;;
esac
case ":${LD_LIBRARY_PATH:-}:" in
    *":$TOOLCHAIN_ROOT/lib64:"*) ;;
    *) export LD_LIBRARY_PATH="$TOOLCHAIN_ROOT/lib64:${LD_LIBRARY_PATH:-}" ;;
esac
