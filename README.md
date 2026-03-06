# Weather Screen Saver

A macOS Screen Saver that displays ASCII art weather animations using data from Open-Meteo API.

## Features

- ASCII art weather animations
- Real weather data from Open-Meteo API
- Configurable location (latitude/longitude)
- Metric/Imperial units
- Configurable update interval
- macOS 13+ support (including macOS 15, 26 Tahoe)
- Universal binary (arm64 + x86_64)

## Project Structure

```
weathr-saver/
 ├── weathr-core/       # Rust library with C ABI
 ├── macos-screensaver/ # Swift ScreenSaver bundle
 └── build-pipeline/    # GitHub Actions workflows
```

## Building

### Prerequisites

- macOS 13+
- Rust (installed via GitHub Actions)
- Xcode 15+
- XcodeGen

### Local Build

1. Install XcodeGen:
   ```bash
   brew install xcodegen
   ```

2. Build the project:
   ```bash
   # Build Rust library
   cd weathr-core
   cargo build --release
   
   # Generate Xcode project
   cd ../macos-screensaver
   xcodegen generate
   
   # Build ScreenSaver
   xcodebuild -project WeatherSaver.xcodeproj -scheme WeatherSaver -configuration Release build
   ```

## Installation

1. Download the latest `Weather.saver.zip` from GitHub Releases
2. Unzip the archive
3. Double-click `Weather.saver`
4. macOS will prompt to install the screen saver

## Configuration

The screen saver can be configured with:
- City name
- Latitude/Longitude coordinates
- Temperature units (Metric/Imperial)
- Update interval (5 min - 1 hour)

Access settings via System Settings > Screen Saver > Weather > Screen Saver Options

## Development

The project uses GitHub Actions for CI/CD:
- Automatic builds on push to main
- Universal binary creation (arm64 + x86_64)
- Release creation on tag push

## License

GPL-3.0-or-later
