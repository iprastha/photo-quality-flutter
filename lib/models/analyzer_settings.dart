class AnalyzerSettings {
  // Brightness thresholds (0-255 scale)
  final double tooDarkThreshold;
  final double tooBrightThreshold;

  // Blur threshold (variance of Laplacian)
  final double blurThreshold;

  // Color variance threshold (standard deviation)
  final double colorVarianceThreshold;

  const AnalyzerSettings({
    required this.tooDarkThreshold,
    required this.tooBrightThreshold,
    required this.blurThreshold,
    required this.colorVarianceThreshold,
  });

  // Default settings
  static const AnalyzerSettings defaults = AnalyzerSettings(
    tooDarkThreshold: 50.0,
    tooBrightThreshold: 200.0,
    blurThreshold: 50.0,
    colorVarianceThreshold: 20.0,
  );

  AnalyzerSettings copyWith({
    double? tooDarkThreshold,
    double? tooBrightThreshold,
    double? blurThreshold,
    double? colorVarianceThreshold,
  }) {
    return AnalyzerSettings(
      tooDarkThreshold: tooDarkThreshold ?? this.tooDarkThreshold,
      tooBrightThreshold: tooBrightThreshold ?? this.tooBrightThreshold,
      blurThreshold: blurThreshold ?? this.blurThreshold,
      colorVarianceThreshold: colorVarianceThreshold ?? this.colorVarianceThreshold,
    );
  }
}
