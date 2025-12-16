#!/usr/bin/env node

/**
 * PWA Icon Generator
 * Generates all required PWA icons from a source PNG image
 * 
 * Usage: node scripts/generate-icons.js <source-image.png>
 * Example: node scripts/generate-icons.js public/icon-source.png
 */

import sharp from 'sharp'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// Icon sizes to generate
const ICON_SIZES = [
  { name: 'apple-touch-icon.png', size: 180 },
  { name: 'icon-512x512.png', size: 512 },
  { name: 'icon-384x384.png', size: 384 },
  { name: 'icon-192x192.png', size: 192 },
  { name: 'icon-152x152.png', size: 152 },
  { name: 'icon-144x144.png', size: 144 },
  { name: 'icon-128x128.png', size: 128 },
  { name: 'icon-96x96.png', size: 96 },
  { name: 'icon-72x72.png', size: 72 },
  { name: 'icon-32x32.png', size: 32 },
  { name: 'icon-16x16.png', size: 16 }
]

const OUTPUT_DIR = path.join(__dirname, '../public/icons')

async function generateIcons(sourceImagePath) {
  try {
    // Check if source image exists
    if (!fs.existsSync(sourceImagePath)) {
      console.error(`❌ Source image not found: ${sourceImagePath}`)
      process.exit(1)
    }

    // Create output directory if it doesn't exist
    if (!fs.existsSync(OUTPUT_DIR)) {
      fs.mkdirSync(OUTPUT_DIR, { recursive: true })
      console.log(`📁 Created directory: ${OUTPUT_DIR}`)
    }

    console.log(`🔄 Generating PWA icons from: ${sourceImagePath}`)
    console.log(`📂 Output directory: ${OUTPUT_DIR}\n`)

    // Generate each icon size
    for (const icon of ICON_SIZES) {
      const outputPath = path.join(OUTPUT_DIR, icon.name)
      
      await sharp(sourceImagePath)
        .resize(icon.size, icon.size, {
          fit: 'contain',
          background: { r: 0, g: 0, b: 0, alpha: 0 } // Transparent background
        })
        .png()
        .toFile(outputPath)
      
      console.log(`✅ Generated: ${icon.name} (${icon.size}x${icon.size})`)
    }

    console.log(`\n✨ All icons generated successfully!`)
    console.log(`📋 Generated ${ICON_SIZES.length} icon files in ${OUTPUT_DIR}/`)
    
    // List generated files
    console.log(`\n📁 Generated files:`)
    const files = fs.readdirSync(OUTPUT_DIR)
      .filter(f => f.endsWith('.png'))
      .sort()
    files.forEach(file => {
      const stats = fs.statSync(path.join(OUTPUT_DIR, file))
      const sizeKB = (stats.size / 1024).toFixed(2)
      console.log(`   - ${file} (${sizeKB} KB)`)
    })

  } catch (error) {
    console.error(`❌ Error generating icons:`, error.message)
    process.exit(1)
  }
}

// Get source image path from command line arguments
const sourceImage = process.argv[2]

if (!sourceImage) {
  console.log('📱 PWA Icon Generator')
  console.log('')
  console.log('Usage: node scripts/generate-icons.js <source-image.png>')
  console.log('')
  console.log('Example:')
  console.log('  node scripts/generate-icons.js public/icon-source.png')
  console.log('')
  console.log('The source image should be:')
  console.log('  - PNG format (recommended)')
  console.log('  - At least 512x512 pixels')
  console.log('  - Square aspect ratio (1:1)')
  console.log('  - Transparent background (optional but recommended)')
  process.exit(1)
}

generateIcons(sourceImage)

