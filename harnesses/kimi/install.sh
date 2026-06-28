#!/bin/bash
# Install agent-skills for Kimi Code CLI.
# Syncs Kimi-adapted skills from harnesses/kimi/skills/ to ~/.kimi/skills/.
# Run from the agent-skills repo root: ./harnesses/kimi/install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills"
TARGET_DIR="$HOME/.kimi/skills"

echo "Installing agent-skills for Kimi to $TARGET_DIR"

mkdir -p "$TARGET_DIR"

# Copy all Kimi-adapted skill directories
for skill_dir in "$SOURCE_DIR"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")
    echo "  → $skill_name"
    rm -rf "$TARGET_DIR/$skill_name"
    cp -r "$skill_dir" "$TARGET_DIR/$skill_name"
done

echo ""
echo "Installed $(ls -1 "$SOURCE_DIR" | wc -l | tr -d ' ') Kimi skills."
echo ""
echo "Next steps:"
echo "  1. Create .kimi/AGENTS.md in any project that needs a thin overlay"
echo "  2. See harnesses/kimi/.kimi/AGENTS.md.template for an example"
