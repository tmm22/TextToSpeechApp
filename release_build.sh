#!/bin/bash

# TextToSpeechApp Release Build Script
# This script builds the app for release and prepares it for GitHub distribution

set -e  # Exit on any error

echo "🚀 Building TextToSpeechApp for Release..."

# Clean any previous builds
echo "🧹 Cleaning previous builds..."
rm -rf ./build
rm -rf ./release

# Create release directory
mkdir -p ./release

# Build the app for release
echo "🔨 Building application..."
xcodebuild -project TextToSpeechApp.xcodeproj \
           -scheme TextToSpeechApp \
           -configuration Release \
           -derivedDataPath ./build \
           -destination "platform=macOS" \
           build

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Copy the built app to release directory
    cp -R ./build/Build/Products/Release/TextToSpeechApp.app ./release/
    
    # Create a zip file for GitHub release
    echo "📦 Creating release package..."
    cd ./release
    zip -r TextToSpeechApp-v2.1.0-macOS.zip TextToSpeechApp.app
    cd ..
    
    echo "✅ Release package created: ./release/TextToSpeechApp-v2.1.0-macOS.zip"
    echo ""
    echo "📊 Release artifacts:"
    ls -la ./release/
    echo ""
    echo "🎉 Release build complete!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Test the app in ./release/TextToSpeechApp.app"
    echo "2. Create a GitHub release with tag v2.1.0"
    echo "3. Upload the zip file as a release asset"
    echo "4. Use the content from RELEASE_NOTES_v2.1.0.md as release description"
    
else
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "🔗 GitHub Release Checklist:"
echo "□ Create release with tag: v2.1.0"
echo "□ Upload: TextToSpeechApp-v2.1.0-macOS.zip"
echo "□ Copy release notes from: RELEASE_NOTES_v2.1.0.md"
echo "□ Mark as latest release"
echo "□ Add screenshots to release description"