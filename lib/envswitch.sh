# Shared shell entrypoint for EnvSwitch-managed sessions.
#
# Prefer sourcing ~/.config/EnvSwitch/profile.sh after running:
#   envswitch install-shell

if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/EnvSwitch/profile.sh" ]; then
    # shellcheck disable=SC1090
    . "${XDG_CONFIG_HOME:-$HOME/.config}/EnvSwitch/profile.sh"
fi
