class LLMAnalysisResult {
  const LLMAnalysisResult({
    required this.rawResponse,
    this.profileInsight = '',
    this.blindSpotWarning = '',
    this.patternDetection = '',
    this.personalizedAdvice = '',
    this.biasFlags = const <String>[],
    this.valueExtractions = const <String>[],
    this.emotionalToneLabel = '',
    this.confidenceScore = 0.0,
    this.error,
  });

  final String rawResponse;
  final String profileInsight;
  final String blindSpotWarning;
  final String patternDetection;
  final String personalizedAdvice;
  final List<String> biasFlags;
  final List<String> valueExtractions;
  final String emotionalToneLabel;
  final double confidenceScore;
  final String? error;

  bool get hasError => error != null;
  bool get isEmpty => rawResponse.isEmpty;
}

enum AnalysisType {
  profileDeepDive,
  dateReflection,
  interactionInsight,
  dailyCheckInFeedback,
  patternEvolution,
  narrativeAnalysis,
}
