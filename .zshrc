export PATH="$HOME/.local/bin:$PATH"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # disabled — starship handles the prompt
plugins=(git z docker kubectl node python aws terraform zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Aliases
alias oc='OPENCODE_EXPERIMENTAL_MARKDOWN=1 OPENCODE_EXPERIMENTAL_PLAN_MODE=1 opencode'

# fnm (Node version manager)
eval "$(fnm env --use-on-cd --shell zsh)"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# Required for aws-sso-cli completions (compinit is already loaded by oh-my-zsh)
autoload -Uz +X bashcompinit && bashcompinit

# BEGIN_AWS_SSO_CLI
__aws_sso_profile_complete() {
    local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    _multi_parts : "($(/opt/homebrew/bin/aws-sso ${=_args} list --csv Profile))"
}

aws-sso-profile() {
    local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    local _sso=""
    local _profile=""

    if [ -n "$AWS_PROFILE" ]; then
        echo "Unable to assume a role while AWS_PROFILE is set"
        return 1
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            -S|--sso)
                shift
                if [ -z "$1" ]; then
                    echo "Error: -S/--sso requires an argument"
                    return 1
                fi
                _sso="$1"
                shift
                ;;
            -*)
                echo "Unknown option: $1"
                echo "Usage: aws-sso-profile [-S|--sso <sso-instance>] <profile>"
                return 1
                ;;
            *)
                if [ -z "$_profile" ]; then
                    _profile="$1"
                else
                    echo "Error: Multiple profiles specified"
                    return 1
                fi
                shift
                ;;
        esac
    done

    if [ -z "$_profile" ]; then
        echo "Usage: aws-sso-profile [-S|--sso <sso-instance>] <profile>"
        return 1
    fi

    if [ -n "$_sso" ]; then
        eval $(/opt/homebrew/bin/aws-sso ${=_args} -S "$_sso" eval -p "$_profile")
    else
        eval $(/opt/homebrew/bin/aws-sso ${=_args} eval -p "$_profile")
    fi

    if [ "$AWS_SSO_PROFILE" != "$_profile" ]; then
        return 1
    fi
}

aws-sso-clear() {
    local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    if [ -z "$AWS_SSO_PROFILE" ]; then
        echo "AWS_SSO_PROFILE is not set"
        return 1
    fi
    eval $(/opt/homebrew/bin/aws-sso ${=_args} eval -c)
}

compdef __aws_sso_profile_complete aws-sso-profile
complete -C /opt/homebrew/bin/aws-sso aws-sso
# END_AWS_SSO_CLI

# Secrets via 1Password (requires `op` CLI and a service account token
# at ~/.config/op/.service-account-token — see README).
if [ -r "$HOME/.config/op/.service-account-token" ]; then
    export OP_SERVICE_ACCOUNT_TOKEN="$(cat "$HOME/.config/op/.service-account-token")"
    export CLOUDFLARE_API_TOKEN="$(op item get h4kcnsdggh7lmvrsas6w3zdlke --vault clawd --fields api_token --reveal)"
    export CLOUDFLARE_DEFAULT_ACCOUNT_ID="$(op item get h4kcnsdggh7lmvrsas6w3zdlke --vault clawd --fields default_account_id --reveal)"
    export GITHUB_PAT="$(op item get cbndd6i4kc4wqmlg22fc3p6nkm --vault clawd --fields credential --reveal)"
fi

# Per-machine overrides (anything not in 1Password)
[ -f "$HOME/.zshenv.local" ] && source "$HOME/.zshenv.local"

# Docker CLI completions
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit

# Starship prompt (must be last)
eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="/Users/kenny/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
