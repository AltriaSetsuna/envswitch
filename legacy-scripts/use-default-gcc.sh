#!/usr/bin/env bash
# Compatibility wrapper. Prefer:
#   envswitch on
ENVSWITCH_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "$ENVSWITCH_ROOT/legacy-scripts/use-gcc12.sh"
