#!/bin/bash

# Model Day - Deployment Script for Vercel
# This script prepares and deploys the Flutter web app to Vercel

echo "🚀 Starting Model Day deployment process..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

echo "📦 Installing dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies."
    exit 1
fi

echo "🧹 Cleaning previous builds..."
flutter clean

echo "🔨 Building for web..."
flutter build web --release --base-href=/

if [ $? -ne 0 ]; then
    echo "❌ Build failed."
    exit 1
fi

echo "✅ Build completed successfully!"
echo "📁 Build files are in: build/web/"

# Check if Vercel CLI is installed
if command -v vercel &> /dev/null; then
    echo "🌐 Deploying to Vercel..."
    vercel --prod
    
    if [ $? -eq 0 ]; then
        echo "🎉 Deployment successful!"
    else
        echo "⚠️  Deployment failed. Please check Vercel configuration."
    fi
else
    echo "⚠️  Vercel CLI not found. Install with: npm i -g vercel"
    echo "📋 Manual deployment steps:"
    echo "   1. Install Vercel CLI: npm i -g vercel"
    echo "   2. Run: vercel"
    echo "   3. Follow the prompts"
fi

echo "✨ Deployment process completed!"
