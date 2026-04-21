import 'models.dart';

class MockAnalysisEngine {
  static InsightReport build({
    required ReflectionDraft draft,
    required OnboardingProfile profile,
    required String sessionId,
  }) {
    final String combined =
        '${draft.dateContext} ${draft.sensoryObservations} ${draft.specificDialogs} ${draft.valueTests} ${draft.emotionalReactions} ${draft.clarificationAnswers.join(' ')}'
            .toLowerCase();

    final bool safetyEscalated =
        draft.physicalBoundaryIssue ||
        _containsAny(combined, const <String>[
          'korktum',
          'tehdit',
          'takip',
          'israr',
          'baski',
          'baskı',
          'sinir',
          'sınır',
          'rahatsiz oldum',
          'rahatsız oldum',
          'güvensiz',
          'guvensiz',
          'manipüle',
          'manipule',
        ]);

    final List<InsightSignal> positiveSignals = <InsightSignal>[];
    final List<InsightSignal> cautionSignals = <InsightSignal>[];
    final List<String> uncertaintyFlags = <String>[];
    final List<String> missingDataPoints = <String>[];
    final List<String> recommendedQuestions = <String>[];
    final List<String> memoryUpdates = <String>[];
    final List<ClarityDimension> dimensions = <ClarityDimension>[];
    final Map<String, int> evidenceMix = <String, int>{
      'Somut olay': 0,
      'Yapılandırılmış cevap': 0,
      'Yorum': 0,
      'Eksik veri': 0,
    };

    final List<String> nlpBiasFlags = <String>[];
    final List<String> consistencyFlags = <String>[];

    // ── Simulate World Embedding & Deep Character Analysis ──
    if (profile.blindSpots.contains('Çok hızlı eleme ve vazgeçme') &&
        _containsAny(draft.emotionalReactions.toLowerCase(), const <String>['sıkıldım', 'bunaldım', 'soğudum'])) {
      nlpBiasFlags.add('Internal/External Attribution Bias: Karşındakinin hatasından çok kendi kaçınma refleksin devrede olabilir.');
    }

    if (draft.sensoryObservations.toLowerCase().contains('nazik') &&
        (draft.specificDialogs.toLowerCase().contains('sert') || draft.emotionalReactions.toLowerCase().contains('gergin'))) {
      consistencyFlags.add('Tutarlılık Kontrolü (Evidence Source): "Nazik" vücut dili raporladın ama diyalog veya histe "sert/gergin" bir taraf var. Bu çelişki tehlikeli olabilir.');
    }

    // ── Personalized Guidance (Dynamic System Prompt) ──
    String uniqueDir = 'Bu eşleşmede temel sınırların aşıldığına dair net bir sapma görülmedi.';
    if (profile.values.isNotEmpty) {
      final String coreValue = profile.values.first;
      if (!combined.contains(coreValue.toLowerCase().substring(0, (coreValue.length > 4 ? 4 : coreValue.length)))) {
        uniqueDir = "Senin profilinde '$coreValue' en yüksek değerin. Ancak bu date'in diyalog ve değer testlerinde bu değerinle uyumlu olunduğuna dair hiçbir veri yok. Heyecanın bunu göz ardı etmene neden de olsa, verilerimiz bunun senin için bir 'Kırmızı Çizgi' (Dealbreaker) olduğunu hatırlatıyor.";
      } else {
        uniqueDir = "Senin profilindeki '$coreValue' değeriyle rezonans var. Vektörel karar uzayına göre bu çok nadir ve güçlü bir eşleşme sinyali.";
      }
    }

    final String tone = profile.coreTraits.contains('Analitik') ? 'analitik ve doğrudan' : 'empatik ve destekleyici';
    final String antiCliche = 'Herkes için "zaman ver" iyi bir tavsiye olabilir ama senin vizyonunda, $tone bir dille söylüyorum: Bu belirsizlik senin temponla (${profile.pacingPreference.label}) çelişiyor.';

    final PersonalizedGuidance personalizedGuidance = PersonalizedGuidance(
      uniqueDirection: uniqueDir,
      antiClicheLanguage: antiCliche,
    );

    // ── Positive signal: mutual curiosity ──
    if (_containsAny(combined, const <String>[
      'dinledi',
      'merak',
      'soru sordu',
      'ilgiliydi',
      'nazik',
      'ilgi',
      'dikkat',
    ])) {
      evidenceMix.update('Somut olay', (int v) => v + 1);
      positiveSignals.add(
        InsightSignal(
          id: 'positive-curiosity',
          title: 'Karşılıklı merak sinyali',
          explanation:
              'Anlatımında ilgi veya dinleme işaretleri var — ama dikkat: "ilgiliydi" senin yorumun, somut davranış değil. Gerçekten sana sorular mı sordu, yoksa kibar mıydı sadece?',
          signalType: 'curiosity',
          confidenceLabel: ConfidenceLabel.medium,
          evidenceItems: <EvidenceItem>[
            EvidenceItem(source: 'user_reported_fact', text: '${draft.sensoryObservations} ${draft.emotionalReactions}'),
          ],
        ),
      );
    }

    // ── Follow-up intent ──
    if (draft.followUpOffer == 'Evet' || draft.futurePlanSignal == 'Var') {
      evidenceMix.update('Yapılandırılmış cevap', (int v) => v + 1);
      positiveSignals.add(
        InsightSignal(
          id: 'positive-follow-up',
          title: 'Devam etme niyeti işareti',
          explanation:
              'Takip teklifi veya plan sinyali var — ama "tekrar görüşelim" demek gerçek niyet değil, sosyal nezaket de olabilir. Somut bir tarih veya plan detayı var mı? Yoksa kibarlık ile niyeti karıştırıyor olabilirsin.',
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

    // ── Ambiguity caution ──
    if (draft.comfortLevel == 'Dusuk' || draft.clarityLevel == 'Belirsiz') {
      evidenceMix.update('Yapılandırılmış cevap', (int v) => v + 1);
      cautionSignals.add(
        InsightSignal(
          id: 'caution-ambiguity',
          title: 'Belirsizlik yüksek — ve bu normal değil',
          explanation:
              'Konfor veya netlik düşük. Kendine dürüst ol: "belirsiz hissediyorum" diyorsan ama devam etmek istiyorsan, bu belirsizliğe rağmen devam etme dürtüsü nereden geliyor? Yalnızlıktan mı, gerçek ilgiden mi?',
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
        'İlgi gösteren biri seni istiyor demek değildir. İlgi ile niyet arasındaki farkı henüz test etmedin.',
      );
    }

    // ── Low momentum ──
    if (draft.followUpOffer == 'Hayir' && draft.futurePlanSignal == 'Yok') {
      evidenceMix.update('Yapılandırılmış cevap', (int v) => v + 1);
      cautionSignals.add(
        const InsightSignal(
          id: 'caution-low-momentum',
          title: 'Takip momentumu yok — bunu kabul et',
          explanation:
              'Ne takip teklifi ne de gelecek planı var. Bu net bir sinyal: ilgi düşük veya yok. Bunu "utangaç" veya "yoğun" diye yorumlamak yerine, veriyi olduğu gibi oku.',
          signalType: 'momentum',
          confidenceLabel: ConfidenceLabel.high,
          evidenceItems: <EvidenceItem>[
            EvidenceItem(
              source: 'structured_response',
              text: 'follow_up_offer=Hayır, future_plan_signal=Yok',
            ),
          ],
        ),
      );
    }

    // ══════════════════════════════════════════════
    //  Profile-personalized signals
    // ══════════════════════════════════════════════

    // Idealization warning (profile-based)
    if (profile.highIdealization &&
        _containsAny(combined, const <String>[
          'harika',
          'mükemmel',
          'muhteşem',
          'ruh ikizi',
          'hic boyle hissetmedim',
          'hiç böyle hissetmedim',
          'ilk defa',
          'kusursuz',
        ])) {
      cautionSignals.add(
        InsightSignal(
          id: 'caution-idealization-profile',
          title: 'İdealizasyon devrede — kendini kandırıyor olabilirsin',
          explanation:
              'Profildeki inanç testinde idealizasyon eğilimin zaten yüksek çıkmıştı. Şimdi "harika/mükemmel" diyorsun. Bu bir veri değil, bir his. İlk buluşmadan sonra kimse "mükemmel" olamaz — tanımadığın birini idealize ediyorsun.',
          signalType: 'idealization',
          confidenceLabel: ConfidenceLabel.pattern,
          evidenceItems: <EvidenceItem>[
            EvidenceItem(
              source: 'profile_cross_ref',
              text:
                  'İdealizasyon skoru: ${(profile.idealizationScore * 100).toStringAsFixed(0)}%',
            ),
          ],
        ),
      );
      recommendedQuestions.add(
        'Dur ve düşün: bu kişinin sana uygun olmadığını gösteren TEK BİR ŞEY bile gördün mü? Görmediysen, gözlerin kapalı olabilir.',
      );
    }

    // Fast attachment warning (blind spot based)
    if (profile.hasFastAttachment &&
        _containsAny(combined, const <String>[
          'çok hızlı',
          'cok hizli',
          'bağlandım',
          'baglandim',
          'duramıyorum',
          'düşünemiyorum',
          'hep aklımda',
        ])) {
      cautionSignals.add(
        const InsightSignal(
          id: 'caution-fast-attachment',
          title: 'Erken bağlanma — bildiğin kör noktan tekrarlıyor',
          explanation:
              'Bunu zaten biliyorsun: profilde "çok erken bağlanıyorum" dedin. Şimdi tam da bunu yapıyorsun. Farkında olmak yetmiyor — farkında olup yine aynı şeyi yapmak örüntünün gücünü gösteriyor.',
          signalType: 'attachment_speed',
          confidenceLabel: ConfidenceLabel.pattern,
          evidenceItems: <EvidenceItem>[
            EvidenceItem(
              source: 'profile_blind_spot',
              text: 'Kullanıcı kör noktası: çok erken bağlanma',
            ),
          ],
        ),
      );
    }

    // High assurance need — ambiguity amplifier
    if (profile.highAssurance && draft.clarityLevel != 'Net') {
      cautionSignals.add(
        const InsightSignal(
          id: 'caution-assurance-gap',
          title: 'Güvence açığı — anksiyete döngüsü riski',
          explanation:
              'Güvence ihtiyacın yüksek ve bu oturumda netlik yok. Bu kombinasyon tehlikeli: belirsizliği kapatmak için karşı tarafı zorlayabilir, mesaj kontrol edebilir veya "test" davranışları başlatabilirsin. Bunu yapmadan önce dur.',
          signalType: 'assurance_gap',
          confidenceLabel: ConfidenceLabel.medium,
          evidenceItems: <EvidenceItem>[
            EvidenceItem(
              source: 'profile_cross_ref',
              text: 'Güvence: yüksek, netlik: düşük/belirsiz',
            ),
          ],
        ),
      );
      recommendedQuestions.add(
        'Kendine sor: güvence ihtiyacını karşılamak karşı tarafın işi mi, yoksa senin iç güvenliğinin eksikliği mi?',
      );
    }

    // Pacing mismatch
    if (profile.pacingPreference == PacingPreference.slow &&
        _containsAny(combined, const <String>[
          'çok hızlı ilerliyor',
          'hızlı gidiyor',
          'hizli gidiyor',
          'acele',
          'nefes alamıyorum',
        ])) {
      cautionSignals.add(
        const InsightSignal(
          id: 'caution-pacing-mismatch',
          title: 'Tempo uyumsuzluğu — sınır koyabiliyor musun?',
          explanation:
              'Tempon yavaş ama karşı taraf hızlı gidiyor ve sen rahatsızsın. Soru şu: rahatsızlığını ifade edebiliyor musun, yoksa "kaçırırım" korkusuyla sessiz mi kalıyorsun? Sessiz kalmak onay vermektir.',
          signalType: 'pacing',
          confidenceLabel: ConfidenceLabel.medium,
          evidenceItems: <EvidenceItem>[
            EvidenceItem(
              source: 'profile_cross_ref',
              text: 'Profil tercihi: yavaş tempo',
            ),
          ],
        ),
      );
    }

    // ── Safety escalation ──
    if (safetyEscalated) {
      evidenceMix.update('Somut olay', (int v) => v + 1);
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
            EvidenceItem(source: 'user_reported_fact', text: '${draft.sensoryObservations} ${draft.emotionalReactions}'),
          ],
        ),
      );
      recommendedQuestions.insert(
        0,
        'Bu kişiyle teması yavaşlatmak sana daha güvenli hissettirir mi?',
      );
      memoryUpdates.add('Safety escalation kaydı oluştur.');
    }

    // ── Value alignment check ──
    final List<String> lowerValues = profile.values
        .map((String v) => v.toLowerCase())
        .toList(growable: false);
    if (!_containsAny(combined, lowerValues)) {
      evidenceMix.update('Eksik veri', (int v) => v + 1);
      missingDataPoints.add(
        'Senin temel değerlerin bu kişide henüz test edilmedi. "İyi hissettim" bir değer uyumu değil.',
      );
      recommendedQuestions.add(
        'Senin için en önemli değer bu kişide somut olarak nasıl görünüyor? Görmüyorsan, görmek istemiyor olabilirsin.',
      );
    }

    if (draft.futurePlanSignal == 'Belirsiz') {
      evidenceMix.update('Eksik veri', (int v) => v + 1);
      missingDataPoints.add(
        'İlişki niyeti belirsiz. "Niyetini bilmiyorum ama devam ediyorum" en riskli pozisyon.',
      );
    }

    // ── Fallback positive ──
    if (positiveSignals.isEmpty) {
      evidenceMix.update('Eksik veri', (int v) => v + 1);
      positiveSignals.add(
        const InsightSignal(
          id: 'positive-restraint',
          title: 'Henüz olumlu sinyal yok — ve bu sorun değil',
          explanation:
              'Anlatımında somut olumlu veri yok. Bu kötü bir şey değil — ama "bir şey hissetmedim" ile "fark etmedim" arasında fark var. Hangisi senin durumun?',
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

    // ── Profile-personalized recommended questions ──
    if (profile.highIdealization && recommendedQuestions.length < 4) {
      recommendedQuestions.add(
        'Bu kişinin KUSURU ne? Bir tane bile bulamıyorsan, onu değil kendi fantezini görüyorsun demektir.',
      );
    }
    if (profile.isFirstRelationship && recommendedQuestions.length < 4) {
      recommendedQuestions.add(
        'İlk deneyimin — karşılaştırma noktanız yok. Bu seni daha savunmasız yapıyor. Bunu bilerek hareket et.',
      );
    }

    if (recommendedQuestions.isEmpty) {
      recommendedQuestions.add(
        'Bir sonraki görüşmede "niyetin ne?" sorusunu sormaktan korkuyor musun? Korkuyorsan, neden?',
      );
    }

    // ── Dimensions (enriched with profile data) ──
    dimensions.addAll(<ClarityDimension>[
      ClarityDimension(
        title: 'Saygı',
        state: safetyEscalated
            ? DimensionState.caution
            : DimensionState.supported,
        note: safetyEscalated
            ? 'Sınır veya baskı sinyalleri var. Saygısızlığı "ilgi" olarak yorumlama.'
            : 'Açık saygısızlık verisi yok — ama tek buluşma bunu ölçmek için az.',
      ),
      ClarityDimension(
        title: 'Karşılıklık',
        state: draft.followUpOffer == 'Evet'
            ? DimensionState.supported
            : draft.followUpOffer == 'Hayir'
                ? DimensionState.caution
                : DimensionState.mixed,
        note: draft.followUpOffer == 'Hayir'
            ? 'Takip teklifi yok. Bunu "utangaç" diye yorumlamak bir savunma mekanizması.'
            : 'Takip sinyali var ama sözle eylem arasındaki farkı izle.',
      ),
      ClarityDimension(
        title: 'Duygusal güvenlik',
        state: draft.comfortLevel == 'Dusuk'
            ? DimensionState.caution
            : draft.comfortLevel == 'Orta'
                ? DimensionState.mixed
                : DimensionState.supported,
        note: draft.comfortLevel == 'Dusuk'
            ? 'Rahat hissetmedin. Bu vücudunun sana bir şey söylemeye çalışması — dinle.'
            : 'Konfor alanı stabil görünüyor.',
      ),
      ClarityDimension(
        title: 'Merak',
        state: _containsAny(combined, const <String>[
              'soru sordu',
              'merak',
              'dinledi',
              'ilgili',
            ])
            ? DimensionState.supported
            : DimensionState.unclear,
        note: _containsAny(combined, const <String>['soru sordu', 'merak', 'dinledi', 'ilgili'])
            ? 'İlgi sinyalleri var — ama "ilgiliydi" senin yorumun. Somut soru sordu mu?'
            : 'Karşı tarafın sana merak gösterdiğine dair somut veri yok.',
      ),
      ClarityDimension(
        title: 'Tutarlılık',
        state: draft.clarityLevel == 'Net'
            ? DimensionState.supported
            : draft.clarityLevel == 'Belirsiz'
                ? DimensionState.mixed
                : DimensionState.caution,
        note: draft.clarityLevel != 'Net'
            ? 'Anlatınla form cevapların arasında tutarsızlık olabilir. Kendine ne kadar dürüstsün?'
            : 'Form ve anlatı birbirini destekliyor.',
      ),
      ClarityDimension(
        title: 'Tempo uyumu',
        state: draft.futurePlanSignal == 'Var'
            ? DimensionState.supported
            : profile.pacingPreference == PacingPreference.slow
                ? DimensionState.mixed
                : DimensionState.unclear,
        note:
            'Senin tempo tercihin (${profile.pacingPreference.label}) ve karşı tarafın ileri sinyalleri birlikte okunuyor.',
      ),
      ClarityDimension(
        title: 'Niyet uyumu',
        state: draft.futurePlanSignal == 'Var'
            ? DimensionState.supported
            : draft.futurePlanSignal == 'Belirsiz'
                ? DimensionState.unclear
                : DimensionState.caution,
        note: 'Geleceğe dönük işaretlerin düzeyi.',
      ),
      ClarityDimension(
        title: 'Belirsizlik',
        state: missingDataPoints.length >= 2
            ? DimensionState.caution
            : missingDataPoints.isNotEmpty
                ? DimensionState.mixed
                : DimensionState.supported,
        note: 'Karar öncesi hâlâ test edilmesi gereken alanlar.',
      ),
    ]);

    // ── Summary (personalized tone) ──
    final String profileNote = profile.highIdealization
        ? ' Uyarı: idealizasyon eğilimin yüksek — "harika gitti" hissi seni yanıltıyor olabilir.'
        : '';

    final String summary = safetyEscalated
        ? 'Bu oturumda güvenlik sinyalleri var. Romantik uyum şu an önemsiz — önce kendini koru.'
        : cautionSignals.isEmpty
            ? 'Şu an ciddi uyarı yok ama bu "iyi gidiyor" demek değil. Henüz yeterli verin yok, erken heyecanlanma.$profileNote'
            : 'Bu raporda uyarı sinyalleri var. Bunları görmezden gelme dürtüsü hissediyorsan, tam da o yüzden ciddi al.$profileNote';

    final String nextStep = safetyEscalated
        ? 'Teması durdur veya yavaşlat. "Bir şans daha vereyim" dürtüsüne karşı dikkatli ol — baskı hissettiysen bu yeterli veri.'
        : draft.followUpOffer == 'Evet'
            ? 'Devam edeceksen, bir sonraki görüşmede belirsiz alanları test et. "Bakarız" diyerek geçiştirme.'
            : 'Momentum yoksa zorlamayı bırak. Karşı tarafın ilgisizliğini "zamanlama" ile açıklamak kendini kandırmaktır.';

    final SafetyAssessment safetyAssessment = safetyEscalated
        ? const SafetyAssessment(
            escalated: true,
            headline: 'Güvenlik alarmı — romantik uyum şu an önemsiz',
            summary:
                'Baskı, korku veya sınır ihlali hissettiysen bu yeterli veri. "Belki abarttım" diye küçümseme — içgüdülerine güven. Bu kişiyle devam etmek şu an doğru karar değil.',
            actions: <String>[
              'Teması durdur veya ciddi şekilde yavaşlat',
              'Güvendiğin birine anlat — yalnız karar verme',
              '"Bir şans daha" dürtüsünü sorgula',
            ],
          )
        : const SafetyAssessment(
            escalated: false,
            headline: 'Standart değerlendirme',
            summary:
                'Güvenlik alarmı yok ama bu "güvenli" demek değil — sadece henüz sinyal tetiklenmedi.',
            actions: <String>[
              'Hislere değil somut davranışlara bak',
              'Niyet sorusunu sormaktan kaçınma',
            ],
          );

    memoryUpdates.add('schema=insight_report_v2');
    memoryUpdates.add('goal=${profile.goal.label}');
    memoryUpdates.add('pacing=${profile.pacingPreference.label}');
    memoryUpdates.add('idealization_score=${(profile.idealizationScore * 100).toStringAsFixed(0)}%');
    memoryUpdates.add('assurance_need=${profile.assuranceNeed.label}');
    memoryUpdates.add('top_values=${profile.values.join(', ')}');
    memoryUpdates.add('blind_spots=${profile.blindSpots.join(', ')}');

    return InsightReport(
      schemaVersion: 'insight_report_v2',
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
      dimensions: dimensions,
      evidenceMix: evidenceMix,
      personalizedGuidance: personalizedGuidance,
      nlpBiasFlags: nlpBiasFlags,
      consistencyFlags: consistencyFlags,
    );
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final String keyword in keywords) {
      if (text.contains(keyword)) return true;
    }
    return false;
  }
}
