#!/usr/bin/env bash
# Bootstrap a new macOS machine by symlinking dotfiles into $HOME.
# Usage:  ./install.sh           # symlink everything
#         ./install.sh --dry-run # print what would happen
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

# Top-level dotfiles to link into $HOME
FILES=(
  .zshrc
  .zprofile
  .gitconfig
  .gitignore
  .tmux.conf
  .actrc
)

# ~/.config subpaths to link (relative to repo's .config/)
CONFIG_ENTRIES=(
  starship.toml
  ghostty/config
)

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    local bak="${target}.backup.$(date +%Y%m%d%H%M%S)"
    echo "  backup: $target -> $bak"
    (( DRY_RUN )) || mv "$target" "$bak"
  elif [[ -L "$target" ]]; then
    echo "  unlink: $target"
    (( DRY_RUN )) || rm "$target"
  fi
}

link() {
  local src="$1" target="$2"
  backup_if_exists "$target"
  echo "  link:   $target -> $src"
  (( DRY_RUN )) || ln -s "$src" "$target"
}

echo "Linking top-level dotfiles from $DOTFILES_DIR into $HOME"
for f in "${FILES[@]}"; do
  link "$DOTFILES_DIR/$f" "$HOME/$f"
done

echo "Linking ~/.config entries"
mkdir -p "$HOME/.config"
for entry in "${CONFIG_ENTRIES[@]}"; do
  target="$HOME/.config/$entry"
  mkdir -p "$(dirname "$target")"
  link "$DOTFILES_DIR/.config/$entry" "$target"
done

cat <<'EOF'

Done. Next steps on a fresh machine:
  1. Install Homebrew:      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  2. Core tools:            brew install starship bat nvm pyenv zsh-autosuggestions zsh-syntax-highlighting tmux git-delta gh
  3. Oh My Zsh:             sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  4. Create ~/.zshenv.local with secrets (CLOUDFLARE_API_TOKEN, GITHUB_PAT, etc.)
  5. (Optional) Create ~/.gitconfig.local with machine-specific git settings.
  6. Restart the shell.
EOF
