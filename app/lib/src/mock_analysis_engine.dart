import 'models.dart';

class MockAnalysisEngine {
  static InsightReport build({
    required ReflectionDraft draft,
    required OnboardingProfile profile,
    required String sessionId,
  }) {
    final String combined =
        '${draft.dateContext} ${draft.debrief} ${draft.clarificationAnswers.join(' ')}'
            .toLowerCase();

    final bool safetyEscalated =
        draft.physicalBoundaryIssue ||
        _containsAny(combined, const <String>[
          'korktum',
          'tehdit',
          'takip',
          'ısrar',
          'baskı',
          'sınır',
          'rahatsız oldum',
        ]);

    final List<InsightSignal> positiveSignals = <InsightSignal>[];
    final List<InsightSignal> cautionSignals = <InsightSignal>[];
    final List<String> uncertaintyFlags = <String>[];
    final List<String> missingDataPoints = <String>[];
    final List<String> recommendedQuestions = <String>[];
    final List<String> memoryUpdates = <String>[];

    if (_containsAny(combined, const <String>[
      'dinledi',
      'merak',
      'soru sordu',
      'ilgiliydi',
      'nazik',
    ])) {
      positiveSignals.add(
        InsightSignal(
          id: 'positive-curiosity',
          title: 'Karşılıklı merak sinyali',
          explanation:
              'Anlatımında soru sorma, aktif dinleme veya ilgiyi sürdüren davranış örnekleri var.',
          signalType: 'curiosity',
          confidenceLabel: ConfidenceLabel.medium,
          evidenceItems: <EvidenceItem>[
            EvidenceItem(source: 'user_reported_fact', text: draft.debrief),
          ],
        ),
      );
    }

    if (draft.followUpOffer == 'Evet' || draft.futurePlanSignal == 'Var') {
      positiveSignals.add(
        InsightSignal(
          id: 'positive-follow-up',
          title: 'Devam etme niyeti işareti',
          explanation:
              'Takip teklifinin veya geleceğe dönük plan sinyalinin olması ikinci görüşme ihtimalini destekliyor.',
          signalType: 'follow_up_intent',
          confidenceLabel: ConfidenceLabel.high,
          evidenceItems: <EvidenceItem>[
            EvidenceItem(
              source: 'structured_response',
              text:
                  'follow_up_offer=${draft.followUpOffer}, future_plan_signal=${draft.futurePlanSignal}',
            ),
          ],
        ),
      );
    }

    if (draft.comfortLevel == 'Düşük' || draft.clarityLevel == 'Belirsiz') {
      cautionSignals.add(
        InsightSignal(
          id: 'caution-ambiguity',
          title: 'Belirsizlik yüksek',
          explanation:
              'Konfor veya netlik alanı düşük kaldığı için bu oturum güçlü karar vermek için erken olabilir.',
          signalType: 'ambiguity',
          confidenceLabel: ConfidenceLabel.medium,
          evidenceItems: <EvidenceItem>[
            EvidenceItem(
              source: 'structured_response',
              text:
                  'comfort_level=${draft.comfortLevel}, clarity_level=${draft.clarityLevel}',
            ),
          ],
        ),
      );
      uncertaintyFlags.add(
        'İlgi ile gerçek niyet arasında hâlâ veri boşluğu olabilir.',
      );
      recommendedQuestions.add(
        'Bir sonraki görüşme için somut plan önerisi geliyor mu?',
      );
    }

    if (draft.followUpOffer == 'Hayır' && draft.futurePlanSignal == 'Yok') {
      cautionSignals.add(
        InsightSignal(
          id: 'caution-low-momentum',
          title: 'Takip momentumu zayıf',
          explanation:
              'Takip teklifi ve geleceğe dönük plan sinyali birlikte yoksa devam olasılığı daha belirsiz olur.',
          signalType: 'momentum',
          confidenceLabel: ConfidenceLabel.high,
          evidenceItems: const <EvidenceItem>[
            EvidenceItem(
              source: 'structured_response',
              text: 'follow_up_offer=Hayır, future_plan_signal=Yok',
            ),
          ],
        ),
      );
    }

    if (safetyEscalated) {
      cautionSignals.insert(
        0,
        InsightSignal(
          id: 'caution-safety',
          title: 'Güvenlik odaklı değerlendirme gerekli',
          explanation:
              'Anlatımında sınır, baskı veya korku çağrıştıran unsurlar bulunduğu için önce güvenlik perspektifi öne alınmalı.',
          signalType: 'safety',
          confidenceLabel: ConfidenceLabel.high,
          evidenceItems: <EvidenceItem>[
            EvidenceItem(source: 'user_reported_fact', text: draft.debrief),
          ],
        ),
      );
      recommendedQuestions.insert(
        0,
        'Bu kişiyle teması yavaşlatmak sana daha güvenli hissettirir mi?',
      );
      memoryUpdates.add('Safety escalation kaydı oluştur.');
    }

    final List<String> lowerValues = profile.values
        .map((String value) => value.toLowerCase())
        .toList(growable: false);
    if (!_containsAny(combined, lowerValues)) {
      missingDataPoints.add(
        'Senin temel değerlerinle uyum hakkında henüz somut örnek az.',
      );
      recommendedQuestions.add(
        'Senin için önemli değerlerden biri bu kişide davranışa dönüşüyor mu?',
      );
    }

    if (draft.futurePlanSignal == 'Belirsiz') {
      missingDataPoints.add(
        'İlişki niyeti ve tempo sinyali daha net test edilmeli.',
      );
    }

    if (positiveSignals.isEmpty) {
      positiveSignals.add(
        const InsightSignal(
          id: 'positive-restraint',
          title: 'Erken yargı vermemek için alan var',
          explanation:
              'Şu an en güçlü değer, raporun belirsizliği görünür kılması; kesin olumlu hüküm üretmek için erken.',
          signalType: 'restraint',
          confidenceLabel: ConfidenceLabel.low,
          evidenceItems: <EvidenceItem>[
            EvidenceItem(
              source: 'missing_observation',
              text: 'Henüz yeterli olumlu örnek yok.',
            ),
          ],
        ),
      );
    }

    if (recommendedQuestions.isEmpty) {
      recommendedQuestions.add(
        'İkinci görüşmede niyet ve tempo hakkında açık soru sorabilir misin?',
      );
    }

    final String summary = safetyEscalated
        ? 'Bu session romantik uyumdan önce güvenlik ve sınır perspektifiyle değerlendirilmeli.'
        : cautionSignals.isEmpty
        ? 'İlk sinyaller umut verici; yine de kararı hızlandırmadan somut davranışları test etmek faydalı olur.'
        : 'Rapor, olumlu sinyaller ile belirsiz alanların birlikte var olduğunu gösteriyor.';

    final String nextStep = safetyEscalated
        ? 'Teması yavaşlat, ekstra doğrulama yap ve kendini rahat hissetmiyorsan geri çekilmeyi normalize et.'
        : draft.followUpOffer == 'Evet'
        ? 'İkinci görüşmeye açık kal, ama netlik üretmeyen alanları özellikle test et.'
        : 'Şimdilik kesin yatırım yapmadan veri toplamaya devam et veya geri çekilmeyi değerlendir.';

    final SafetyAssessment safetyAssessment = safetyEscalated
        ? const SafetyAssessment(
            escalated: true,
            headline: 'Öncelik güvenlik ve sınır netliği',
            summary:
                'Bu raporda romantik uygunluk yorumundan önce rahatlık, baskı ve sınır işaretleri ciddiye alınmalı.',
            actions: <String>[
              'Teması yavaşlat',
              'Bir sonraki adımı acele verme',
              'Gerekirse dış destek al',
            ],
          )
        : const SafetyAssessment(
            escalated: false,
            headline: 'Standart değerlendirme',
            summary:
                'Bu session için normal insight akışı yeterli; güvenlik katmanı baskın tetiklenmedi.',
            actions: <String>[
              'Somut davranışlara bak',
              'Niyet ve tempo sorularını açık tut',
            ],
          );

    memoryUpdates.add('schema=insight_report_v1');
    memoryUpdates.add('top_values=${profile.values.join(', ')}');

    return InsightReport(
      schemaVersion: 'insight_report_v1',
      sessionId: sessionId,
      summary: summary,
      positiveSignals: positiveSignals,
      cautionSignals: cautionSignals,
      uncertaintyFlags: uncertaintyFlags,
      missingDataPoints: missingDataPoints,
      recommendedQuestions: recommendedQuestions,
      nextStep: nextStep,
      safetyAssessment: safetyAssessment,
      memoryUpdates: memoryUpdates,
    );
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final String keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}
