enum AiTaskType {
  chatOnboardingTurn,
  beliefExtraction,
  onboardingMirror,
  profileAnalysis,
  adaptiveFollowUps,
  reflectionReport,
  dailyCheckIn,
  interactionInsight,
  narrativeAnalysis,
}

enum AiRunMode {
  local,
  vector,
  llm,
  hybrid,
}

class ChatTurnPayload {
  const ChatTurnPayload({
    required this.reply,
    this.extractedFields = const <String, dynamic>{},
    this.acknowledgedSensitiveContext = false,
  });

  final String reply;
  final Map<String, dynamic> extractedFields;
  final bool acknowledgedSensitiveContext;
}

class BeliefExtractionPayload {
  const BeliefExtractionPayload({
    required this.beliefRightPersonFindsWay,
    required this.beliefChemistryFeltFast,
    required this.beliefStrongAttractionIsSign,
    required this.beliefFeelsRightOrNot,
    required this.beliefFirstFeelingsAreTruth,
    required this.beliefPotentialEqualsValue,
    required this.beliefAmbiguityIsNormal,
    required this.beliefLoveOvercomesIssues,
  });

  final int beliefRightPersonFindsWay;
  final int beliefChemistryFeltFast;
  final int beliefStrongAttractionIsSign;
  final int beliefFeelsRightOrNot;
  final int beliefFirstFeelingsAreTruth;
  final int beliefPotentialEqualsValue;
  final int beliefAmbiguityIsNormal;
  final int beliefLoveOvercomesIssues;
}

class AiEnvelope<T> {
  const AiEnvelope({
    required this.task,
    required this.mode,
    required this.payload,
    required this.latencyMs,
    required this.contentHash,
    this.isEnhanced = false,
    this.isCached = false,
    this.provider,
    this.note,
    this.error,
  });

  final AiTaskType task;
  final AiRunMode mode;
  final T payload;
  final int latencyMs;
  final String contentHash;
  final bool isEnhanced;
  final bool isCached;
  final String? provider;
  final String? note;
  final String? error;

  bool get hasError => error != null && error!.trim().isNotEmpty;
}
