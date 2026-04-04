// ──────────────────────────────────────────────
// Enums
// ──────────────────────────────────────────────

enum RelationshipGoal {
  serious('Ciddi ilişki'),
  openExplore('Potansiyeli açık tanışma'),
  slowBond('Yavaş ilerleyen bağ'),
  shortTerm('Kısa dönem deneyim'),
  unsure('Emin değilim');

  const RelationshipGoal(this.label);
  final String label;
}

enum PacingPreference {
  slow('Yavaş'),
  balanced('Dengeli'),
  fastButClear('Hızlı ama net');

  const PacingPreference(this.label);
  final String label;
}

enum RelationshipExperience {
  first('İlk ciddi deneyim'),
  few('Az deneyim'),
  several('Birkaç ilişki'),
  extensive('Uzun ilişki geçmişi');

  const RelationshipExperience(this.label);
  final String label;
}

enum CommunicationPreference {
  frequentContact('Sık temas'),
  balancedRegular('Düzenli ama dengeli'),
  spaceGiving('Alan tanıyan'),
  deepConversation('Derin konuşma'),
  lightFun('Hafif ve eğlenceli');

  const CommunicationPreference(this.label);
  final String label;
}

enum AmbiguityResponse {
  wait('Beklerim'),
  ask('Sorarım'),
  withdraw('Geri çekilirim'),
  overthink('Fazla düşünürüm'),
  testInterest('İlgiyi test ederim');

  const AmbiguityResponse(this.label);
  final String label;
}

enum ConflictStyle {
  talkItOut('Konuşup çözmek'),
  coolDownFirst('Önce sakinleşmek'),
  shutDown('İçine kapanmak'),
  distance('Mesafe koymak'),
  overEngage('Fazla yoğunlaşmak');

  const ConflictStyle(this.label);
  final String label;
}

enum AssuranceNeed {
  low('Düşük'),
  medium('Orta'),
  high('Yüksek');

  const AssuranceNeed(this.label);
  final String label;
}

enum FatigueResponse {
  seekCloseness('Yakınlaşırım'),
  pullAway('Uzaklaşırım'),
  test('Test ederim'),
  goSilent('Susarım'),
  overAnalyze('Fazla analiz ederim');

  const FatigueResponse(this.label);
  final String label;
}

// ──────────────────────────────────────────────
// Daily Engagement Enums
// ──────────────────────────────────────────────

enum MoodLevel {
  great('Harika'),
  good('İyi'),
  neutral('Nötr'),
  low('Düşük'),
  bad('Kötü');

  const MoodLevel(this.label);
  final String label;

  double get numericValue => switch (this) {
    MoodLevel.great => 1.0,
    MoodLevel.good => 0.75,
    MoodLevel.neutral => 0.5,
    MoodLevel.low => 0.25,
    MoodLevel.bad => 0.0,
  };
}

enum EmotionalTrigger {
  romanticThought('Romantik düşünce'),
  loneliness('Yalnızlık hissi'),
  rejection('Ret/reddetme'),
  excitement('Heyecan'),
  anxiety('Kaygı'),
  jealousy('Kıskançlık'),
  hope('Umut'),
  disappointment('Hayal kırıklığı'),
  peace('Huzur'),
  confusion('Kafa karışıklığı'),
  none('Belirgin tetikleyici yok');

  const EmotionalTrigger(this.label);
  final String label;
}

enum InteractionType {
  texting('Mesajlaşma'),
  call('Telefon / sesli arama'),
  date('Buluşma'),
  socialMedia('Sosyal medya etkileşimi'),
  thinkingOf('Aklıma geldi'),
  bumped('Tesadüfen karşılaştım'),
  introduced('Tanıştırıldım'),
  matchApp('Uygulama eşleşmesi'),
  friendMention('Arkadaş bahsetti');

  const InteractionType(this.label);
  final String label;
}

enum InteractionEnergy {
  positive('Olumlu'),
  neutral('Nötr'),
  draining('Yorucu'),
  confusing('Kafa karıştırıcı'),
  exciting('Heyecan verici');

  const InteractionEnergy(this.label);
  final String label;
}

enum EnergyLevel {
  high('Yüksek'),
  medium('Orta'),
  low('Düşük');

  const EnergyLevel(this.label);
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

enum CheckInOutcome {
  positive('Olumlu ilerledi'),
  stillTalking('Konuşma devam ediyor'),
  userSteppedBack('Kullanıcı vazgeçti'),
  inconsistent('Karşı taraf tutarsız davrandı'),
  distanced('Karşı taraf uzaklaştı'),
  observing('Veri hâlâ yetersiz');

  const CheckInOutcome(this.label);
  final String label;

  bool get keepsFutureCheckIns =>
      this == CheckInOutcome.stillTalking || this == CheckInOutcome.observing;
}

enum DimensionState {
  supported('Destekleniyor'),
  mixed('Karışık'),
  unclear('Belirsiz'),
  caution('Dikkat');

  const DimensionState(this.label);
  final String label;
}

// ──────────────────────────────────────────────
// Onboarding Profile — Romantik Karar Profili
// ──────────────────────────────────────────────

class OnboardingProfile {
  const OnboardingProfile({
    // Section 1: Kendini anlat
    required this.displayName,
    required this.selfDescription,
    required this.coreTraits,
    required this.currentLifeTheme,
    required this.datingChallenge,
    required this.freeformAboutMe,

    // Section 2: İlişki niyeti ve zamanlama
    required this.goal,
    required this.pacingPreference,
    required this.openingUpTime,
    required this.trustBuilder,
    required this.relationshipExperience,
    required this.recentDatingChallenge,

    // Section 3: Değerler ve vazgeçilmezler
    required this.values,
    required this.respectSignal,
    required this.dealbreakers,
    required this.lifestyleFactors,
    required this.potentialVsBehavior,

    // Section 4: İletişim ve yakınlık stili
    required this.communicationPreference,
    required this.showsInterestHow,
    required this.directVsSoft,
    required this.messagingImportance,
    required this.ambiguityResponse,
    required this.conflictStyle,

    // Section 5: Kör noktalar ve pattern'ler
    required this.blindSpots,
    required this.recurringPattern,
    required this.feedbackFromCloseOnes,
    required this.biggestMisjudgment,
    required this.judgmentCloudedBy,

    // Section 6: Aşka dair inançlar (1-7 scale)
    required this.beliefRightPersonFindsWay,
    required this.beliefChemistryFeltFast,
    required this.beliefStrongAttractionIsSign,
    required this.beliefFeelsRightOrNot,
    required this.beliefFirstFeelingsAreTruth,
    required this.beliefPotentialEqualsValue,
    required this.beliefAmbiguityIsNormal,
    required this.beliefLoveOvercomesIssues,

    // Section 7: Güvenlik, sınır ve kırılganlıklar
    required this.alarmTriggers,
    required this.vulnerabilityArea,
    required this.assuranceNeed,
    required this.jealousyLevel,
    required this.fatigueResponse,
    required this.boundaryDifficulty,

    // Section 8: Açık alan ve doğrulama
    required this.attachmentHistory,
    required this.misunderstandingRisk,
    required this.partnerShouldKnowEarly,
    required this.freeformForProfile,
    required this.profileSummaryFeedback,

    // Conditional follow-ups (nullable)
    this.highAssuranceThought,
    this.idealizationAwareness,
    this.firstRelationshipLearning,
    this.noSecondChanceBehavior,
    this.fastAttachmentDriver,
    this.fastEliminationReason,

    // Legal
    required this.ageConfirmed,
    required this.policyAccepted,
  });

  // Section 1
  final String displayName;
  final String selfDescription;
  final List<String> coreTraits;
  final String currentLifeTheme;
  final String datingChallenge;
  final String freeformAboutMe;

  // Section 2
  final RelationshipGoal goal;
  final PacingPreference pacingPreference;
  final String openingUpTime;
  final String trustBuilder;
  final RelationshipExperience relationshipExperience;
  final String recentDatingChallenge;

  // Section 3
  final List<String> values;
  final String respectSignal;
  final List<String> dealbreakers;
  final List<String> lifestyleFactors;
  final String potentialVsBehavior;

  // Section 4
  final CommunicationPreference communicationPreference;
  final String showsInterestHow;
  final String directVsSoft;
  final String messagingImportance;
  final AmbiguityResponse ambiguityResponse;
  final ConflictStyle conflictStyle;

  // Section 5
  final List<String> blindSpots;
  final String recurringPattern;
  final String feedbackFromCloseOnes;
  final String biggestMisjudgment;
  final String judgmentCloudedBy;

  // Section 6 — Romantik İnanç Skalası (1-7)
  final int beliefRightPersonFindsWay;
  final int beliefChemistryFeltFast;
  final int beliefStrongAttractionIsSign;
  final int beliefFeelsRightOrNot;
  final int beliefFirstFeelingsAreTruth;
  final int beliefPotentialEqualsValue;
  final int beliefAmbiguityIsNormal;
  final int beliefLoveOvercomesIssues;

  // Section 7
  final List<String> alarmTriggers;
  final String vulnerabilityArea;
  final AssuranceNeed assuranceNeed;
  final String jealousyLevel;
  final FatigueResponse fatigueResponse;
  final String boundaryDifficulty;

  // Section 8
  final String attachmentHistory;
  final String misunderstandingRisk;
  final String partnerShouldKnowEarly;
  final String freeformForProfile;
  final String profileSummaryFeedback;

  // Conditional follow-ups
  final String? highAssuranceThought;
  final String? idealizationAwareness;
  final String? firstRelationshipLearning;
  final String? noSecondChanceBehavior;
  final String? fastAttachmentDriver;
  final String? fastEliminationReason;

  // Legal
  final bool ageConfirmed;
  final bool policyAccepted;

  // ══════════════════════════════════════════════
  //  Computed Profile Scores
  // ══════════════════════════════════════════════

  double get idealizationScore {
    return (beliefRightPersonFindsWay +
            beliefChemistryFeltFast +
            beliefStrongAttractionIsSign +
            beliefFeelsRightOrNot +
            beliefFirstFeelingsAreTruth +
            beliefPotentialEqualsValue) /
        42.0;
  }

  double get romanticRealismScore => 1.0 - idealizationScore;

  double get ambiguityTolerance => beliefAmbiguityIsNormal / 7.0;

  double get emotionalDependencyRisk {
    double risk = 0;
    if (assuranceNeed == AssuranceNeed.high) risk += 0.3;
    if (fatigueResponse == FatigueResponse.seekCloseness) risk += 0.15;
    if (fatigueResponse == FatigueResponse.test) risk += 0.2;
    if (blindSpots.contains('Çok erken bağlanma')) risk += 0.2;
    if (blindSpots.contains('Kendi ihtiyacını geri plana atma')) risk += 0.15;
    if (vulnerabilityArea == 'Terk edilme') risk += 0.15;
    return risk.clamp(0.0, 1.0);
  }

  double get selfProtectionScore {
    double score = 0;
    if (blindSpots.contains('Fazla hızlı eleme')) score += 0.25;
    if (conflictStyle == ConflictStyle.distance) score += 0.2;
    if (conflictStyle == ConflictStyle.shutDown) score += 0.2;
    if (fatigueResponse == FatigueResponse.pullAway) score += 0.15;
    if (ambiguityResponse == AmbiguityResponse.withdraw) score += 0.15;
    if (alarmTriggers.length >= 5) score += 0.15;
    return score.clamp(0.0, 1.0);
  }

  double get boundaryHealthScore {
    double score = 0.5;
    if (boundaryDifficulty.trim().isNotEmpty) score -= 0.2;
    if (alarmTriggers.isNotEmpty) score += 0.1;
    if (dealbreakers.length >= 3) score += 0.15;
    if (blindSpots.contains('Kendi ihtiyacını geri plana atma')) score -= 0.2;
    if (blindSpots.contains('Red flag\'i rasyonalize etme')) score -= 0.15;
    return score.clamp(0.0, 1.0);
  }

  /// Communication-action alignment: how consistent words vs behavior are
  double get communicationAlignmentScore {
    double score = 0.7; // assume decent
    if (directVsSoft == 'Doğrudan' &&
        (conflictStyle == ConflictStyle.shutDown ||
            conflictStyle == ConflictStyle.distance)) {
      score -= 0.3;
    }
    if (communicationPreference == CommunicationPreference.deepConversation &&
        conflictStyle == ConflictStyle.shutDown) {
      score -= 0.2;
    }
    if (ambiguityResponse == AmbiguityResponse.ask &&
        conflictStyle == ConflictStyle.talkItOut) {
      score += 0.15;
    }
    return score.clamp(0.0, 1.0);
  }

  /// Self-awareness score: how honestly they acknowledge patterns
  double get selfAwarenessScore {
    double score = 0.3;
    if (blindSpots.isNotEmpty) score += 0.15;
    if (blindSpots.length >= 2) score += 0.1;
    if (recurringPattern.trim().isNotEmpty) score += 0.15;
    if (feedbackFromCloseOnes.trim().isNotEmpty) score += 0.1;
    if (biggestMisjudgment.trim().isNotEmpty) score += 0.1;
    if (freeformForProfile.trim().isNotEmpty) score += 0.1;
    return score.clamp(0.0, 1.0);
  }

  /// Emotional regulation capacity
  double get emotionalRegulationScore {
    double score = 0.5;
    if (conflictStyle == ConflictStyle.talkItOut) score += 0.2;
    if (conflictStyle == ConflictStyle.coolDownFirst) score += 0.15;
    if (conflictStyle == ConflictStyle.overEngage) score -= 0.2;
    if (fatigueResponse == FatigueResponse.overAnalyze) score -= 0.15;
    if (fatigueResponse == FatigueResponse.test) score -= 0.2;
    if (ambiguityResponse == AmbiguityResponse.overthink) score -= 0.15;
    if (ambiguityResponse == AmbiguityResponse.ask) score += 0.15;
    return score.clamp(0.0, 1.0);
  }

  /// Relationship readiness composite
  double get relationshipReadiness {
    return ((boundaryHealthScore +
                emotionalRegulationScore +
                selfAwarenessScore +
                romanticRealismScore +
                communicationAlignmentScore) /
            5.0)
        .clamp(0.0, 1.0);
  }

  bool get highIdealization => idealizationScore > 0.65;
  bool get highAssurance => assuranceNeed == AssuranceNeed.high;
  bool get isFirstRelationship =>
      relationshipExperience == RelationshipExperience.first;
  bool hasBlindSpot(String spot) => blindSpots.contains(spot);
  bool get hasFastAttachment => blindSpots.contains('Çok erken bağlanma');
  bool get hasFastElimination => blindSpots.contains('Fazla hızlı eleme');
  bool get highBoundarySensitivity =>
      alarmTriggers.length >= 4 || boundaryDifficulty.trim().isNotEmpty;

  // ══════════════════════════════════════════════
  //  Inconsistency Detection
  // ══════════════════════════════════════════════

  List<ProfileInconsistency> detectInconsistencies() {
    final List<ProfileInconsistency> issues = <ProfileInconsistency>[];

    // 1. Says "bağımsız" but assurance need is high
    if (coreTraits.contains('Bağımsız') && highAssurance) {
      issues.add(const ProfileInconsistency(
        title: 'Bağımsızlık vs güvence ihtiyacı',
        explanation:
            'Kendini "bağımsız" olarak tanımlıyorsun ama güvence ihtiyacın yüksek. Bu iki şey aynı anda olabilir — ama genellikle biri diğerini maskeler. Hangisi daha gerçek?',
        severity: InconsistencySeverity.moderate,
      ));
    }

    // 2. Says slow pacing but has fast attachment blind spot
    if (pacingPreference == PacingPreference.slow && hasFastAttachment) {
      issues.add(const ProfileInconsistency(
        title: 'Yavaş tempo tercihi vs erken bağlanma eğilimi',
        explanation:
            'Yavaş ilerlemeyi tercih ettiğini söylüyorsun ama kör noktalarında "çok erken bağlanma" var. Bu, istediğin tempo ile gerçekte yaşadığın tempo arasında bir açık olduğunu gösteriyor.',
        severity: InconsistencySeverity.significant,
      ));
    }

    // 3. High idealization but says "bugünkü davranış" matters more
    if (highIdealization && potentialVsBehavior == 'Bugünkü davranışı') {
      issues.add(const ProfileInconsistency(
        title: 'İdealizasyon eğilimi vs davranış odaklı söylem',
        explanation:
            '"Bugünkü davranışı daha belirleyici" diyorsun ama inanç skalasında potansiyele, ilk hislere ve güçlü çekime yüksek değer veriyorsun. Bilinçli tercihin ile duygusal eğilimin çelişiyor.',
        severity: InconsistencySeverity.significant,
      ));
    }

    // 4. Says "temkinli" but ambiguity tolerance is high
    if (coreTraits.contains('Temkinli') && ambiguityTolerance > 0.7) {
      issues.add(const ProfileInconsistency(
        title: 'Temkinli profil vs belirsizlik toleransı',
        explanation:
            'Kendini temkinli biri olarak görüyorsun ama belirsizliğe toleransın yüksek. Temkinli insanlar genellikle belirsizlikten rahatsız olur. Bu tolerans gerçek mi, yoksa ilişkide pasif kalmayı normalleştiren bir kalkan mı?',
        severity: InconsistencySeverity.mild,
      ));
    }

    // 5. Direct communication but shuts down in conflict
    if (directVsSoft == 'Doğrudan' &&
        (conflictStyle == ConflictStyle.shutDown ||
            conflictStyle == ConflictStyle.distance)) {
      issues.add(const ProfileInconsistency(
        title: 'Doğrudan iletişim vs çatışmada kapanma',
        explanation:
            'İletişimde doğrudan olduğunu söylüyorsun ama tartışma anında içine kapanıyor veya mesafe koyuyorsun. Doğrudanlığın güvenli alanlarda mı geçerli? Gerçek test, zor anlarda nasıl iletişim kurduğun.',
        severity: InconsistencySeverity.moderate,
      ));
    }

    // 6. Says "duygusal" but fatigue response is pulling away
    if (coreTraits.contains('Duygusal') &&
        fatigueResponse == FatigueResponse.pullAway) {
      issues.add(const ProfileInconsistency(
        title: 'Duygusal profil vs yorulunca uzaklaşma',
        explanation:
            'Duygusal biri olarak tanımlıyorsun kendini ama yorulduğunda uzaklaşıyorsun. Bu, duyguları yaşamakla duyguları paylaşmak arasında bir fark olduğunu gösteriyor.',
        severity: InconsistencySeverity.mild,
      ));
    }

    // 7. Low jealousy claim but vulnerability is about being left
    if (jealousyLevel == 'Düşük' && vulnerabilityArea == 'Terk edilme') {
      issues.add(const ProfileInconsistency(
        title: 'Düşük kıskançlık vs terk edilme korkusu',
        explanation:
            'Kıskançlığın düşük olduğunu söylüyorsun ama en hassas alanın terk edilme. Terk edilme korkusu olan biri genellikle kıskançlığı bastırır, yokmuş gibi yapar. Bunu gerçekten düşük mü hissediyorsun, yoksa göstermemeyi mi tercih ediyorsun?',
        severity: InconsistencySeverity.significant,
      ));
    }

    // 8. Many alarm triggers but says boundary difficulty is empty
    if (alarmTriggers.length >= 5 && boundaryDifficulty.trim().isEmpty) {
      issues.add(const ProfileInconsistency(
        title: 'Çok alarm tetikleyici ama sınır zorluğu yok',
        explanation:
            'Birçok davranıştan alarm aldığını işaretledin ama sınır koymakta zorluk yaşamadığını söylüyorsun. Eğer sınır koymak kolay olsaydı, bu kadar çok alarmın olmazdı. Fark etmek ile harekete geçmek aynı şey değil.',
        severity: InconsistencySeverity.moderate,
      ));
    }

    // 9. "Sakin" trait but overthinks in ambiguity
    if (coreTraits.contains('Sakin') &&
        ambiguityResponse == AmbiguityResponse.overthink) {
      issues.add(const ProfileInconsistency(
        title: 'Sakin profil vs fazla düşünme eğilimi',
        explanation:
            'Kendini sakin olarak tanımlıyorsun ama belirsizlikte fazla düşünüyorsun. Dışarıya sakin görünmek ile içeride sakin olmak farklı şeyler.',
        severity: InconsistencySeverity.mild,
      ));
    }

    // 10. Rescuer pattern but claims high boundary sensitivity
    if (blindSpots.contains('Kurtarıcı rolüne girme') &&
        highBoundarySensitivity) {
      issues.add(const ProfileInconsistency(
        title: 'Kurtarıcı eğilimi vs sınır hassasiyeti',
        explanation:
            'Kurtarıcı rolüne girme eğilimin var ama sınır hassasiyetin de yüksek. Kurtarıcılar genellikle karşı tarafın sınırlarına hassas olur ama kendi sınırlarını feda eder. Hassasiyetin kime yönelik?',
        severity: InconsistencySeverity.moderate,
      ));
    }

    // 11. Deep conversation preference but goes silent when fatigued
    if (communicationPreference == CommunicationPreference.deepConversation &&
        fatigueResponse == FatigueResponse.goSilent) {
      issues.add(const ProfileInconsistency(
        title: 'Derin konuşma isteği vs suskunluk refleksi',
        explanation:
            'Derin konuşmalara değer veriyorsun ama yorulduğunda susuyorsun. Derinlik iki taraflı bir iş — sen sustukça karşı taraf seni yüzeysel sanabilir. Bu paradoksu fark ediyor musun?',
        severity: InconsistencySeverity.moderate,
      ));
    }

    // 12. Tests interest in ambiguity but claims to value trust
    if (ambiguityResponse == AmbiguityResponse.testInterest &&
        values.any((String v) => v.toLowerCase().contains('güven'))) {
      issues.add(const ProfileInconsistency(
        title: 'Güven değeri vs ilgi testi davranışı',
        explanation:
            'Güveni temel değer olarak belirtiyorsun ama belirsizlikte karşı tarafı test ediyorsun. Test etmek güvenin tersidir — güvensizliğin davranışa dönüşmüş hali. Bunu kabul etmek ilk adım.',
        severity: InconsistencySeverity.significant,
      ));
    }

    // 13. Frequent contact preference but space-giving communication
    if (communicationPreference == CommunicationPreference.frequentContact &&
        ambiguityResponse == AmbiguityResponse.withdraw) {
      issues.add(const ProfileInconsistency(
        title: 'Sık temas isteği vs geri çekilme davranışı',
        explanation:
            'Sık temas istiyorsun ama belirsizlikte geri çekiliyorsun. Yani istediğini elde edemeyince tam tersini yapıyorsun. Bu karşı tarafa karışık sinyaller gönderiyor.',
        severity: InconsistencySeverity.moderate,
      ));
    }

    // 14. Over-engage in conflict but claims to be "sakin" or "analitik"
    if (conflictStyle == ConflictStyle.overEngage &&
        (coreTraits.contains('Sakin') || coreTraits.contains('Analitik'))) {
      issues.add(const ProfileInconsistency(
        title: 'Sakin/analitik profil vs çatışmada aşırı yoğunlaşma',
        explanation:
            'Kendini sakin veya analitik görüyorsun ama çatışmada fazla yoğunlaşıyorsun. Bu, kontrol kaybettiğinde farklı bir kişi ortaya çıktığını gösterir. Stres altındaki halin gerçek halin.',
        severity: InconsistencySeverity.significant,
      ));
    }

    // 15. Says "potential doesn't matter" but high belief in love overcoming issues
    if (potentialVsBehavior == 'Bugünkü davranışı' &&
        beliefLoveOvercomesIssues >= 5) {
      issues.add(const ProfileInconsistency(
        title: 'Davranış odaklı söylem vs aşk her şeyi aşar inancı',
        explanation:
            '"Bugünkü davranış belirleyici" diyorsun ama "aşk sorunları aşar" inancın yüksek. Bu iki inanç birbiriyle çelişiyor — sorunlu davranış gördüğünde hangisini seçeceksin?',
        severity: InconsistencySeverity.significant,
      ));
    }

    // 16. Many dealbreakers but rationalizes red flags
    if (dealbreakers.length >= 4 &&
        blindSpots.contains('Red flag\'i rasyonalize etme')) {
      issues.add(const ProfileInconsistency(
        title: 'Çok sayıda dealbreaker vs red flag rasyonalizasyonu',
        explanation:
            'Teoride ${dealbreakers.length} vazgeçilmezin var ama pratikte red flag\'leri rasyonalize ediyorsun. Bu, sınırların kafanda net ama kalpte uygulanamaz olduğunu gösteriyor.',
        severity: InconsistencySeverity.significant,
      ));
    }

    // 17. Fast-but-clear pacing but ambiguity response is overthinking
    if (pacingPreference == PacingPreference.fastButClear &&
        ambiguityResponse == AmbiguityResponse.overthink) {
      issues.add(const ProfileInconsistency(
        title: 'Hızlı-ama-net tempo vs belirsizlikte fazla düşünme',
        explanation:
            'Hızlı ama net ilerlemek istiyorsun ama belirsizlikte fazla düşünüyorsun. Netlik arıyorsan, "bekleyip düşünmek" yerine "sormak" daha tutarlı olurdu. Düşünmek netlik getirmez, sormak getirir.',
        severity: InconsistencySeverity.mild,
      ));
    }

    // 18. Claims low jealousy but tests interest
    if (jealousyLevel == 'Düşük' &&
        ambiguityResponse == AmbiguityResponse.testInterest) {
      issues.add(const ProfileInconsistency(
        title: 'Düşük kıskançlık iddiası vs ilgi testi',
        explanation:
            'Kıskançlığın düşük diyorsun ama belirsizlikte ilgiyi test ediyorsun. İlgiyi test etmek kıskançlığın sofistike versiyonudur — açıkça kıskanmak yerine kontrol mekanizması kuruyorsun.',
        severity: InconsistencySeverity.moderate,
      ));
    }

    return issues;
  }

  // ══════════════════════════════════════════════
  //  Profile Highlights & Summary
  // ══════════════════════════════════════════════

  List<String> get profileHighlights {
    final List<String> items = <String>[];
    items.addAll(coreTraits.take(3));
    items.add(pacingPreference.label);
    items.add(goal.label);
    if (highIdealization) items.add('İdealizasyon eğilimi');
    if (highAssurance) items.add('Yüksek güvence ihtiyacı');
    if (emotionalDependencyRisk > 0.5) items.add('Duygusal bağımlılık riski');
    return items;
  }

  String generateProfileSummary() {
    final StringBuffer sb = StringBuffer();

    // Opening — honest, direct
    final String paceDesc = switch (pacingPreference) {
      PacingPreference.slow => 'yavaş açılan',
      PacingPreference.balanced => 'dengeli tempoda ilerleyen',
      PacingPreference.fastButClear => 'hızlı ama netlik arayan',
    };
    sb.write('$paceDesc');

    if (highIdealization) {
      sb.write(', idealizasyona eğilimli');
    } else if (romanticRealismScore > 0.65) {
      sb.write(', gerçekçi bakış açısına sahip');
    }

    if (highAssurance) {
      sb.write(', güvence ihtiyacı belirgin');
    }

    if (highBoundarySensitivity) {
      sb.write(', sınır bilinci yüksek');
    }

    if (ambiguityTolerance < 0.4) {
      sb.write(', belirsizliğe toleransı düşük');
    }

    final String commDesc = switch (communicationPreference) {
      CommunicationPreference.frequentContact => ', sık temas isteyen',
      CommunicationPreference.deepConversation =>
        ', derin konuşmalara değer veren',
      CommunicationPreference.spaceGiving => ', alan tanımayı önemseyen',
      _ => '',
    };
    sb.write(commDesc);

    sb.write(' bir profilsin.');

    // Honest observation
    if (emotionalDependencyRisk > 0.5) {
      sb.write(
          ' Duygusal bağımlılık riskin ortalamanın üstünde — bu seni kötü yapmaz ama farkındalık gerektirir.');
    }

    if (selfProtectionScore > 0.5) {
      sb.write(
          ' Kendini koruma refleksin güçlü — bu bazen gerçek yakınlığı da engelleyebilir.');
    }

    final List<ProfileInconsistency> issues = detectInconsistencies();
    if (issues.isNotEmpty) {
      sb.write(
          ' Profilinde ${issues.length} tutarsızlık tespit ettik — bu normal, ama farkında olmakta fayda var.');
    }

    if (blindSpots.isNotEmpty) {
      sb.write(
          ' En kritik kör noktan: ${blindSpots.first.toLowerCase()}.');
    }

    return sb.toString();
  }

  /// Character analysis sections for deep profile view
  List<CharacterInsight> generateCharacterAnalysis() {
    final List<CharacterInsight> insights = <CharacterInsight>[];

    // Attachment style inference
    String attachmentNote;
    if (highAssurance && vulnerabilityArea == 'Terk edilme') {
      attachmentNote =
          'Kaygılı bağlanma eğilimin güçlü. Yakınlık istersin ama reddi de şiddetli yaşarsın. Bu, ilişkinin başında aşırı uyumlu olmana ve kendi ihtiyaçlarını bastırmana yol açabilir.';
    } else if (selfProtectionScore > 0.5 &&
        fatigueResponse == FatigueResponse.pullAway) {
      attachmentNote =
          'Kaçıngan bağlanma eğilimin var. Yakınlık arttığında geri çekilme refleksin devreye giriyor. Bu, seni koruyor gibi görünür ama aslında gerçek bağlanmayı geciktirir.';
    } else if (highAssurance &&
        fatigueResponse == FatigueResponse.test) {
      attachmentNote =
          'Kaygılı-kaçıngan karışık bir örüntün olabilir. Hem yakınlık istersin hem de test edersin — bu karşı taraf için çok yorucu bir döngü yaratır.';
    } else {
      attachmentNote =
          'Bağlanma stilin görece dengeli görünüyor. Ama bu, stres altındayken nasıl davrandığınla test edilir — rahat zamanlarda herkes güvenli bağlanır.';
    }
    insights.add(CharacterInsight(
      title: 'Bağlanma eğilimin',
      body: attachmentNote,
      score: 1.0 - emotionalDependencyRisk,
      scoreLabel: 'Bağlanma dengesi',
    ));

    // Decision pattern
    String decisionNote;
    if (highIdealization && hasFastAttachment) {
      decisionNote =
          'Hızlı karar verme eğilimin var ve bu kararlar duygusal çekimle şekilleniyor. "Bu farklı" dediğin kişiler muhtemelen aynı pattern\'in farklı versiyonları. Karar vermeden önce en az 3 hafta bekle.';
    } else if (hasFastElimination) {
      decisionNote =
          'Çok hızlı eleme eğilimin var. Bu bazen seni korur ama bazen potansiyeli olan insanları da kaybettirir. Soru şu: gerçekten uyumsuzluk mu görüyorsun, yoksa kaygıdan mı kaçıyorsun?';
    } else if (highIdealization) {
      decisionNote =
          'İdealizasyon eğilimin karar sürecini bulandırıyor. İlk izlenim seni fazla etkiliyor. Somut davranışları 3 buluşma boyunca gözlemlemeden karar vermemen önerilir.';
    } else {
      decisionNote =
          'Karar sürecin görece dengeli. Ama "potansiyel" kelimesine dikkat et — potansiyel, bugünkü davranışın yerine geçmez.';
    }
    insights.add(CharacterInsight(
      title: 'Karar verme örüntün',
      body: decisionNote,
      score: romanticRealismScore,
      scoreLabel: 'Gerçekçilik',
    ));

    // Boundary analysis
    insights.add(CharacterInsight(
      title: 'Sınır sağlığın',
      body: boundaryHealthScore > 0.6
          ? 'Sınır farkındalığın iyi seviyede. Ama fark etmek ile uygulamak farklı şeyler. Sınır ihlali yaşadığında ne kadar çabuk tepki verdiğine dikkat et.'
          : boundaryHealthScore > 0.35
              ? 'Sınır bilincin var ama uygulamada zorluklar yaşıyorsun. Özellikle hoşlandığın birinden gelen sınır ihlallerini normalleştirme eğilimin olabilir.'
              : 'Sınır sağlığın kritik seviyede. Kendi ihtiyaçlarını geri plana atma ve red flag rasyonalize etme eğilimin birleşince, seni zor duruma düşürebilecek ilişkilere açık hale gelirsin.',
      score: boundaryHealthScore,
      scoreLabel: 'Sınır gücü',
    ));

    // Communication truth
    String commNote;
    if (directVsSoft == 'Doğrudan' &&
        conflictStyle == ConflictStyle.talkItOut) {
      commNote =
          'İletişim stilin tutarlı — hem doğrudan hem de çatışmada çözüm odaklısın. Bu güçlü bir kombinasyon.';
    } else if (directVsSoft == 'Doğrudan' &&
        (conflictStyle == ConflictStyle.shutDown ||
            conflictStyle == ConflictStyle.distance)) {
      commNote =
          'Doğrudan olduğunu söylüyorsun ama çatışmada kapanıyorsun. Bu, güvenli alanda doğrudan ama tehdit hissettiğinde savunmaya geçen bir pattern. Gerçek iletişim gücü, zor anlarda ölçülür.';
    } else {
      commNote =
          'İletişim stilin esnek ama netliğe ihtiyaç var. Belirsizlikte ${ambiguityResponse.label.toLowerCase()} eğilimin, karşı tarafa mesaj veriyor — sen farkında olsan da olmasan da.';
    }
    insights.add(CharacterInsight(
      title: 'İletişim gerçeğin',
      body: commNote,
      score: null,
      scoreLabel: null,
    ));

    return insights;
  }

  /// Legacy compatibility helpers
  List<String> get biasFlags => blindSpots;
  String get clarityExpectation =>
      ambiguityTolerance > 0.5
          ? 'belirsizliği tolere edebilirim'
          : 'netlik arıyorum';
  bool get highSafetySensitivity => highBoundarySensitivity;
}

// ══════════════════════════════════════════════
//  Inconsistency Model
// ══════════════════════════════════════════════

enum InconsistencySeverity {
  mild('Hafif'),
  moderate('Orta'),
  significant('Dikkat');

  const InconsistencySeverity(this.label);
  final String label;
}

class ProfileInconsistency {
  const ProfileInconsistency({
    required this.title,
    required this.explanation,
    required this.severity,
  });

  final String title;
  final String explanation;
  final InconsistencySeverity severity;
}

class CharacterInsight {
  const CharacterInsight({
    required this.title,
    required this.body,
    required this.score,
    required this.scoreLabel,
  });

  final String title;
  final String body;
  final double? score;
  final String? scoreLabel;
}

// ──────────────────────────────────────────────
// Reflection & Analysis Models (unchanged API)
// ──────────────────────────────────────────────

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

class ClarityDimension {
  const ClarityDimension({
    required this.title,
    required this.state,
    required this.note,
  });

  final String title;
  final DimensionState state;
  final String note;
}

class ValidationFeedback {
  const ValidationFeedback({
    this.missingContext = '',
    this.leastAccuratePart = '',
  });

  final String missingContext;
  final String leastAccuratePart;

  bool get hasAny =>
      missingContext.trim().isNotEmpty || leastAccuratePart.trim().isNotEmpty;

  List<String> get notes {
    final List<String> items = <String>[];
    if (missingContext.trim().isNotEmpty) {
      items.add('Eksik kalan bağlam: ${missingContext.trim()}');
    }
    if (leastAccuratePart.trim().isNotEmpty) {
      items.add('En az doğru gelen bölüm: ${leastAccuratePart.trim()}');
    }
    return items;
  }
}

class CheckInRecord {
  const CheckInRecord({
    required this.day,
    required this.outcome,
    required this.interactionState,
    required this.consistencyState,
    required this.note,
    required this.createdAt,
  });

  final int day;
  final CheckInOutcome outcome;
  final String interactionState;
  final String consistencyState;
  final String note;
  final DateTime createdAt;
}

class PendingCheckInTask {
  const PendingCheckInTask({
    required this.entryIndex,
    required this.title,
    required this.day,
    required this.scheduledFor,
  });

  final int entryIndex;
  final String title;
  final int day;
  final DateTime scheduledFor;
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
    required this.dimensions,
    required this.evidenceMix,
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
  final List<ClarityDimension> dimensions;
  final Map<String, int> evidenceMix;

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
      dimensions: dimensions,
      evidenceMix: evidenceMix,
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
    this.completedCheckIns = const <CheckInRecord>[],
    this.validationFeedback = const ValidationFeedback(),
    this.validations = const <String, ValidationChoice>{},
  });

  final String title;
  final DateTime createdAt;
  final InsightReport report;
  final String outcomeLabel;
  final List<int> pendingCheckIns;
  final List<CheckInRecord> completedCheckIns;
  final ValidationFeedback validationFeedback;
  final Map<String, ValidationChoice> validations;

  JournalEntry copyWith({
    String? title,
    DateTime? createdAt,
    InsightReport? report,
    String? outcomeLabel,
    List<int>? pendingCheckIns,
    List<CheckInRecord>? completedCheckIns,
    ValidationFeedback? validationFeedback,
    Map<String, ValidationChoice>? validations,
  }) {
    return JournalEntry(
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      report: report ?? this.report,
      outcomeLabel: outcomeLabel ?? this.outcomeLabel,
      pendingCheckIns: pendingCheckIns ?? this.pendingCheckIns,
      completedCheckIns: completedCheckIns ?? this.completedCheckIns,
      validationFeedback: validationFeedback ?? this.validationFeedback,
      validations: validations ?? this.validations,
    );
  }
}

// ══════════════════════════════════════════════
//  Daily Emotional Check-in
// ══════════════════════════════════════════════

class DailyCheckIn {
  const DailyCheckIn({
    required this.date,
    required this.mood,
    required this.triggers,
    required this.energyLevel,
    required this.romanticThought,
    required this.miniReflection,
    required this.readinessSnapshot,
  });

  final DateTime date;
  final MoodLevel mood;
  final List<EmotionalTrigger> triggers;
  final EnergyLevel energyLevel;
  final String romanticThought;    // what's on their mind romantically
  final String miniReflection;      // 1-2 sentence daily reflection
  final double readinessSnapshot;   // snapshot of readiness at this point
}

// ══════════════════════════════════════════════
//  Interaction Log — Any Romantic Signal
// ══════════════════════════════════════════════

class InteractionLogEntry {
  const InteractionLogEntry({
    required this.date,
    required this.personLabel,
    required this.interactionType,
    required this.energy,
    required this.whatHappened,
    required this.whatYouFelt,
    required this.redFlagNoticed,
    required this.greenFlagNoticed,
    this.profileInsight,
  });

  final DateTime date;
  final String personLabel;          // nickname or label for the person
  final InteractionType interactionType;
  final InteractionEnergy energy;
  final String whatHappened;
  final String whatYouFelt;
  final String redFlagNoticed;       // any red flag, can be empty
  final String greenFlagNoticed;     // any green flag, can be empty
  final String? profileInsight;      // AI-generated insight based on profile
}

// ══════════════════════════════════════════════
//  Daily Personalized Insight/Prompt
// ══════════════════════════════════════════════

class DailyInsight {
  const DailyInsight({
    required this.date,
    required this.prompt,
    required this.category,
    required this.relatedProfileArea,
  });

  final DateTime date;
  final String prompt;
  final String category;             // kör nokta, inanç, sınır, iletişim, etc
  final String relatedProfileArea;
}

// ══════════════════════════════════════════════
//  Readiness History Point (for evolution chart)
// ══════════════════════════════════════════════

class ReadinessHistoryPoint {
  const ReadinessHistoryPoint({
    required this.date,
    required this.readiness,
    required this.idealization,
    required this.boundary,
    required this.selfAwareness,
    required this.emotionalRegulation,
  });

  final DateTime date;
  final double readiness;
  final double idealization;
  final double boundary;
  final double selfAwareness;
  final double emotionalRegulation;
}
