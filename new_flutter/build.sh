#!/bin/bash

# Model Day - Vercel Build Script
# This script installs Flutter and builds the web app for Vercel deployment

set -e

echo "🚀 Starting Model Day build process for Vercel..."

# Restore Flutter configuration files
echo "📋 Restoring Flutter configuration files..."
if [ -f "pubspec.yaml.bak" ]; then
    mv pubspec.yaml.bak pubspec.yaml
    echo "✅ Restored pubspec.yaml"
fi

if [ -f "pubspec.lock.bak" ]; then
    mv pubspec.lock.bak pubspec.lock
    echo "✅ Restored pubspec.lock"
fi

# Set Flutter version
FLUTTER_VERSION="3.24.3"
FLUTTER_CHANNEL="stable"

# Create Flutter directory in a persistent location
export FLUTTER_ROOT="/vercel/path0/flutter"
export PATH="$FLUTTER_ROOT/bin:$PATH"

# Create the directory if it doesn't exist
mkdir -p /vercel/path0

# Check if Flutter is already installed
if [ ! -d "$FLUTTER_ROOT" ]; then
    echo "📦 Installing Flutter $FLUTTER_VERSION..."

    # Download and extract Flutter
    cd /vercel/path0
    curl -L -o flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_CHANNEL/linux/flutter_linux_$FLUTTER_VERSION-$FLUTTER_CHANNEL.tar.xz"
    tar xf flutter.tar.xz
    rm flutter.tar.xz

    echo "✅ Flutter installed successfully"
else
    echo "✅ Flutter already installed"
fi

# Verify Flutter installation
echo "🔍 Verifying Flutter installation..."
flutter --version

# Configure Flutter for web
echo "🌐 Enabling Flutter web..."
flutter config --enable-web --no-analytics

# Navigate to project directory (current directory should be the project root)
echo "📂 Current directory: $(pwd)"
echo "📁 Directory contents:"
ls -la

# Get dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Build for web
echo "🔨 Building Flutter web app..."
flutter build web --release --web-renderer html --dart-define=FLUTTER_WEB_USE_SKIA=false

# Verify build output
echo "✅ Build completed!"
echo "📁 Build output:"
ls -la build/web/

echo "🎉 Model Day build process completed successfully!"
