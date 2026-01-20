class QualityResult {
  final bool isGood;
  final String reason;
  final double brightnessScore;
  final double varianceScore;

  QualityResult({
    required this.isGood,
    required this.reason,
    required this.brightnessScore,
    required this.varianceScore,
  });

  @override
  String toString() {
    return 'QualityResult(isGood: $isGood, reason: $reason, '
        'brightness: ${brightnessScore.toStringAsFixed(2)}, '
        'variance: ${varianceScore.toStringAsFixed(2)})';
  }
}
