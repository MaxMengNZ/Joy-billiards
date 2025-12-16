#!/bin/bash

# Icon Generation Script for Joy Billiards PWA
# This script generates all required PWA icons from a source image

SOURCE_IMAGE="public/JoyBilliards-Logo.svg"
OUTPUT_DIR="public/icons"

# Create icons directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick is not installed."
    echo "Install it with: brew install imagemagick (macOS) or apt-get install imagemagick (Linux)"
    exit 1
fi

# Check if source image exists
if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "❌ Source image not found: $SOURCE_IMAGE"
    echo "Please provide a source image (PNG, SVG, or JPG) at least 512x512px"
    exit 1
fi

echo "🔄 Generating PWA icons from $SOURCE_IMAGE..."

# Generate all required icon sizes
convert "$SOURCE_IMAGE" -resize 512x512 -background none -gravity center -extent 512x512 "$OUTPUT_DIR/icon-512x512.png"
convert "$SOURCE_IMAGE" -resize 384x384 -background none -gravity center -extent 384x384 "$OUTPUT_DIR/icon-384x384.png"
convert "$SOURCE_IMAGE" -resize 192x192 -background none -gravity center -extent 192x192 "$OUTPUT_DIR/icon-192x192.png"
convert "$SOURCE_IMAGE" -resize 180x180 -background none -gravity center -extent 180x180 "$OUTPUT_DIR/apple-touch-icon.png"
convert "$SOURCE_IMAGE" -resize 152x152 -background none -gravity center -extent 152x152 "$OUTPUT_DIR/icon-152x152.png"
convert "$SOURCE_IMAGE" -resize 144x144 -background none -gravity center -extent 144x144 "$OUTPUT_DIR/icon-144x144.png"
convert "$SOURCE_IMAGE" -resize 128x128 -background none -gravity center -extent 128x128 "$OUTPUT_DIR/icon-128x128.png"
convert "$SOURCE_IMAGE" -resize 96x96 -background none -gravity center -extent 96x96 "$OUTPUT_DIR/icon-96x96.png"
convert "$SOURCE_IMAGE" -resize 72x72 -background none -gravity center -extent 72x72 "$OUTPUT_DIR/icon-72x72.png"
convert "$SOURCE_IMAGE" -resize 32x32 -background none -gravity center -extent 32x32 "$OUTPUT_DIR/icon-32x32.png"
convert "$SOURCE_IMAGE" -resize 16x16 -background none -gravity center -extent 16x16 "$OUTPUT_DIR/icon-16x16.png"

echo "✅ All icons generated successfully in $OUTPUT_DIR/"
echo ""
echo "📋 Generated icons:"
ls -lh "$OUTPUT_DIR"/*.png

