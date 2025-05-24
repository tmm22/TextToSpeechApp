#!/bin/bash

# Text-to-Speech App Build Script
# This script builds the macOS Text-to-Speech application

set -e  # Exit on any error

echo "🎙️  Building Text-to-Speech macOS App..."
echo "=================================="

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode command line tools not found!"
    echo "Please install Xcode and run: xcode-select --install"
    exit 1
fi

# Project configuration
PROJECT_NAME="TextToSpeechApp"
PROJECT_FILE="${PROJECT_NAME}.xcodeproj"
SCHEME="${PROJECT_NAME}"
CONFIGURATION="Release"
BUILD_DIR="build"

# Check if project file exists
if [ ! -d "$PROJECT_FILE" ]; then
    echo "❌ Error: $PROJECT_FILE not found!"
    echo "Make sure you're in the correct directory."
    exit 1
fi

echo "📁 Project: $PROJECT_FILE"
echo "🎯 Scheme: $SCHEME"
echo "⚙️  Configuration: $CONFIGURATION"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
xcodebuild clean -project "$PROJECT_FILE" -scheme "$SCHEME" -configuration "$CONFIGURATION"

echo ""
echo "🔨 Building application..."

# Build the project
xcodebuild \
    -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$BUILD_DIR" \
    SYMROOT="$BUILD_DIR" \
    build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📱 Application built at:"
    APP_PATH="$BUILD_DIR/$CONFIGURATION/${PROJECT_NAME}.app"
    echo "   $APP_PATH"
    
    if [ -d "$APP_PATH" ]; then
        echo ""
        echo "🚀 To run the application:"
        echo "   open \"$APP_PATH\""
        echo ""
        echo "📦 To create a distributable package:"
        echo "   You can now archive and notarize this app for distribution"
    else
        echo "⚠️  Warning: App bundle not found at expected location"
    fi
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "🎉 Build process completed!"