# Photo Quality Analyzer

A Flutter mobile application that analyzes photo quality using OpenCV to detect common issues like poor lighting, blur, and lack of color diversity.

## Features

### Quality Analysis
- **Brightness Detection**: Identifies photos that are too dark or too bright
- **Blur Detection**: Uses variance of Laplacian method to detect blurry images
- **Color Variance Analysis**: Detects photos with insufficient color diversity

### User Interface
- **Home Screen**: Clean interface with two primary actions
  - Take Photo: Capture new photos with the camera
  - Import from Gallery: Select existing photos for analysis
- **Camera View**: Full-screen camera preview with intuitive capture button
- **Results Display**:
  - Photo thumbnail
  - Quality verdict (Good/Bad with specific issues)
  - Detailed metrics with color-coded badges
  - Option to analyze another photo

### Settings
- **Configurable Thresholds**: Adjust sensitivity for all quality metrics
  - Brightness: Too dark threshold (0-255)
  - Brightness: Too bright threshold (0-255)
  - Blur: Detection threshold (0-500)
  - Color Variance: Diversity threshold (0-100)
- **Reset to Defaults**: Restore original threshold values
- **Persistent Settings**: Settings maintained during app session

## Technical Stack

### Dependencies
- **Flutter**: Cross-platform mobile framework
- **opencv_dart**: OpenCV bindings for image processing
- **camera**: Camera access and capture
- **image_picker**: Gallery image selection
- **path_provider**: File system access
- **permission_handler**: Runtime permissions

### Analysis Methods
1. **Brightness Analysis**
   - Converts image to grayscale
   - Calculates mean brightness (0-255 scale)
   - Classifies as too dark, too bright, or normal

2. **Blur Detection**
   - Variance of Laplacian method
   - Applies Laplacian operator to detect edges
   - Calculates variance (higher = sharper)
   - Industry-standard blur detection technique

3. **Color Variance**
   - Multi-channel analysis (BGR)
   - Calculates standard deviation across all channels
   - Determines color diversity level

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- Android Studio / Xcode for platform-specific development
- Physical device or emulator with camera support

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd photoquality
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
Permissions are already configured in `android/app/src/main/AndroidManifest.xml`:
- Camera access
- External storage read/write
- Camera hardware feature

#### iOS
Permissions are configured in `ios/Runner/Info.plist`:
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   ├── analyzer_settings.dart    # Settings model
│   └── quality_result.dart       # Result data model
├── screens/
│   ├── home_screen.dart          # Main screen with camera/gallery options
│   └── settings_screen.dart      # Threshold configuration
├── services/
│   └── quality_analyzer.dart     # OpenCV-based quality analysis
└── widgets/
    └── result_display.dart       # Legacy result display widget
```

## Usage

### Analyzing Photos

1. **Launch the app**
   - Home screen displays with two buttons

2. **Choose input method**
   - Tap "Take Photo" to capture with camera
   - Tap "Import from Gallery" to select existing photo

3. **View results**
   - Photo thumbnail is displayed
   - Quality verdict shown (Good/Bad)
   - Detailed metrics with scores and classifications
   - Color-coded badges (Green = good, Orange = issues)

4. **Analyze another photo**
   - Tap "Analyze Another Photo" to return to home screen

### Adjusting Settings

1. **Open settings**
   - Tap the gear icon (⚙️) in the top-right corner

2. **Adjust thresholds**
   - Use sliders to modify threshold values
   - Real-time value display for each setting
   - Descriptions explain what each threshold controls

3. **Save or reset**
   - Tap "Save Settings" to apply changes
   - Tap "Reset" to restore default values

### Default Thresholds

- **Too Dark Threshold**: 50 (0-255 scale)
- **Too Bright Threshold**: 200 (0-255 scale)
- **Blur Threshold**: 100 (variance of Laplacian)
- **Color Variance Threshold**: 20 (standard deviation)

## Testing

### Functional Tests

**Brightness Testing:**
- Cover camera lens → should detect "Too dark"
- Point at bright light → should detect "Too bright"
- Normal lighting → should show "Normal"

**Blur Testing:**
- Take shaky/blurry photo → should detect "Too blur"
- Take sharp, focused photo → should show "Normal"

**Color Variance Testing:**
- Point at plain white wall → should detect "Less colours"
- Point at colorful scene → should show "Lots of colours"

**Gallery Testing:**
- Import dark image from gallery → correct detection
- Import blurry image → correct detection
- Import plain image → correct detection

## Quality Metrics Explained

### Brightness Score
- Range: 0-255
- 0 = Pure black
- 255 = Pure white
- Default thresholds: <50 (too dark), >200 (too bright)

### Blur Score
- Variance of Laplacian measurement
- Higher values = sharper image
- Lower values = blurrier image
- Default threshold: <100 (too blur)

### Color Variance Score
- Average standard deviation across BGR channels
- Higher values = more color diversity
- Lower values = less color variety
- Default threshold: <20 (less colours)

## Development

### Running in Development Mode
```bash
flutter run --debug
```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

### Code Analysis
```bash
flutter analyze
```

### Running Tests
```bash
flutter test
```

## Known Limitations

- Camera functionality requires physical device (simulators have limited support)
- Settings do not persist between app sessions (in-memory only)
- Analysis is performed on device (no cloud processing)
- OpenCV operations may take 1-2 seconds on older devices

## Future Enhancements

- Persistent settings storage (SharedPreferences)
- Batch photo analysis
- Export analysis reports
- Additional quality metrics (noise, contrast, saturation)
- ML-based quality assessment
- Photo comparison mode
- History of analyzed photos

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with Flutter framework
- OpenCV for image processing
- Variance of Laplacian blur detection method
- Material Design 3 UI components

## Support

For issues, questions, or contributions, please open an issue on the project repository.

---

**Version**: 1.0.0
**Last Updated**: January 2026
**Developed with**: Flutter 3.38.7 & Dart 3.10.7
