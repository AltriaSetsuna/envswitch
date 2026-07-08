#!/usr/bin/env bash
# Compatibility wrapper. Prefer:
#   envswitch on
ENVS_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "$ENVS_ROOT/legacy-scripts/use-gcc12.sh"
