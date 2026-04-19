# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # disabled — starship handles the prompt
plugins=(git z docker kubectl node python aws terraform zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# ============================================
# ALIASES & FUNCTIONS
# ============================================
alias cat="bat"
alias python=/opt/homebrew/bin/python3
alias oc='OPENCODE_EXPERIMENTAL_MARKDOWN=1 OPENCODE_EXPERIMENTAL_PLAN_MODE=1 opencode'

bd() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}

kraken() {
    /Applications/GitKraken.app/Contents/MacOS/GitKraken -p $(pwd)
}

# ============================================
# NVM
# ============================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ============================================
# LAZY LOAD VIRTUALENVWRAPPER
# ============================================
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/opt/homebrew/bin/python
_load_virtualenvwrapper() {
    unfunction workon mkvirtualenv rmvirtualenv 2>/dev/null
    source virtualenvwrapper.sh
}
workon() { _load_virtualenvwrapper; workon "$@"; }
mkvirtualenv() { _load_virtualenvwrapper; mkvirtualenv "$@"; }
rmvirtualenv() { _load_virtualenvwrapper; rmvirtualenv "$@"; }

# ============================================
# LAZY LOAD PYENV
# ============================================
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
pyenv() {
    unfunction pyenv
    eval "$(command pyenv init -)"
    pyenv "$@"
}

# ============================================
# LAZY LOAD NGROK
# ============================================
ngrok() {
    unfunction ngrok
    eval "$(command ngrok completion)"
    ngrok "$@"
}

# ============================================
# SINGLE COMPINIT (cached, runs once per day)
# ============================================
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
autoload -Uz bashcompinit && bashcompinit

# ============================================
# BUN
# ============================================
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
fpath=($BUN_INSTALL $fpath)
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# ============================================
# AWS SSO CLI
# ============================================
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

# ============================================
# PNPM
# ============================================
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ============================================
# PATH EXPORTS (consolidated)
# ============================================
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
export PATH="$HOME/.sst/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ============================================
# BUILD FLAGS
# ============================================
export LDFLAGS="-L/opt/homebrew/opt/jpeg/lib"
export CPPFLAGS="-I/opt/homebrew/opt/jpeg/include"

# ============================================
# PYTHON CONFIG
# ============================================
export PIPENV_DEFAULT_PYTHON_VERSION=3.9.4
# Per-machine PYTHONPATH (if needed) goes in ~/.zshenv.local

# ============================================
# SECRETS / PER-MACHINE OVERRIDES
# ============================================
# Keep tokens and machine-specific exports out of version control.
# Create ~/.zshenv.local with things like:
#   export CLOUDFLARE_API_TOKEN=...
#   export CLOUDFLARE_DEFAULT_ACCOUNT_ID=...
#   export GITHUB_PAT=...
[ -f "$HOME/.zshenv.local" ] && source "$HOME/.zshenv.local"

# ============================================
# DOCKER COMPLETIONS
# ============================================
fpath=($HOME/.docker/completions $fpath)

# ============================================
# STARSHIP PROMPT (must be last)
# ============================================
eval "$(starship init zsh)"
