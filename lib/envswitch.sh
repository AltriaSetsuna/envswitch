# Shared shell entrypoint for envswitch-managed sessions.
#
# Prefer sourcing ~/.config/envswitch/profile.sh after running:
#   envswitch install-shell

if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/envswitch/profile.sh" ]; then
    # shellcheck disable=SC1090
    . "${XDG_CONFIG_HOME:-$HOME/.config}/envswitch/profile.sh"
fi
