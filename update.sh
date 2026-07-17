#!/usr/bin/env bash
# Update script for claude-desktop (official Anthropic apt repo).
# The apt Packages index carries version + SHA256, so no prefetch download.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NIX="$SCRIPT_DIR/package.nix"
INDEX_URL="https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages"

echo "Fetching apt package index..."
INDEX=$(curl -fsSL "$INDEX_URL")

LATEST_VERSION=$(echo "$INDEX" | grep '^Version: ' | awk '{print $2}' | sort -V | tail -1)
SHA256_HEX=$(echo "$INDEX" | awk -v ver="$LATEST_VERSION" '
  $1 == "Version:" { v = $2 }
  $1 == "SHA256:" && v == ver { print $2; exit }')

CURRENT_VERSION=$(grep 'version = ' "$PACKAGE_NIX" | head -1 | sed 's/.*"\(.*\)".*/\1/')

echo "Current version: $CURRENT_VERSION"
echo "Latest version:  $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "Already up to date!"
    exit 0
fi

if [ -z "$SHA256_HEX" ]; then
    echo "Error: no SHA256 for $LATEST_VERSION in apt index" >&2
    exit 1
fi

SRI_HASH=$(nix hash convert --to sri --hash-algo sha256 "$SHA256_HEX")
echo "New SRI hash: $SRI_HASH"

sed -i "s/version = \"$CURRENT_VERSION\"/version = \"$LATEST_VERSION\"/" "$PACKAGE_NIX"
sed -i "s|hash = \"sha256-.*\"|hash = \"$SRI_HASH\"|" "$PACKAGE_NIX"

echo "Updated package.nix to version $LATEST_VERSION"
