#!/bin/bash

set -e

# Cursor Dark Islands Bootstrap Installer
# One-liner: curl -fsSL https://raw.githubusercontent.com/mdaz78/cursor-dark-islands/main/bootstrap.sh | bash

echo "🏝️  Cursor Dark Islands Bootstrap Installer"
echo "============================================"
echo ""

REPO_URL="https://github.com/mdaz78/cursor-dark-islands.git"
INSTALL_DIR="$HOME/.cursor-dark-islands-temp"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
else
    OS="Linux"
fi

echo "📥 Step 1: Downloading Cursor Dark Islands..."
echo "   Repository: $REPO_URL"

# Remove old temp directory if exists
rm -rf "$INSTALL_DIR"


# Clone repository
BRANCH="main"
if ! git clone "$REPO_URL" "$INSTALL_DIR" --quiet --branch "$BRANCH"; then
    echo "❌ Failed to download Cursor Dark Islands"
    exit 1
fi

echo "✓ Downloaded successfully!"
echo ""

echo "🚀 Step 2: Running installer..."
echo ""

# Run appropriate installer
if [[ "$OS" == "macOS" ]] || [[ "$OS" == "Linux" ]]; then
    cd "$INSTALL_DIR"
    bash install.sh
else
    echo "⚠️  Automatic installation not supported for this OS"
    echo "   Please manually run: cd $INSTALL_DIR && ./install.sh"
    exit 1
fi

# Cleanup (optional - keeps the temp directory)
echo ""
echo "🧹 Step 3: Cleaning up..."
read -p "   Remove temporary files? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$INSTALL_DIR"
    echo "✓ Temporary files removed"
else
    echo "   Files kept at: $INSTALL_DIR"
fi

echo ""
echo -e "🎉 Done! Enjoy your Cursor Dark Islands theme!"
