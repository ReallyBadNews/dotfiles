# dotfiles

My macOS shell + terminal setup.

## What's in here

| File | Purpose |
| --- | --- |
| `.zshrc` | Zsh config: oh-my-zsh, aliases, lazy-loaded nvm/pyenv/virtualenvwrapper, AWS SSO, bun, pnpm, starship |
| `.zprofile` | Homebrew shellenv |
| `.gitconfig` | Git identity, aliases, SSH commit signing, delta pager |
| `.tmux.conf` | Enable mouse |
| `.actrc` | Docker images for `act` (GitHub Actions local runner) |
| `.config/starship.toml` | Starship prompt symbols |
| `.config/ghostty/config` | Ghostty terminal (fonts, theme, keybinds) |
| `install.sh` | Symlinks everything above into `$HOME` |

## Install

```sh
git clone https://github.com/ReallyBadNews/dotfiles.git ~/github/ReallyBadNews/dotfiles
cd ~/github/ReallyBadNews/dotfiles
./install.sh --dry-run   # preview
./install.sh             # apply
```

Existing non-symlink files in `$HOME` are backed up with a timestamp suffix.

## Secrets

Secrets are **not** committed. Both `.zshrc` and `.gitconfig` source a local, git-ignored file:

**`~/.zshenv.local`** — tokens and per-machine env:
```sh
export CLOUDFLARE_API_TOKEN=...
export CLOUDFLARE_DEFAULT_ACCOUNT_ID=...
export GITHUB_PAT=...
# export PYTHONPATH=...
```

**`~/.gitconfig.local`** — machine-specific git settings (optional):
```ini
[github]
    token = ghp_...
```

## Prerequisites

```sh
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Core tools
brew install starship bat nvm pyenv tmux git-delta gh \
  zsh-autosuggestions zsh-syntax-highlighting

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Font for Ghostty (FiraCode Nerd Font)
brew install --cask font-fira-code-nerd-font
```
