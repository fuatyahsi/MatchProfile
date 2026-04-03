enum RelationshipGoal {
  serious('Ciddi ilişki'),
  explore('Açık keşif'),
  shortTerm('Kısa dönem');

  const RelationshipGoal(this.label);

  final String label;
}

enum ConfidenceLabel {
  high('Yüksek Kanıt'),
  medium('Orta Kanıt'),
  low('Düşük Kanıt'),
  missing('Veri Eksik'),
  interpretation('Kullanıcı Yorumu Ağırlıklı'),
  pattern('Geçmiş Örüntü Benzerliği');

  const ConfidenceLabel(this.label);

  final String label;
}

enum ValidationChoice {
  dogru('Doğru'),
  eksik('Eksik'),
  yanlis('Yanlış'),
  veriYetersiz('Veri yetersiz');

  const ValidationChoice(this.label);

  final String label;
}

class OnboardingProfile {
  const OnboardingProfile({
    required this.displayName,
    required this.goal,
    required this.values,
    required this.dealbreakers,
    required this.biasFlags,
    required this.highSafetySensitivity,
    required this.ageConfirmed,
    required this.policyAccepted,
  });

  final String displayName;
  final RelationshipGoal goal;
  final List<String> values;
  final List<String> dealbreakers;
  final List<String> biasFlags;
  final bool highSafetySensitivity;
  final bool ageConfirmed;
  final bool policyAccepted;
}

class ReflectionDraft {
  const ReflectionDraft({
    required this.dateContext,
    required this.debrief,
    required this.followUpOffer,
    required this.futurePlanSignal,
    required this.comfortLevel,
    required this.clarityLevel,
    required this.physicalBoundaryIssue,
    required this.clarificationAnswers,
  });

  final String dateContext;
  final String debrief;
  final String followUpOffer;
  final String futurePlanSignal;
  final String comfortLevel;
  final String clarityLevel;
  final bool physicalBoundaryIssue;
  final List<String> clarificationAnswers;
}

class EvidenceItem {
  const EvidenceItem({required this.source, required this.text});

  final String source;
  final String text;
}

class InsightSignal {
  const InsightSignal({
    required this.id,
    required this.title,
    required this.explanation,
    required this.signalType,
    required this.confidenceLabel,
    required this.evidenceItems,
    this.validation,
  });

  final String id;
  final String title;
  final String explanation;
  final String signalType;
  final ConfidenceLabel confidenceLabel;
  final List<EvidenceItem> evidenceItems;
  final ValidationChoice? validation;

  InsightSignal copyWith({ValidationChoice? validation}) {
    return InsightSignal(
      id: id,
      title: title,
      explanation: explanation,
      signalType: signalType,
      confidenceLabel: confidenceLabel,
      evidenceItems: evidenceItems,
      validation: validation ?? this.validation,
    );
  }
}

class SafetyAssessment {
  const SafetyAssessment({
    required this.escalated,
    required this.headline,
    required this.summary,
    required this.actions,
  });

  final bool escalated;
  final String headline;
  final String summary;
  final List<String> actions;
}

class InsightReport {
  const InsightReport({
    required this.schemaVersion,
    required this.sessionId,
    required this.summary,
    required this.positiveSignals,
    required this.cautionSignals,
    required this.uncertaintyFlags,
    required this.missingDataPoints,
    required this.recommendedQuestions,
    required this.nextStep,
    required this.safetyAssessment,
    required this.memoryUpdates,
  });

  final String schemaVersion;
  final String sessionId;
  final String summary;
  final List<InsightSignal> positiveSignals;
  final List<InsightSignal> cautionSignals;
  final List<String> uncertaintyFlags;
  final List<String> missingDataPoints;
  final List<String> recommendedQuestions;
  final String nextStep;
  final SafetyAssessment safetyAssessment;
  final List<String> memoryUpdates;

  InsightReport applyValidations(Map<String, ValidationChoice> validations) {
    List<InsightSignal> patch(List<InsightSignal> signals) {
      return signals
          .map(
            (InsightSignal signal) =>
                signal.copyWith(validation: validations[signal.id]),
          )
          .toList(growable: false);
    }

    return InsightReport(
      schemaVersion: schemaVersion,
      sessionId: sessionId,
      summary: summary,
      positiveSignals: patch(positiveSignals),
      cautionSignals: patch(cautionSignals),
      uncertaintyFlags: uncertaintyFlags,
      missingDataPoints: missingDataPoints,
      recommendedQuestions: recommendedQuestions,
      nextStep: nextStep,
      safetyAssessment: safetyAssessment,
      memoryUpdates: memoryUpdates,
    );
  }

  List<InsightSignal> get allSignals => <InsightSignal>[
    ...positiveSignals,
    ...cautionSignals,
  ];
}

class JournalEntry {
  const JournalEntry({
    required this.title,
    required this.createdAt,
    required this.report,
    required this.outcomeLabel,
    required this.pendingCheckIns,
  });

  final String title;
  final DateTime createdAt;
  final InsightReport report;
  final String outcomeLabel;
  final List<int> pendingCheckIns;
}
