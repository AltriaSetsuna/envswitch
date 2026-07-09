#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

ROOT="$TMP_ROOT/EnvSwitch"
HOME_DIR="$TMP_ROOT/home"
mkdir -p "$ROOT" "$HOME_DIR"

tar \
    --exclude=.git \
    --exclude='modules/gcc/versions/*' \
    --exclude='modules/cuda/versions/*' \
    --exclude='modules/python/versions/*' \
    -C "$SOURCE_ROOT" -cf - . |
    tar -C "$ROOT" -xf -

GCC12_HOME="$ROOT/modules/gcc/versions/gcc-12"
CUDA128_HOME="$ROOT/modules/cuda/versions/cuda-12.8"
PYTHON312_HOME="$ROOT/modules/python/versions/python-3.12.12"

mkdir -p \
    "$GCC12_HOME/bin" \
    "$GCC12_HOME/lib" \
    "$GCC12_HOME/lib64" \
    "$GCC12_HOME/x86_64-conda-linux-gnu/lib" \
    "$CUDA128_HOME/bin" \
    "$CUDA128_HOME/lib64" \
    "$CUDA128_HOME/extras/CUPTI/lib64" \
    "$PYTHON312_HOME/bin"

cat >"$GCC12_HOME/bin/x86_64-conda-linux-gnu-gcc" <<'EOF'
#!/usr/bin/env bash
printf 'gcc (EnvSwitch test) 12.0.0\n'
EOF
cat >"$GCC12_HOME/bin/x86_64-conda-linux-gnu-g++" <<'EOF'
#!/usr/bin/env bash
printf 'g++ (EnvSwitch test) 12.0.0\n'
EOF
cat >"$CUDA128_HOME/bin/nvcc" <<'EOF'
#!/usr/bin/env bash
printf 'Cuda compilation tools, release 12.8\n'
EOF
cat >"$PYTHON312_HOME/bin/python3" <<'EOF'
#!/usr/bin/env bash
printf 'Python 3.12.12\n'
EOF
cat >"$PYTHON312_HOME/bin/pip3" <<'EOF'
#!/usr/bin/env bash
printf 'pip test\n'
EOF
chmod +x \
    "$GCC12_HOME/bin/x86_64-conda-linux-gnu-gcc" \
    "$GCC12_HOME/bin/x86_64-conda-linux-gnu-g++" \
    "$CUDA128_HOME/bin/nvcc" \
    "$PYTHON312_HOME/bin/python3" \
    "$PYTHON312_HOME/bin/pip3"

export HOME="$HOME_DIR"
export XDG_CONFIG_HOME="$HOME_DIR/.config"

clean_bash() {
    env -i \
        HOME="$HOME_DIR" \
        XDG_CONFIG_HOME="$HOME_DIR/.config" \
        SHELL=/bin/bash \
        PATH=/usr/bin:/bin \
        bash --noprofile --rcfile "$HOME_DIR/.bashrc" -ic "$1"
}

"$ROOT/bin/envswitch" install >/dev/null

clean_bash 'envswitch status' | grep -E '^gcc[[:space:]]+disabled' >/dev/null
clean_bash 'envswitch status' | grep -E '^cuda[[:space:]]+disabled' >/dev/null
clean_bash 'envswitch status' | grep -E '^python[[:space:]]+disabled' >/dev/null

clean_bash 'envswitch use cuda >/dev/null; test -z "${CC:-}"; test "$CUDA_HOME" = "'"$CUDA128_HOME"'"; test -z "${ENVS_PYTHON_HOME:-}"'
clean_bash 'test -z "${CC:-}"; test "$CUDA_HOME" = "'"$CUDA128_HOME"'"'
clean_bash 'envswitch status' | grep -E '^cuda[[:space:]]+enabled[[:space:]]+12[.]8' >/dev/null
clean_bash 'envswitch status' | grep -E '^gcc[[:space:]]+disabled' >/dev/null

clean_bash 'envswitch use gcc >/dev/null; test "$CC" = "'"$GCC12_HOME"'/bin/x86_64-conda-linux-gnu-gcc"; test "$CUDA_HOME" = "'"$CUDA128_HOME"'"'
clean_bash 'gcc --version | grep -q 12'
clean_bash 'case ":${LIBRARY_PATH:-}:" in *":'"$GCC12_HOME"'/lib:"*) ;; *) exit 1 ;; esac'

clean_bash 'envswitch off cuda >/dev/null; test -n "${CC:-}"; test -z "${CUDA_HOME:-}"'
clean_bash 'envswitch use python >/dev/null; test -n "${CC:-}"; test -z "${CUDA_HOME:-}"; test "$ENVS_PYTHON_HOME" = "'"$PYTHON312_HOME"'"'
clean_bash 'python --version | grep -q "Python 3.12.12"'

clean_bash 'envswitch off >/dev/null; test -z "${CC:-}"; test -z "${CUDA_HOME:-}"; test -z "${ENVS_PYTHON_HOME:-}"'
clean_bash 'envswitch on >/dev/null; test -n "${CC:-}"; test -z "${CUDA_HOME:-}"; test -n "${ENVS_PYTHON_HOME:-}"'
clean_bash 'envswitch on cuda >/dev/null; test -n "${CC:-}"; test -n "${CUDA_HOME:-}"; test -n "${ENVS_PYTHON_HOME:-}"'

grep -q "ENVS_STATE_VERSION='2'" "$XDG_CONFIG_HOME/EnvSwitch/state"
grep -q "ENVS_GCC_ENABLED='1'" "$XDG_CONFIG_HOME/EnvSwitch/state"
grep -q "ENVS_CUDA_ENABLED='1'" "$XDG_CONFIG_HOME/EnvSwitch/state"
grep -q "ENVS_PYTHON_ENABLED='1'" "$XDG_CONFIG_HOME/EnvSwitch/state"

cat >"$XDG_CONFIG_HOME/EnvSwitch/state" <<'EOF'
ENVS_ENABLED='1'
ENVS_GCC_VERSION='12'
ENVS_CUDA_VERSION='12.8'
EOF
"$ROOT/bin/envswitch" install >/dev/null
grep -q "ENVS_STATE_VERSION='2'" "$XDG_CONFIG_HOME/EnvSwitch/state"
grep -q "ENVS_GCC_ENABLED='1'" "$XDG_CONFIG_HOME/EnvSwitch/state"
grep -q "ENVS_CUDA_ENABLED='1'" "$XDG_CONFIG_HOME/EnvSwitch/state"
grep -q "ENVS_PYTHON_ENABLED='0'" "$XDG_CONFIG_HOME/EnvSwitch/state"

"$ROOT/bin/envswitch" uninstall >/dev/null
! grep -q 'EnvSwitch' "$HOME_DIR/.bashrc"

printf 'smoke ok\n'
