# dotfiles

My macOS shell + terminal + editor setup.

## What's in here

| File / dir | Purpose |
| --- | --- |
| `.zshrc` | Zsh: oh-my-zsh, fnm, AWS SSO CLI, bun, 1Password-sourced secrets, starship |
| `.zprofile` | Homebrew shellenv |
| `.gitconfig` | Git identity, aliases, SSH commit signing, delta pager |
| `.tmux.conf` | Enable mouse |
| `.actrc` | Docker images for `act` |
| `.config/starship.toml` | Starship prompt symbols |
| `.config/ghostty/config` | Ghostty terminal (fonts, theme, keybinds) |
| `cursor/settings.json` | Cursor editor settings |
| `cursor/keybindings.json` | Cursor keybindings |
| `cursor/commands/` | Custom slash commands |
| `cursor/skills/`, `cursor/skills-cursor/` | Installed skills |
| `cursor/mcp.json.tpl` | MCP servers template (rendered via `op inject`) |
| `cursor/extensions.txt` | Extension IDs for `cursor --install-extension` |
| `install.sh` | Symlinks everything into `$HOME`, renders MCP config |

## Install

```sh
git clone https://github.com/ReallyBadNews/dotfiles.git ~/github/ReallyBadNews/dotfiles
cd ~/github/ReallyBadNews/dotfiles
./install.sh --dry-run        # preview
./install.sh                  # apply (symlinks + MCP render)
./install.sh --extensions     # also install Cursor extensions
```

Existing non-symlink files in `$HOME` are backed up with a timestamp suffix.

## Prerequisites

```sh
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Core tools
brew install starship fnm tmux git-delta gh 1password-cli

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install.sh will clone these into $ZSH_CUSTOM/plugins on the next run,
# but you can do it manually too:
#   git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
#     ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
#   git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
#     ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Font for Ghostty
brew install --cask font-fira-code-nerd-font
```

## Secrets — 1Password

Secrets are fetched at shell-start via the `op` CLI. Put a 1Password service account token at `~/.config/op/.service-account-token` and everything else is automatic:

```sh
mkdir -p ~/.config/op && chmod 700 ~/.config/op
# Paste the service account token, then:
chmod 600 ~/.config/op/.service-account-token
```

**Env vars exported in `.zshrc`:**

| Env var | 1P reference |
| --- | --- |
| `CLOUDFLARE_API_TOKEN` | `op://clawd/h4kcnsdggh7lmvrsas6w3zdlke/api_token` |
| `CLOUDFLARE_DEFAULT_ACCOUNT_ID` | `op://clawd/h4kcnsdggh7lmvrsas6w3zdlke/default_account_id` |
| `GITHUB_PAT` | `op://clawd/cbndd6i4kc4wqmlg22fc3p6nkm/credential` |

**MCP secrets** (rendered into `~/.cursor/mcp.json` by `op inject`):

| Field | 1P reference |
| --- | --- |
| `github` Authorization | `op://clawd/cbndd6i4kc4wqmlg22fc3p6nkm/credential` |
| `context7` API key | `op://clawd/qivvl2atclndugp4cecg3oxqey/API Key` |

### Per-machine overrides

For env vars not in 1Password, create `~/.zshenv.local` (git-ignored):
```sh
export SOME_MACHINE_SPECIFIC_VAR=...
```

For machine-specific git settings, create `~/.gitconfig.local` — auto-included by `.gitconfig`.
