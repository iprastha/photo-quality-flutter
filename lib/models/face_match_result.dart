class FaceMatchResult {
  final bool isMatch; // Is this the enrolled person?
  final double similarity; // Cosine similarity score (0-1, higher = more similar)
  final String confidence; // "Very High", "High", "Medium", "Low", "Very Low"

  FaceMatchResult({
    required this.isMatch,
    required this.similarity,
    required this.confidence,
  });

  String get confidenceLevel {
    // Cosine similarity: higher values = more similar
    if (similarity >= 0.75) return 'Very High';
    if (similarity >= 0.65) return 'High';
    if (similarity >= 0.55) return 'Medium';
    if (similarity >= 0.45) return 'Low';
    return 'Very Low';
  }
}
