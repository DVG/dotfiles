

# Make sure .claude exists
mkdir -p ~/.claude

# Symlink commands
ln -s "$DOTFILES_DIR/claude/commands" "$HOME/.claude/commands"

# Symlink agents
ln -s "$DOTFILES_DIR/claude/agents" "$HOME/.claude/agents"

# Symlink skills
ln -s "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills"