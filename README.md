# dotfiles

My macOS shell + terminal setup.

## What's in here

| File | Purpose |
| --- | --- |
| `.zshrc` | Zsh: oh-my-zsh, fnm, AWS SSO CLI, bun, 1Password-sourced secrets, starship |
| `.zprofile` | Homebrew shellenv |
| `.gitconfig` | Git identity, aliases, SSH commit signing, delta pager |
| `.tmux.conf` | Enable mouse |
| `.actrc` | Docker images for `act` (GitHub Actions local runner) |
| `.config/starship.toml` | Starship prompt symbols |
| `.config/ghostty/config` | Ghostty terminal (fonts, theme, keybinds) |
| `install.sh` | Symlinks everything into `$HOME` |

## Install

```sh
git clone https://github.com/ReallyBadNews/dotfiles.git ~/github/ReallyBadNews/dotfiles
cd ~/github/ReallyBadNews/dotfiles
./install.sh --dry-run   # preview
./install.sh             # apply
```

Existing non-symlink files in `$HOME` are backed up with a timestamp suffix.

## Prerequisites

```sh
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Core tools
brew install starship fnm tmux git-delta gh 1password-cli \
  zsh-autosuggestions zsh-syntax-highlighting

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Font for Ghostty
brew install --cask font-fira-code-nerd-font
```

## Secrets — 1Password

Secrets (Cloudflare, GitHub PAT) are fetched at shell-start via the `op` CLI. The shell reads a 1Password service account token from `~/.config/op/.service-account-token`; the rest is automatic.

```sh
mkdir -p ~/.config/op && chmod 700 ~/.config/op
# Paste the service account token into the file, then:
chmod 600 ~/.config/op/.service-account-token
```

If the token file is missing or unreadable, the `op` block is skipped silently — the shell still starts, you just won't have the env vars set.

**Item references used by `.zshrc`:**
| Env var | 1P item | Field |
| --- | --- | --- |
| `CLOUDFLARE_API_TOKEN` | `h4kcnsdggh7lmvrsas6w3zdlke` (vault: `clawd`) | `api_token` |
| `CLOUDFLARE_DEFAULT_ACCOUNT_ID` | same | `default_account_id` |
| `GITHUB_PAT` | `cbndd6i4kc4wqmlg22fc3p6nkm` (vault: `clawd`) | `credential` |

### Per-machine overrides

For env vars not in 1Password, create `~/.zshenv.local` (git-ignored):
```sh
export SOME_MACHINE_SPECIFIC_VAR=...
```

For git-specific machine overrides, create `~/.gitconfig.local` (git-ignored); it's auto-included by `.gitconfig`.
