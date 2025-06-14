#!/bin/bash

# Install Flutter if not available
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found. Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 /opt/flutter
    export PATH="$PATH:/opt/flutter/bin"
fi

# Navigate to Flutter project directory
cd new_flutter

# Get Flutter dependencies
flutter pub get

# Build for web
flutter build web --release --base-href=/

echo "Build completed successfully!"
