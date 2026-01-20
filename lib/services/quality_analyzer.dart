import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../models/quality_result.dart';

class QualityAnalyzer {
  // Thresholds for quality detection
  static const double _darkThreshold = 35.0; // Mean brightness below this = too dark
  static const double _varianceThreshold = 15.0; // Std deviation below this = too plain
  static const double _edgeRatioThreshold = 0.05; // Edge pixels below 5% = too plain

  /// Analyzes the quality of an image file
  /// Returns QualityResult indicating if photo is good or bad with reason
  Future<QualityResult> analyzeImage(String imagePath) async {
    try {
      // Read image from file
      final image = cv.imread(imagePath);

      if (image.isEmpty) {
        return QualityResult(
          isGood: false,
          reason: 'Failed to load image',
          brightnessScore: 0.0,
          varianceScore: 0.0,
        );
      }

      // 1. Check for darkness
      final brightnessScore = _calculateBrightness(image);
      if (brightnessScore < _darkThreshold) {
        image.dispose();
        return QualityResult(
          isGood: false,
          reason: 'Too dark',
          brightnessScore: brightnessScore,
          varianceScore: 0.0,
        );
      }

      // 2. Check for plainness (single color/lack of detail)
      final varianceScore = _calculateColorVariance(image);
      final edgeRatio = _calculateEdgeRatio(image);

      image.dispose();

      // If both variance and edge ratio are low, image is too plain
      if (varianceScore < _varianceThreshold && edgeRatio < _edgeRatioThreshold) {
        return QualityResult(
          isGood: false,
          reason: 'Too plain',
          brightnessScore: brightnessScore,
          varianceScore: varianceScore,
        );
      }

      // Image passes quality checks
      return QualityResult(
        isGood: true,
        reason: 'Good quality',
        brightnessScore: brightnessScore,
        varianceScore: varianceScore,
      );
    } catch (e) {
      return QualityResult(
        isGood: false,
        reason: 'Analysis failed: $e',
        brightnessScore: 0.0,
        varianceScore: 0.0,
      );
    }
  }

  /// Calculate mean brightness of the image (0-255 scale)
  double _calculateBrightness(cv.Mat image) {
    // Convert to grayscale
    final gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY);

    // Calculate mean brightness
    final meanScalar = cv.mean(gray);
    final brightness = meanScalar.val1;

    gray.dispose();
    return brightness;
  }

  /// Calculate color variance (standard deviation) to detect plain images
  double _calculateColorVariance(cv.Mat image) {
    // Convert to grayscale for simplicity
    final gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY);

    // Calculate mean and standard deviation
    final (mean, stddev) = cv.meanStdDev(gray);
    final variance = stddev.val1;

    gray.dispose();
    mean.dispose();
    stddev.dispose();

    return variance;
  }

  /// Calculate edge ratio using Canny edge detection
  double _calculateEdgeRatio(cv.Mat image) {
    // Convert to grayscale
    final gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY);

    // Apply Canny edge detection
    final edges = cv.canny(gray, 50, 150);

    // Count edge pixels (non-zero pixels)
    final edgeCount = cv.countNonZero(edges);
    final totalPixels = image.rows * image.cols;
    final edgeRatio = edgeCount / totalPixels;

    gray.dispose();
    edges.dispose();

    return edgeRatio;
  }
}
