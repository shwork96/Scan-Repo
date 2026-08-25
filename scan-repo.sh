#!/usr/bin/env bash

set -euo pipefail

TARGET="${1:-.}"

echo "🔍 Scanning: $TARGET"
echo "-------------------------------------------"

# 1. Detect AI agent config directories
echo "📁 Checking for AI agent config directories..."
find "$TARGET" -type d \( -name ".claude" -o -name ".cursor" -o -name ".gemini" \) -print

# 2. Detect VS Code auto-run tasks
echo "🧨 Checking for VS Code auto-run tasks..."
grep -R "\"runOn\"" "$TARGET"/.vscode 2>/dev/null || true

# 3. Detect suspicious scripts
echo "⚠️ Checking for suspicious shell scripts..."
find "$TARGET" -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.zsh" \) -exec grep -HnE "\beval\b|bash -c|(curl|wget).*\||base64.*(--decode|-d)" {} \; 2>/dev/null || true

# 4. Detect invisible Unicode characters
echo "🕳️ Checking for invisible Unicode characters..."
grep -RIn $'\xe2\x80\x8b' "$TARGET" 2>/dev/null || true  # U+200B zero-width space
grep -RIn $'\xe2\x80\x8c' "$TARGET" 2>/dev/null || true  # U+200C zero-width non-joiner
grep -RIn $'\xe2\x80\x8d' "$TARGET" 2>/dev/null || true  # U+200D zero-width joiner
grep -RIn $'\xe2\x80\xae' "$TARGET" 2>/dev/null || true  # U+202E right-to-left override

# 5. Detect large single-line files (obfuscation)
echo "📏 Checking for large single-line files..."
find "$TARGET" -type f -size +50k -exec awk 'NR==1 && length($0) > 50000 {print FILENAME " has a huge single line"}' {} \; 2>/dev/null || true

# 6. Detect suspicious JSON/YAML patterns
echo "🧪 Checking for suspicious JSON/YAML patterns..."
grep -RInE "(postinstall|preinstall|runOn|eval)" "$TARGET" 2>/dev/null || true

echo "-------------------------------------------"
echo "✅ Scan complete."
