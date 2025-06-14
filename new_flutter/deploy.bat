@echo off
REM Model Day - Deployment Script for Vercel (Windows)
REM This script prepares and deploys the Flutter web app to Vercel

echo 🚀 Starting Model Day deployment process...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed. Please install Flutter first.
    pause
    exit /b 1
)

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo ❌ pubspec.yaml not found. Please run this script from the project root.
    pause
    exit /b 1
)

echo 📦 Installing dependencies...
flutter pub get

if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies.
    pause
    exit /b 1
)

echo 🧹 Cleaning previous builds...
flutter clean

echo 🔨 Building for web...
flutter build web --release --base-href=/

if %errorlevel% neq 0 (
    echo ❌ Build failed.
    pause
    exit /b 1
)

echo ✅ Build completed successfully!
echo 📁 Build files are in: build/web/

REM Check if Vercel CLI is installed
vercel --version >nul 2>&1
if %errorlevel% equ 0 (
    echo 🌐 Deploying to Vercel...
    vercel --prod
    
    if %errorlevel% equ 0 (
        echo 🎉 Deployment successful!
    ) else (
        echo ⚠️  Deployment failed. Please check Vercel configuration.
    )
) else (
    echo ⚠️  Vercel CLI not found. Install with: npm i -g vercel
    echo 📋 Manual deployment steps:
    echo    1. Install Vercel CLI: npm i -g vercel
    echo    2. Run: vercel
    echo    3. Follow the prompts
)

echo ✨ Deployment process completed!
pause
