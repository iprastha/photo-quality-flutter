import 'face_match_result.dart';

class QualityResult {
  final bool isGood;
  final String reason;

  // Analysis metrics
  final double brightnessScore;
  final String brightnessLevel; // "Too dark", "Too bright", "Normal"
  final double blurScore;
  final String blurLevel; // "Too blur", "Normal"
  final double colorVarianceScore;
  final String colorVarianceLevel; // "Lots of colours", "Less colours"
  final int faceCount; // Number of faces detected

  // Face recognition
  final FaceMatchResult? faceMatch; // Null if no profile or no faces detected
  final bool? hasEnrolledProfile; // Is there an enrolled profile?

  QualityResult({
    required this.isGood,
    required this.reason,
    required this.brightnessScore,
    required this.brightnessLevel,
    required this.blurScore,
    required this.blurLevel,
    required this.colorVarianceScore,
    required this.colorVarianceLevel,
    required this.faceCount,
    this.faceMatch,
    this.hasEnrolledProfile,
  });

  @override
  String toString() {
    return 'QualityResult(isGood: $isGood, reason: $reason, '
        'brightness: ${brightnessScore.toStringAsFixed(2)} ($brightnessLevel), '
        'blur: ${blurScore.toStringAsFixed(2)} ($blurLevel), '
        'colorVariance: ${colorVarianceScore.toStringAsFixed(2)} ($colorVarianceLevel), '
        'faces: $faceCount, '
        'faceMatch: ${faceMatch?.isMatch}, hasProfile: $hasEnrolledProfile)';
  }
}
