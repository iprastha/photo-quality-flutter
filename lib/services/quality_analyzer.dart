import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../models/quality_result.dart';

class QualityAnalyzer {
  // Brightness thresholds (0-255 scale)
  static const double _tooDarkThreshold = 50.0;
  static const double _tooBrightThreshold = 200.0;

  // Blur threshold (variance of Laplacian)
  static const double _blurThreshold = 100.0; // Below this = too blur

  // Color variance threshold (standard deviation)
  static const double _lowColorVarianceThreshold = 20.0; // Below this = less colours

  /// Analyzes the quality of an image file
  /// Returns QualityResult with comprehensive quality metrics
  Future<QualityResult> analyzeImage(String imagePath) async {
    try {
      // Read image from file
      final image = cv.imread(imagePath);

      if (image.isEmpty) {
        return _createErrorResult('Failed to load image');
      }

      // 1. Analyze brightness
      final brightnessScore = _calculateBrightness(image);
      final brightnessLevel = _getBrightnessLevel(brightnessScore);

      // 2. Analyze blur using variance of Laplacian
      final blurScore = _calculateBlurScore(image);
      final blurLevel = _getBlurLevel(blurScore);

      // 3. Analyze color variance
      final colorVarianceScore = _calculateColorVariance(image);
      final colorVarianceLevel = _getColorVarianceLevel(colorVarianceScore);

      image.dispose();

      // Determine overall quality and reason
      final issues = <String>[];
      if (brightnessLevel == 'Too dark') issues.add('too dark');
      if (brightnessLevel == 'Too bright') issues.add('too bright');
      if (blurLevel == 'Too blur') issues.add('too blur');
      if (colorVarianceLevel == 'Less colours') issues.add('lacks color variety');

      final isGood = issues.isEmpty;
      final reason = isGood ? 'Good quality' : 'Issues: ${issues.join(', ')}';

      return QualityResult(
        isGood: isGood,
        reason: reason,
        brightnessScore: brightnessScore,
        brightnessLevel: brightnessLevel,
        blurScore: blurScore,
        blurLevel: blurLevel,
        colorVarianceScore: colorVarianceScore,
        colorVarianceLevel: colorVarianceLevel,
      );
    } catch (e) {
      return _createErrorResult('Analysis failed: $e');
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

  /// Determine brightness level based on score
  String _getBrightnessLevel(double score) {
    if (score < _tooDarkThreshold) {
      return 'Too dark';
    } else if (score > _tooBrightThreshold) {
      return 'Too bright';
    } else {
      return 'Normal';
    }
  }

  /// Calculate blur score using variance of Laplacian method
  /// Higher score = sharper image, lower score = blurrier image
  double _calculateBlurScore(cv.Mat image) {
    // Convert to grayscale
    final gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY);

    // Apply Laplacian operator (ddepth: CV_64F = 6)
    final laplacian = cv.laplacian(gray, 6);

    // Calculate variance of the Laplacian
    final (mean, stddev) = cv.meanStdDev(laplacian);
    final variance = stddev.val1 * stddev.val1; // Variance = stddev^2

    gray.dispose();
    laplacian.dispose();
    mean.dispose();
    stddev.dispose();

    return variance;
  }

  /// Determine blur level based on score
  String _getBlurLevel(double score) {
    if (score < _blurThreshold) {
      return 'Too blur';
    } else {
      return 'Normal';
    }
  }

  /// Calculate color variance (standard deviation across all color channels)
  double _calculateColorVariance(cv.Mat image) {
    // Calculate standard deviation across all channels
    final (mean, stddev) = cv.meanStdDev(image);

    // Average the standard deviation across all channels (BGR)
    final avgStdDev = (stddev.val1 + stddev.val2 + stddev.val3) / 3.0;

    mean.dispose();
    stddev.dispose();

    return avgStdDev;
  }

  /// Determine color variance level based on score
  String _getColorVarianceLevel(double score) {
    if (score < _lowColorVarianceThreshold) {
      return 'Less colours';
    } else {
      return 'Lots of colours';
    }
  }

  /// Create an error result
  QualityResult _createErrorResult(String message) {
    return QualityResult(
      isGood: false,
      reason: message,
      brightnessScore: 0.0,
      brightnessLevel: 'Unknown',
      blurScore: 0.0,
      blurLevel: 'Unknown',
      colorVarianceScore: 0.0,
      colorVarianceLevel: 'Unknown',
    );
  }
}
