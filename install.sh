#!/usr/bin/env bash
# Bootstrap a new macOS machine by symlinking dotfiles into $HOME.
# Usage:  ./install.sh                 # symlink everything (and render MCP)
#         ./install.sh --dry-run       # print what would happen
#         ./install.sh --extensions    # also install Cursor extensions
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
INSTALL_EXT=0
for arg in "$@"; do
  case "$arg" in
    --dry-run)    DRY_RUN=1 ;;
    --extensions) INSTALL_EXT=1 ;;
  esac
done

FILES=(
  .zshrc
  .zprofile
  .gitconfig
  .gitignore
  .tmux.conf
  .actrc
)

CONFIG_ENTRIES=(
  starship.toml
  ghostty/config
)

CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"

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

echo "== Top-level dotfiles -> \$HOME =="
for f in "${FILES[@]}"; do
  link "$DOTFILES_DIR/$f" "$HOME/$f"
done

echo "== ~/.config entries =="
mkdir -p "$HOME/.config"
for entry in "${CONFIG_ENTRIES[@]}"; do
  target="$HOME/.config/$entry"
  mkdir -p "$(dirname "$target")"
  link "$DOTFILES_DIR/.config/$entry" "$target"
done

echo "== Cursor =="
mkdir -p "$CURSOR_USER_DIR" "$HOME/.cursor"
link "$DOTFILES_DIR/cursor/settings.json"    "$CURSOR_USER_DIR/settings.json"
link "$DOTFILES_DIR/cursor/keybindings.json" "$CURSOR_USER_DIR/keybindings.json"
link "$DOTFILES_DIR/cursor/commands"      "$HOME/.cursor/commands"
link "$DOTFILES_DIR/cursor/skills"        "$HOME/.cursor/skills"
link "$DOTFILES_DIR/cursor/skills-cursor" "$HOME/.cursor/skills-cursor"

# Render MCP config via `op inject` (needs the 1P service account token)
if command -v op >/dev/null 2>&1 && [ -r "$HOME/.config/op/.service-account-token" ]; then
  echo "== Rendering ~/.cursor/mcp.json from template via op inject =="
  if (( DRY_RUN )); then
    echo "  would render: $DOTFILES_DIR/cursor/mcp.json.tpl -> $HOME/.cursor/mcp.json"
  else
    OP_SERVICE_ACCOUNT_TOKEN="$(cat "$HOME/.config/op/.service-account-token")" \
      op inject --force -i "$DOTFILES_DIR/cursor/mcp.json.tpl" -o "$HOME/.cursor/mcp.json"
    chmod 600 "$HOME/.cursor/mcp.json"
  fi
else
  echo "== Skipping MCP render (op CLI or service account token missing) =="
fi

if (( INSTALL_EXT )); then
  echo "== Installing Cursor extensions =="
  if ! command -v cursor >/dev/null 2>&1; then
    echo "  'cursor' CLI not in PATH; open Cursor and run \"Install 'cursor' command in PATH\" first"
  else
    while read -r ext; do
      [[ -z "$ext" ]] && continue
      echo "  + $ext"
      (( DRY_RUN )) || cursor --install-extension "$ext" --force >/dev/null
    done < "$DOTFILES_DIR/cursor/extensions.txt"
  fi
fi

cat <<'EOF'

Done. Next steps on a fresh machine:
  1. Install Homebrew:
       /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  2. Core tools:
       brew install starship fnm tmux git-delta gh 1password-cli \
         zsh-autosuggestions zsh-syntax-highlighting
  3. Oh My Zsh:
       sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  4. 1Password service account token:
       mkdir -p ~/.config/op && chmod 700 ~/.config/op
       # Paste the token, then:
       chmod 600 ~/.config/op/.service-account-token
  5. Re-run with extensions:  ./install.sh --extensions
  6. (Optional) ~/.zshenv.local for anything not in 1Password.
  7. Restart the shell.
EOF
