// ══════════════════════════════════════════════════════════════
//  Sıfır Maliyetli Türkçe Metin Analiz Motoru
//  ──────────────────────────────────────────────
//  Harici API yok · Kütüphane yok · Tamamen cihaz üzerinde
//  Kural tabanlı Türkçe NLP: anahtar kelime sözlükleri,
//  duygu tonu, bağlanma örüntüsü, sınır sağlığı,
//  ve çapraz doğrulama analizi
// ══════════════════════════════════════════════════════════════

/// Tek bir metin parçasının analiz sonucu
class TextAnalysisResult {
  const TextAnalysisResult({
    this.emotionalTone = EmotionalTone.neutral,
    this.dominantThemes = const <ProfileTheme>[],
    this.intensityScore = 0.0,
    this.selfAwarenessSignals = 0,
    this.boundarySignals = 0,
    this.attachmentSignals = 0,
    this.idealizationSignals = 0,
    this.regulationSignals = 0,
    this.dependencySignals = 0,
    this.protectionSignals = 0,
    this.detectedKeywords = const <String>[],
    this.crossReferenceFlags = const <CrossReferenceFlag>[],
  });

  final EmotionalTone emotionalTone;
  final List<ProfileTheme> dominantThemes;

  /// 0.0–1.0 arası: metnin duygusal yoğunluğu
  final double intensityScore;

  /// Her boyut için tespit edilen sinyal sayısı (pozitif = artırıcı, negatif = azaltıcı)
  final int selfAwarenessSignals;
  final int boundarySignals;
  final int attachmentSignals;
  final int idealizationSignals;
  final int regulationSignals;
  final int dependencySignals;
  final int protectionSignals;

  final List<String> detectedKeywords;
  final List<CrossReferenceFlag> crossReferenceFlags;

  bool get isEmpty => detectedKeywords.isEmpty && crossReferenceFlags.isEmpty;
}

/// Birden fazla metin alanının birleşik analiz sonucu
class CompositeAnalysis {
  const CompositeAnalysis({
    this.selfAwarenessModifier = 0.0,
    this.boundaryModifier = 0.0,
    this.emotionalRegulationModifier = 0.0,
    this.idealizationModifier = 0.0,
    this.dependencyModifier = 0.0,
    this.protectionModifier = 0.0,
    this.attachmentSpeedModifier = 0.0,
    this.crossReferenceFlags = const <CrossReferenceFlag>[],
    this.narrativeDepthScore = 0.0,
    this.consistencyScore = 1.0,
    this.detectedPatterns = const <String>[],
  });

  /// Her skor için -0.3 ila +0.3 arası düzeltme
  final double selfAwarenessModifier;
  final double boundaryModifier;
  final double emotionalRegulationModifier;
  final double idealizationModifier;
  final double dependencyModifier;
  final double protectionModifier;
  final double attachmentSpeedModifier;

  final List<CrossReferenceFlag> crossReferenceFlags;

  /// 0.0–1.0: anlatı derinliği (uzunluk + çeşitlilik + duygu katmanı)
  final double narrativeDepthScore;

  /// 0.0–1.0: serbest metin ile çoktan seçmeli tutarlılığı
  final double consistencyScore;

  /// Tespit edilen psikolojik kalıp özetleri
  final List<String> detectedPatterns;
}

/// Çapraz doğrulama bayrağı
class CrossReferenceFlag {
  const CrossReferenceFlag({
    required this.field,
    required this.issue,
    required this.severity,
  });

  final String field;
  final String issue;
  final FlagSeverity severity;
}

enum FlagSeverity { low, medium, high }
enum EmotionalTone { positive, negative, anxious, conflicted, neutral, reflective }

enum ProfileTheme {
  attachment,        // bağlanma
  boundary,          // sınır
  selfAwareness,     // öz farkındalık
  idealization,      // idealleştirme
  dependency,        // bağımlılık
  protection,        // kendini koruma
  regulation,        // duygu düzenleme
  trust,             // güven
  abandonment,       // terk edilme
  control,           // kontrol
  perfectionism,     // mükemmeliyetçilik
  avoidance,         // kaçınma
  communication,     // iletişim
  intimacy,          // yakınlık
  selfWorth,         // öz değer
}

// ══════════════════════════════════════════════════════════════
//  Ana Motor
// ══════════════════════════════════════════════════════════════

class TextAnalysisEngine {
  const TextAnalysisEngine._();

  // ────────────────────────────────────
  //  Tek metin analizi
  // ────────────────────────────────────

  static TextAnalysisResult analyze(String text) {
    if (text.trim().length < 5) {
      return const TextAnalysisResult();
    }

    final String normalized = _normalize(text);
    final List<String> words = _tokenize(normalized);
    final List<String> detected = <String>[];

    int selfAwareness = 0;
    int boundary = 0;
    int attachment = 0;
    int idealization = 0;
    int regulation = 0;
    int dependency = 0;
    int protection = 0;

    // ── Anahtar kelime taraması ──
    for (final _KeywordRule rule in _allRules) {
      if (_matchesRule(normalized, words, rule)) {
        detected.add(rule.keyword);
        selfAwareness += rule.selfAwareness;
        boundary += rule.boundary;
        attachment += rule.attachment;
        idealization += rule.idealization;
        regulation += rule.regulation;
        dependency += rule.dependency;
        protection += rule.protection;
      }
    }

    // ── Duygu tonu ──
    final EmotionalTone tone = _detectTone(normalized, words);

    // ── Yoğunluk ──
    final double intensity = _calculateIntensity(normalized, words, detected.length);

    // ── Tema tespiti ──
    final List<ProfileTheme> themes = _detectThemes(
      selfAwareness: selfAwareness,
      boundary: boundary,
      attachment: attachment,
      idealization: idealization,
      regulation: regulation,
      dependency: dependency,
      protection: protection,
    );

    return TextAnalysisResult(
      emotionalTone: tone,
      dominantThemes: themes,
      intensityScore: intensity,
      selfAwarenessSignals: selfAwareness,
      boundarySignals: boundary,
      attachmentSignals: attachment,
      idealizationSignals: idealization,
      regulationSignals: regulation,
      dependencySignals: dependency,
      protectionSignals: protection,
      detectedKeywords: detected,
    );
  }

  // ────────────────────────────────────
  //  Çoklu alan birleşik analizi
  // ────────────────────────────────────

  static CompositeAnalysis analyzeProfile({
    required String selfDescription,
    required String friendDescription,
    required String threeExperiences,
    required String datingChallenge,
    required String freeformAboutMe,
    required String idealDay,
    required String openingUpTime,
    required String trustBuilder,
    required String recentDatingChallenge,
    required String respectSignal,
    required String valueConflict,
    required String showsInterestHow,
    required String messagingImportance,
    required String unheardFeeling,
    required String recurringPattern,
    required String feedbackFromCloseOnes,
    required String biggestMisjudgment,
    required String judgmentCloudedBy,
    required String stayedTooLong,
    required String feelingsChanged,
    required String boundaryDifficulty,
    required String safetyExperience,
    required String attachmentHistory,
    required String freeformForProfile,
    // Çoktan seçmeli referanslar (çapraz doğrulama için)
    required List<String> selectedBlindSpots,
    required String conflictStyleLabel,
    required String assuranceNeedLabel,
    required String fatigueResponseLabel,
    required String ambiguityResponseLabel,
  }) {
    // Her alanı analiz et
    final Map<String, TextAnalysisResult> results = <String, TextAnalysisResult>{
      'selfDescription': analyze(selfDescription),
      'friendDescription': analyze(friendDescription),
      'threeExperiences': analyze(threeExperiences),
      'datingChallenge': analyze(datingChallenge),
      'freeformAboutMe': analyze(freeformAboutMe),
      'idealDay': analyze(idealDay),
      'openingUpTime': analyze(openingUpTime),
      'trustBuilder': analyze(trustBuilder),
      'recentDatingChallenge': analyze(recentDatingChallenge),
      'respectSignal': analyze(respectSignal),
      'valueConflict': analyze(valueConflict),
      'showsInterestHow': analyze(showsInterestHow),
      'messagingImportance': analyze(messagingImportance),
      'unheardFeeling': analyze(unheardFeeling),
      'recurringPattern': analyze(recurringPattern),
      'feedbackFromCloseOnes': analyze(feedbackFromCloseOnes),
      'biggestMisjudgment': analyze(biggestMisjudgment),
      'judgmentCloudedBy': analyze(judgmentCloudedBy),
      'stayedTooLong': analyze(stayedTooLong),
      'feelingsChanged': analyze(feelingsChanged),
      'boundaryDifficulty': analyze(boundaryDifficulty),
      'safetyExperience': analyze(safetyExperience),
      'attachmentHistory': analyze(attachmentHistory),
      'freeformForProfile': analyze(freeformForProfile),
    };

    // ── Sinyalleri topla ──
    int totalSelfAwareness = 0;
    int totalBoundary = 0;
    int totalAttachment = 0;
    int totalIdealization = 0;
    int totalRegulation = 0;
    int totalDependency = 0;
    int totalProtection = 0;

    for (final TextAnalysisResult r in results.values) {
      totalSelfAwareness += r.selfAwarenessSignals;
      totalBoundary += r.boundarySignals;
      totalAttachment += r.attachmentSignals;
      totalIdealization += r.idealizationSignals;
      totalRegulation += r.regulationSignals;
      totalDependency += r.dependencySignals;
      totalProtection += r.protectionSignals;
    }

    // ── Skor düzelticileri hesapla (sigmoid benzeri yumuşatma) ──
    double selfAwarenessMod = _signalToModifier(totalSelfAwareness);
    double boundaryMod = _signalToModifier(totalBoundary);
    double regulationMod = _signalToModifier(totalRegulation);
    double idealizationMod = _signalToModifier(totalIdealization);
    double dependencyMod = _signalToModifier(totalDependency);
    double protectionMod = _signalToModifier(totalProtection);
    double attachmentMod = _signalToModifier(totalAttachment);

    // ── Anlatı derinliği ──
    final double narrativeDepth = _calculateNarrativeDepth(results);

    // Derin anlatı = daha yüksek öz farkındalık
    if (narrativeDepth > 0.6) selfAwarenessMod += 0.05;
    if (narrativeDepth > 0.8) selfAwarenessMod += 0.05;

    // ── Çapraz doğrulama ──
    final List<CrossReferenceFlag> flags = _crossReference(
      results: results,
      selectedBlindSpots: selectedBlindSpots,
      conflictStyleLabel: conflictStyleLabel,
      assuranceNeedLabel: assuranceNeedLabel,
      fatigueResponseLabel: fatigueResponseLabel,
      ambiguityResponseLabel: ambiguityResponseLabel,
    );

    // Tutarsızlık skoru
    final int highFlags = flags.where((CrossReferenceFlag f) => f.severity == FlagSeverity.high).length;
    final int medFlags = flags.where((CrossReferenceFlag f) => f.severity == FlagSeverity.medium).length;
    final double consistency = (1.0 - (highFlags * 0.15 + medFlags * 0.08)).clamp(0.0, 1.0);

    // Düşük tutarlılık = düşük öz farkındalık
    if (consistency < 0.5) selfAwarenessMod -= 0.1;

    // ── Tespit edilen kalıplar ──
    final List<String> patterns = _detectNarrativePatterns(results, flags);

    return CompositeAnalysis(
      selfAwarenessModifier: selfAwarenessMod.clamp(-0.3, 0.3),
      boundaryModifier: boundaryMod.clamp(-0.3, 0.3),
      emotionalRegulationModifier: regulationMod.clamp(-0.3, 0.3),
      idealizationModifier: idealizationMod.clamp(-0.3, 0.3),
      dependencyModifier: dependencyMod.clamp(-0.3, 0.3),
      protectionModifier: protectionMod.clamp(-0.3, 0.3),
      attachmentSpeedModifier: attachmentMod.clamp(-0.3, 0.3),
      crossReferenceFlags: flags,
      narrativeDepthScore: narrativeDepth,
      consistencyScore: consistency,
      detectedPatterns: patterns,
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  Günlük metin analizi (kayıt ve etkileşim notları için)
  // ══════════════════════════════════════════════════════════════

  static TextAnalysisResult analyzeDailyText(String text) => analyze(text);

  // ══════════════════════════════════════════════════════════════
  //  Debrief On-Device Derinlik Kontrolü (Cost Management)
  // ══════════════════════════════════════════════════════════════

  static double analyzeDebriefDepth({
    required String sensory,
    required String dialogs,
    required String valueTests,
    required String emotional,
  }) {
    final String combined = '$sensory $dialogs $valueTests $emotional'.trim();
    if (combined.isEmpty) return 0.0;

    final int words = combined.split(RegExp(r'\s+')).length;
    
    // 50 kelime %100'lük baz skor sayılır. (Maks 70).
    double score = (words / 50.0) * 70.0;
    
    // Her anlamlı (10 karaktere sahip) alan için +7.5 puan ekle (Maks 30).
    int filledFields = 0;
    if (sensory.trim().length >= 10) filledFields++;
    if (dialogs.trim().length >= 10) filledFields++;
    if (valueTests.trim().length >= 10) filledFields++;
    if (emotional.trim().length >= 10) filledFields++;
    
    score += (filledFields * 7.5);

    return score.clamp(0.0, 100.0);
  }

  // ══════════════════════════════════════════════════════════════
  //  Türkçe Anahtar Kelime Sözlükleri
  // ══════════════════════════════════════════════════════════════

  // Her kural: bir kelime/kalıp + hangi boyutları ne yönde etkiler
  // Pozitif = sağlıklı sinyal, Negatif = risk sinyali

  static const List<_KeywordRule> _allRules = <_KeywordRule>[
    // ── BAĞLANMA / ATTACHMENT ──
    _KeywordRule(keyword: 'hemen bağlan', attachment: -2, dependency: -1),
    _KeywordRule(keyword: 'çok çabuk bağlan', attachment: -2, dependency: -1),
    _KeywordRule(keyword: 'hızlı bağlan', attachment: -2),
    _KeywordRule(keyword: 'anında bağlan', attachment: -2),
    _KeywordRule(keyword: 'ilk görüşte', attachment: -1, idealization: -1),
    _KeywordRule(keyword: 'aşık ol', attachment: -1, idealization: -1),
    _KeywordRule(keyword: 'hemen aşık', attachment: -2, idealization: -2),
    _KeywordRule(keyword: 'çok hızlı aşık', attachment: -2, idealization: -1),
    _KeywordRule(keyword: 'takıntı', attachment: -2, regulation: -1),
    _KeywordRule(keyword: 'obsesif', attachment: -2, regulation: -1),
    _KeywordRule(keyword: 'kafamdan çıkar', attachment: -1, regulation: -1),
    _KeywordRule(keyword: 'kafamdan atamı', attachment: -1, regulation: -1),
    _KeywordRule(keyword: 'sürekli düşün', attachment: -1, dependency: -1),
    _KeywordRule(keyword: 'aklımdan çıkmı', attachment: -1),
    _KeywordRule(keyword: 'yavaş yavaş', attachment: 1),
    _KeywordRule(keyword: 'zamanla', attachment: 1),
    _KeywordRule(keyword: 'acele etme', attachment: 1, selfAwareness: 1),
    _KeywordRule(keyword: 'tanıyarak', attachment: 1),

    // ── TERK EDİLME / ABANDONMENT ──
    _KeywordRule(keyword: 'terk edil', dependency: -2, attachment: -1),
    _KeywordRule(keyword: 'bırakıl', dependency: -1, attachment: -1),
    _KeywordRule(keyword: 'yalnız kal', dependency: -1, protection: -1),
    _KeywordRule(keyword: 'yalnız bırak', dependency: -1),
    _KeywordRule(keyword: 'gidecek', dependency: -1, attachment: -1),
    _KeywordRule(keyword: 'vazgeçecek', dependency: -1),
    _KeywordRule(keyword: 'beni bırak', dependency: -2, attachment: -1),
    _KeywordRule(keyword: 'kaybet', dependency: -1),
    _KeywordRule(keyword: 'kaybetme korkusu', dependency: -2, attachment: -1),

    // ── GÜVENCE / ASSURANCE ──
    _KeywordRule(keyword: 'güvence', dependency: -1),
    _KeywordRule(keyword: 'emin ol', dependency: -1),
    _KeywordRule(keyword: 'sürekli sor', dependency: -2, regulation: -1),
    _KeywordRule(keyword: 'beni seviyor mu', dependency: -2),
    _KeywordRule(keyword: 'onay', dependency: -1),
    _KeywordRule(keyword: 'doğrulama ihtiyac', dependency: -1),
    _KeywordRule(keyword: 'teyit', dependency: -1),
    _KeywordRule(keyword: 'mesaj bekleme', dependency: -1, regulation: -1),
    _KeywordRule(keyword: 'cevap bekleme', dependency: -1, regulation: -1),
    _KeywordRule(keyword: 'neden yazmıyor', dependency: -1, regulation: -1),

    // ── İDEALLEŞTİRME / IDEALIZATION ──
    _KeywordRule(keyword: 'mükemmel', idealization: -2),
    _KeywordRule(keyword: 'kusursuz', idealization: -2),
    _KeywordRule(keyword: 'rüya gibi', idealization: -2),
    _KeywordRule(keyword: 'masal gibi', idealization: -2),
    _KeywordRule(keyword: 'hayal ettiğim', idealization: -1),
    _KeywordRule(keyword: 'tam istediğim', idealization: -1),
    _KeywordRule(keyword: 'her şeyiyle', idealization: -1),
    _KeywordRule(keyword: 'potansiyel', idealization: -1),
    _KeywordRule(keyword: 'değişir', idealization: -1),
    _KeywordRule(keyword: 'değiştirebilirim', idealization: -2, selfAwareness: -1),
    _KeywordRule(keyword: 'düzeltebilirim', idealization: -1),
    _KeywordRule(keyword: 'kurtarabilirim', idealization: -2, boundary: -1),
    _KeywordRule(keyword: 'olduğu gibi', idealization: 1, selfAwareness: 1),
    _KeywordRule(keyword: 'gerçekçi', idealization: 1, selfAwareness: 1),
    _KeywordRule(keyword: 'kusurlarıyla', idealization: 1),

    // ── SINIR / BOUNDARY ──
    _KeywordRule(keyword: 'hayır diyem', boundary: -2),
    _KeywordRule(keyword: 'hayır demek', boundary: -1),
    _KeywordRule(keyword: 'reddedem', boundary: -2),
    _KeywordRule(keyword: 'sınır koy', boundary: 1),
    _KeywordRule(keyword: 'sınırlarım', boundary: 1, selfAwareness: 1),
    _KeywordRule(keyword: 'sınır ihlal', boundary: -1),
    _KeywordRule(keyword: 'kendimi feda', boundary: -2, dependency: -1),
    _KeywordRule(keyword: 'kendimi geri plan', boundary: -2, dependency: -1),
    _KeywordRule(keyword: 'kendi ihtiyac', boundary: -1),
    _KeywordRule(keyword: 'hoşgör', boundary: -1),
    _KeywordRule(keyword: 'katlan', boundary: -2),
    _KeywordRule(keyword: 'görmezden gel', boundary: -2, selfAwareness: -1),
    _KeywordRule(keyword: 'ses çıkarmam', boundary: -2, regulation: -1),
    _KeywordRule(keyword: 'idare et', boundary: -1),
    _KeywordRule(keyword: 'kabul etmemeli', boundary: 1, selfAwareness: 1),
    _KeywordRule(keyword: 'tolerans gösterme', boundary: 1),
    _KeywordRule(keyword: 'çizgiyi çiz', boundary: 1),

    // ── DUYGU DÜZENLEME / REGULATION ──
    _KeywordRule(keyword: 'patlı', regulation: -2),
    _KeywordRule(keyword: 'kontrolü kaybet', regulation: -2),
    _KeywordRule(keyword: 'kontrol edemi', regulation: -2),
    _KeywordRule(keyword: 'öfke', regulation: -1),
    _KeywordRule(keyword: 'sinir', regulation: -1),
    _KeywordRule(keyword: 'duygusal', regulation: -1),
    _KeywordRule(keyword: 'ağla', regulation: -1),
    _KeywordRule(keyword: 'panik', regulation: -2),
    _KeywordRule(keyword: 'kaygı', regulation: -1),
    _KeywordRule(keyword: 'endişe', regulation: -1),
    _KeywordRule(keyword: 'abartı', regulation: -1, selfAwareness: 1),
    _KeywordRule(keyword: 'sakin kal', regulation: 1),
    _KeywordRule(keyword: 'nefes al', regulation: 1),
    _KeywordRule(keyword: 'soğukkanlı', regulation: 1),
    _KeywordRule(keyword: 'mantıklı', regulation: 1),
    _KeywordRule(keyword: 'dengeli', regulation: 1),
    _KeywordRule(keyword: 'bastır', regulation: -1, protection: -1),
    _KeywordRule(keyword: 'içime at', regulation: -2, protection: -1),
    _KeywordRule(keyword: 'yutkunur', regulation: -1, protection: -1),

    // ── BAĞIMLILIK / DEPENDENCY ──
    _KeywordRule(keyword: 'onsuz yapam', dependency: -2),
    _KeywordRule(keyword: 'onsuz olamam', dependency: -2),
    _KeywordRule(keyword: 'bensiz yapam', dependency: 1),
    _KeywordRule(keyword: 'ihtiyacım var', dependency: -1),
    _KeywordRule(keyword: 'bağımlı', dependency: -2),
    _KeywordRule(keyword: 'tek başıma', dependency: 1, protection: 1),
    _KeywordRule(keyword: 'kendi ayaklar', dependency: 1),
    _KeywordRule(keyword: 'bağımsız', dependency: 1),
    _KeywordRule(keyword: 'mutluluğum ona bağlı', dependency: -2, regulation: -1),
    _KeywordRule(keyword: 'ruh halim ona bağlı', dependency: -2, regulation: -1),

    // ── KENDİNİ KORUMA / PROTECTION ──
    _KeywordRule(keyword: 'kaçın', protection: -1),
    _KeywordRule(keyword: 'uzaklaş', protection: -1),
    _KeywordRule(keyword: 'geri çekil', protection: -1),
    _KeywordRule(keyword: 'duvar ör', protection: -2),
    _KeywordRule(keyword: 'kapan', protection: -2),
    _KeywordRule(keyword: 'güvenm', protection: -1),
    _KeywordRule(keyword: 'güvenmem', protection: -2),
    _KeywordRule(keyword: 'kimseye güvenm', protection: -2),
    _KeywordRule(keyword: 'yakınlaşmak', protection: -1),
    _KeywordRule(keyword: 'mesafe koy', protection: -1),
    _KeywordRule(keyword: 'test et', protection: -1, regulation: -1),
    _KeywordRule(keyword: 'sına', protection: -1),
    _KeywordRule(keyword: 'açıl', protection: 1),
    _KeywordRule(keyword: 'güvenmeyi öğren', protection: 1, selfAwareness: 1),
    _KeywordRule(keyword: 'savunmasız', protection: 1, selfAwareness: 1),

    // ── ÖZ FARKINDALIK / SELF-AWARENESS ──
    _KeywordRule(keyword: 'fark ettim', selfAwareness: 2),
    _KeywordRule(keyword: 'fark ediyorum', selfAwareness: 2),
    _KeywordRule(keyword: 'farkındayım', selfAwareness: 2),
    _KeywordRule(keyword: 'biliyorum ki', selfAwareness: 1),
    _KeywordRule(keyword: 'kabul ediyorum', selfAwareness: 2),
    _KeywordRule(keyword: 'üzerinde çalış', selfAwareness: 2),
    _KeywordRule(keyword: 'geliştirmeye', selfAwareness: 1),
    _KeywordRule(keyword: 'zayıf noktam', selfAwareness: 2),
    _KeywordRule(keyword: 'hatam', selfAwareness: 1),
    _KeywordRule(keyword: 'hata yaptım', selfAwareness: 2),
    _KeywordRule(keyword: 'sorumluluğum', selfAwareness: 2),
    _KeywordRule(keyword: 'benim suçum', selfAwareness: 1),
    _KeywordRule(keyword: 'öğrendim', selfAwareness: 2),
    _KeywordRule(keyword: 'ders aldım', selfAwareness: 2),
    _KeywordRule(keyword: 'ders çıkardım', selfAwareness: 2),
    _KeywordRule(keyword: 'artık biliyorum', selfAwareness: 2),
    _KeywordRule(keyword: 'eğilimim', selfAwareness: 2),
    _KeywordRule(keyword: 'kalıbım', selfAwareness: 2),
    _KeywordRule(keyword: 'döngüm', selfAwareness: 2),
    _KeywordRule(keyword: 'tekrar ediyorum', selfAwareness: 1),
    _KeywordRule(keyword: 'onun suçu', selfAwareness: -2),
    _KeywordRule(keyword: 'hep karşımdaki', selfAwareness: -2),
    _KeywordRule(keyword: 'hep onlar', selfAwareness: -2),
    _KeywordRule(keyword: 'herkes aynı', selfAwareness: -1),
    _KeywordRule(keyword: 'şanssız', selfAwareness: -1),
    _KeywordRule(keyword: 'kaderim', selfAwareness: -1),

    // ── KONTROL ──
    _KeywordRule(keyword: 'kontrol et', regulation: -1, boundary: -1),
    _KeywordRule(keyword: 'kontrol altına', regulation: -1),
    _KeywordRule(keyword: 'telefonunu kontrol', boundary: -2, regulation: -1),
    _KeywordRule(keyword: 'mesajlarına bak', boundary: -2),
    _KeywordRule(keyword: 'neredesin', dependency: -1),
    _KeywordRule(keyword: 'kiminlesin', dependency: -1),
    _KeywordRule(keyword: 'kıskan', regulation: -1),
    _KeywordRule(keyword: 'sahiplen', boundary: -1),

    // ── MÜKEMMELİYETÇİLİK ──
    _KeywordRule(keyword: 'mükemmeliyetçi', idealization: -1, selfAwareness: 1),
    _KeywordRule(keyword: 'yeterli değil', idealization: -1, selfAwareness: -1),
    _KeywordRule(keyword: 'yetmez', idealization: -1),
    _KeywordRule(keyword: 'daha iyisini hak', idealization: -1),
    _KeywordRule(keyword: 'standartlarım', idealization: -1),
    _KeywordRule(keyword: 'beklentilerim yüksek', idealization: -1, selfAwareness: 1),

    // ── ÖZ DEĞER ──
    _KeywordRule(keyword: 'değersiz', dependency: -1, selfAwareness: -1),
    _KeywordRule(keyword: 'sevilmeyi hak', selfAwareness: 1),
    _KeywordRule(keyword: 'yeterli hisset', selfAwareness: 1),
    _KeywordRule(keyword: 'kendime güven', protection: 1, selfAwareness: 1),
    _KeywordRule(keyword: 'özgüven', selfAwareness: 1),
    _KeywordRule(keyword: 'yetersiz', dependency: -1),
    _KeywordRule(keyword: 'beğenilmek', dependency: -1),
    _KeywordRule(keyword: 'kabul görmek', dependency: -1),

    // ── KAÇINMA ──
    _KeywordRule(keyword: 'konuşmaktan kaçın', protection: -1, regulation: -1),
    _KeywordRule(keyword: 'yüzleşmek', protection: 1, selfAwareness: 1),
    _KeywordRule(keyword: 'yüzleşemem', protection: -2),
    _KeywordRule(keyword: 'erteliyorum', protection: -1, regulation: -1),
    _KeywordRule(keyword: 'görmezden', protection: -1, selfAwareness: -1),

    // ── İLETİŞİM ──
    _KeywordRule(keyword: 'konuşamı', regulation: -1, boundary: -1),
    _KeywordRule(keyword: 'ifade edem', regulation: -1),
    _KeywordRule(keyword: 'anlatamı', regulation: -1),
    _KeywordRule(keyword: 'duyulmadığım', boundary: -1, selfAwareness: 1),
    _KeywordRule(keyword: 'dinlenmi', boundary: -1),
    _KeywordRule(keyword: 'ciddiye alınmı', boundary: -1),
    _KeywordRule(keyword: 'açıkça söyle', regulation: 1, boundary: 1),
    _KeywordRule(keyword: 'dürüstçe', regulation: 1, selfAwareness: 1),
  ];

  // ══════════════════════════════════════════════════════════════
  //  Yardımcı Fonksiyonlar
  // ══════════════════════════════════════════════════════════════

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sçğıöşüâîû]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static List<String> _tokenize(String normalized) {
    return normalized.split(' ').where((String w) => w.length > 1).toList();
  }

  static bool _matchesRule(String normalized, List<String> words, _KeywordRule rule) {
    // Önce tam kalıp eşleştirmesi
    if (normalized.contains(rule.keyword)) return true;
    // Kök eşleştirmesi: Türkçe ek alma nedeniyle
    // "bağlanıyorum" → "bağlan" kökünü yakalar
    if (rule.keyword.length >= 4) {
      for (final String word in words) {
        if (word.length >= rule.keyword.length &&
            word.startsWith(rule.keyword.substring(0, (rule.keyword.length * 0.7).ceil()))) {
          return true;
        }
      }
    }
    return false;
  }

  static EmotionalTone _detectTone(String normalized, List<String> words) {
    int positive = 0, negative = 0, anxious = 0;

    for (final String word in words) {
      if (_positiveWords.any((String pw) => word.startsWith(pw))) positive++;
      if (_negativeWords.any((String nw) => word.startsWith(nw))) negative++;
      if (_anxiousWords.any((String aw) => word.startsWith(aw))) anxious++;
    }

    // Çelişen duygular = conflicted
    if (positive > 2 && negative > 2) return EmotionalTone.conflicted;
    if (anxious > 2) return EmotionalTone.anxious;

    // "fark ettim", "biliyorum", "öğrendim" gibi yansıtıcı kelimeler
    final bool hasReflective = _reflectiveWords.any((String rw) => normalized.contains(rw));
    if (hasReflective && negative <= 1) return EmotionalTone.reflective;

    if (positive > negative + 1) return EmotionalTone.positive;
    if (negative > positive + 1) return EmotionalTone.negative;
    return EmotionalTone.neutral;
  }

  static double _calculateIntensity(String normalized, List<String> words, int keywordCount) {
    double intensity = 0.0;

    // Uzunluk: daha uzun metin = daha yoğun anlatım
    final int charCount = normalized.length;
    if (charCount > 200) intensity += 0.2;
    if (charCount > 400) intensity += 0.15;
    if (charCount > 600) intensity += 0.1;

    // Anahtar kelime yoğunluğu
    if (keywordCount > 0) intensity += 0.1;
    if (keywordCount > 3) intensity += 0.15;
    if (keywordCount > 6) intensity += 0.1;

    // Yoğunlaştırıcı kelimeler
    for (final String amplifier in _amplifierWords) {
      if (normalized.contains(amplifier)) {
        intensity += 0.1;
      }
    }

    return intensity.clamp(0.0, 1.0);
  }

  static List<ProfileTheme> _detectThemes({
    required int selfAwareness,
    required int boundary,
    required int attachment,
    required int idealization,
    required int regulation,
    required int dependency,
    required int protection,
  }) {
    final List<MapEntry<ProfileTheme, int>> scored = <MapEntry<ProfileTheme, int>>[
      MapEntry<ProfileTheme, int>(ProfileTheme.selfAwareness, selfAwareness.abs()),
      MapEntry<ProfileTheme, int>(ProfileTheme.boundary, boundary.abs()),
      MapEntry<ProfileTheme, int>(ProfileTheme.attachment, attachment.abs()),
      MapEntry<ProfileTheme, int>(ProfileTheme.idealization, idealization.abs()),
      MapEntry<ProfileTheme, int>(ProfileTheme.regulation, regulation.abs()),
      MapEntry<ProfileTheme, int>(ProfileTheme.dependency, dependency.abs()),
      MapEntry<ProfileTheme, int>(ProfileTheme.protection, protection.abs()),
    ];
    scored.sort((MapEntry<ProfileTheme, int> a, MapEntry<ProfileTheme, int> b) =>
        b.value.compareTo(a.value));
    return scored
        .where((MapEntry<ProfileTheme, int> e) => e.value > 0)
        .take(3)
        .map((MapEntry<ProfileTheme, int> e) => e.key)
        .toList();
  }

  /// Sinyal sayısını -0.3 ila +0.3 arası düzelticiye çevirir
  /// Pozitif sinyaller skoru artırır, negatifler azaltır
  static double _signalToModifier(int signals) {
    if (signals == 0) return 0.0;
    // Yumuşak doygunluk: |signal| büyüdükçe etki azalan hızda artar
    final double sign = signals > 0 ? 1.0 : -1.0;
    final double magnitude = signals.abs().toDouble();
    // tanh benzeri: hızla doygunluğa ulaş
    return sign * 0.3 * (1.0 - 1.0 / (1.0 + magnitude * 0.25));
  }

  static double _calculateNarrativeDepth(Map<String, TextAnalysisResult> results) {
    int filledFields = 0;
    int totalKeywords = 0;
    int totalIntensity = 0;
    int reflectiveCount = 0;

    for (final MapEntry<String, TextAnalysisResult> entry in results.entries) {
      final TextAnalysisResult r = entry.value;
      if (!r.isEmpty) filledFields++;
      totalKeywords += r.detectedKeywords.length;
      totalIntensity += (r.intensityScore * 10).round();
      if (r.emotionalTone == EmotionalTone.reflective) reflectiveCount++;
    }

    final int totalFields = results.length;
    final double fillRate = totalFields > 0 ? filledFields / totalFields : 0.0;
    final double keywordRichness = (totalKeywords / 20.0).clamp(0.0, 1.0);
    final double reflectiveness = (reflectiveCount / 5.0).clamp(0.0, 1.0);
    final double avgIntensity = totalFields > 0 ? (totalIntensity / totalFields / 10.0) : 0.0;

    return ((fillRate * 0.3) + (keywordRichness * 0.3) +
            (reflectiveness * 0.2) + (avgIntensity * 0.2))
        .clamp(0.0, 1.0);
  }

  // ══════════════════════════════════════════════════════════════
  //  Çapraz Doğrulama: Serbest Metin ↔ Çoktan Seçmeli
  // ══════════════════════════════════════════════════════════════

  static List<CrossReferenceFlag> _crossReference({
    required Map<String, TextAnalysisResult> results,
    required List<String> selectedBlindSpots,
    required String conflictStyleLabel,
    required String assuranceNeedLabel,
    required String fatigueResponseLabel,
    required String ambiguityResponseLabel,
  }) {
    final List<CrossReferenceFlag> flags = <CrossReferenceFlag>[];

    // ── 1. Erken bağlanma sinyali metinde var ama kör noktada seçilmemiş ──
    final bool textShowsAttachment = _anyFieldHasTheme(results, ProfileTheme.attachment, negative: true);
    if (textShowsAttachment && !selectedBlindSpots.contains('Çok erken duygusal bağlanma')) {
      flags.add(const CrossReferenceFlag(
        field: 'bağlanma',
        issue: 'Metinlerinde hızlı bağlanma sinyalleri var ama kör noktalarında bunu seçmedin. Bu, fark etmediğin bir kalıp olabilir.',
        severity: FlagSeverity.high,
      ));
    }

    // ── 2. İdealleştirme sinyali metinde var ama inançlarda farkında değil ──
    final bool textShowsIdealization = _anyFieldHasTheme(results, ProfileTheme.idealization, negative: true);
    final TextAnalysisResult selfDesc = results['selfDescription'] ?? const TextAnalysisResult();
    final TextAnalysisResult dating = results['datingChallenge'] ?? const TextAnalysisResult();
    if (textShowsIdealization && !(selfDesc.idealizationSignals < -1 || dating.idealizationSignals < -1)) {
      // İdealleştirme farklı alanlarda dağılmış — inceden gelen bir kalıp
      if (!selectedBlindSpots.contains('Yoğun çekimi gerçek uyum sanma') &&
          !selectedBlindSpots.contains('Potansiyele aşırı yatırım yapma')) {
        flags.add(const CrossReferenceFlag(
          field: 'idealleştirme',
          issue: 'Metinlerinde idealleştirme eğilimi seziliyor ama kör noktalarında bu yönde bir seçim yok.',
          severity: FlagSeverity.medium,
        ));
      }
    }

    // ── 3. Sınır problemi metinde belirgin ama "hayır diyemem" tarzı serbest metinler ile çatışma stili tutarsız ──
    final bool textShowsBoundaryIssue = _anyFieldHasTheme(results, ProfileTheme.boundary, negative: true);
    if (textShowsBoundaryIssue &&
        conflictStyleLabel == 'Hemen konuşup çözmeye çalışırım') {
      flags.add(const CrossReferenceFlag(
        field: 'sınır-iletişim',
        issue: 'Metinlerinde sınır koyma zorluğu belirgin ama çatışma stilinde "konuşarak çözerim" seçmişsin. Sınır koymak ile konuşmak farklı beceriler.',
        severity: FlagSeverity.medium,
      ));
    }

    // ── 4. Güvence ihtiyacı düşük seçilmiş ama metinlerde bağımlılık sinyalleri var ──
    final bool textShowsDependency = _anyFieldHasTheme(results, ProfileTheme.dependency, negative: true);
    if (textShowsDependency && assuranceNeedLabel == 'Düşük') {
      flags.add(const CrossReferenceFlag(
        field: 'güvence-bağımlılık',
        issue: 'Güvence ihtiyacını düşük olarak işaretledin ama metinlerinde duygusal bağımlılık sinyalleri var. Bu bilinçdışı bir ihtiyaç olabilir.',
        severity: FlagSeverity.high,
      ));
    }

    // ── 5. Kendini koruma yüksek ama kaçınma fark edilmemiş ──
    final bool textShowsProtection = _anyFieldHasTheme(results, ProfileTheme.protection, negative: true);
    if (textShowsProtection && fatigueResponseLabel != 'Geri çekilirim') {
      flags.add(const CrossReferenceFlag(
        field: 'koruma-kaçınma',
        issue: 'Metinlerinde kendini koruma ve kaçınma kalıpları belirgin ama yorgunluk tepkinde bunu yansıtmıyorsun.',
        severity: FlagSeverity.low,
      ));
    }

    // ── 6. Duygu düzenleme sinyalleri metinde kötü ama belirsizlik tepkisi yapıcı seçilmiş ──
    final bool textShowsRegulationIssue = _anyFieldHasTheme(results, ProfileTheme.regulation, negative: true);
    if (textShowsRegulationIssue && ambiguityResponseLabel == 'Açıkça sorarım') {
      flags.add(const CrossReferenceFlag(
        field: 'düzenleme-belirsizlik',
        issue: 'Metinlerinde duygusal düzenleme zorluğu var ama belirsizlikte "açıkça sorarım" demişsin. Gerçek belirsizlik anında duygular devreye girdiğinde bu değişebilir.',
        severity: FlagSeverity.low,
      ));
    }

    // ── 7. "Hep karşımdaki" / dış suçlama varsa ama öz farkındalık yüksek sinyaller de varsa ──
    final TextAnalysisResult misjudgment = results['biggestMisjudgment'] ?? const TextAnalysisResult();
    final TextAnalysisResult feedback = results['feedbackFromCloseOnes'] ?? const TextAnalysisResult();
    if (misjudgment.selfAwarenessSignals < -1 && feedback.selfAwarenessSignals > 0) {
      flags.add(const CrossReferenceFlag(
        field: 'farkındalık-tutarsızlık',
        issue: 'Başkalarının geri bildirimini kabul ediyorsun ama en büyük yanlış değerlendirmende sorumluluğu dışarı yüklüyorsun. Bu bir çelişki.',
        severity: FlagSeverity.medium,
      ));
    }

    // ── 8. stayedTooLong dolu ama "çok hızlı eleme" kör noktası seçilmiş ──
    final TextAnalysisResult stayed = results['stayedTooLong'] ?? const TextAnalysisResult();
    if (!stayed.isEmpty && selectedBlindSpots.contains('Çok hızlı eleme ve vazgeçme')) {
      flags.add(const CrossReferenceFlag(
        field: 'kalma-eleme çelişkisi',
        issue: 'Fazla kaldığın bir ilişkiyi anlatıyorsun ama kör noktanda "çok hızlı eleme" seçmişsin. Her ikisi de doğru olabilir — farklı durumlarda farklı tepki veriyor olabilirsin.',
        severity: FlagSeverity.medium,
      ));
    }

    // ── 9. friendDescription ile selfDescription arasında ton farkı ──
    final TextAnalysisResult friendDesc = results['friendDescription'] ?? const TextAnalysisResult();
    if (!selfDesc.isEmpty && !friendDesc.isEmpty) {
      if (selfDesc.emotionalTone == EmotionalTone.positive &&
          friendDesc.emotionalTone == EmotionalTone.negative) {
        flags.add(const CrossReferenceFlag(
          field: 'öz-imaj tutarsızlığı',
          issue: 'Kendini olumlu anlatıyorsun ama arkadaşlarının seni nasıl tanımlayacağı daha olumsuz. Bu dışarıdan görünen bir kör nokta olabilir.',
          severity: FlagSeverity.high,
        ));
      }
      if (selfDesc.emotionalTone == EmotionalTone.negative &&
          friendDesc.emotionalTone == EmotionalTone.positive) {
        flags.add(const CrossReferenceFlag(
          field: 'öz-değer eksikliği',
          issue: 'Kendini olumsuz anlatıyorsun ama arkadaşların seni daha olumlu görüyor. Öz değer algında bir boşluk olabilir.',
          severity: FlagSeverity.medium,
        ));
      }
    }

    // ── 10. Duyulmamışlık hissi güçlü ama iletişim stili "derin konuşma" değil ──
    final TextAnalysisResult unheard = results['unheardFeeling'] ?? const TextAnalysisResult();
    if (!unheard.isEmpty && unheard.intensityScore > 0.3) {
      // Yoğun duyulmamışlık hissi = iletişimde problem sinyali
      flags.add(const CrossReferenceFlag(
        field: 'duyulmamışlık',
        issue: 'Duyulmadığını hissettiğin deneyimlerin yoğun. Bu, sınır koyma veya iletişimde bir kalıba işaret edebilir.',
        severity: FlagSeverity.medium,
      ));
    }

    return flags;
  }

  static bool _anyFieldHasTheme(
    Map<String, TextAnalysisResult> results,
    ProfileTheme theme, {
    bool negative = false,
  }) {
    int total = 0;
    for (final TextAnalysisResult r in results.values) {
      switch (theme) {
        case ProfileTheme.attachment:
          total += r.attachmentSignals;
        case ProfileTheme.boundary:
          total += r.boundarySignals;
        case ProfileTheme.selfAwareness:
          total += r.selfAwarenessSignals;
        case ProfileTheme.idealization:
          total += r.idealizationSignals;
        case ProfileTheme.dependency:
          total += r.dependencySignals;
        case ProfileTheme.protection:
          total += r.protectionSignals;
        case ProfileTheme.regulation:
          total += r.regulationSignals;
        default:
          break;
      }
    }
    return negative ? total < -2 : total > 2;
  }

  // ══════════════════════════════════════════════════════════════
  //  Anlatı Kalıpları
  // ══════════════════════════════════════════════════════════════

  static List<String> _detectNarrativePatterns(
    Map<String, TextAnalysisResult> results,
    List<CrossReferenceFlag> flags,
  ) {
    final List<String> patterns = <String>[];

    // Toplam sinyalleri hesapla
    int totalAttachment = 0, totalDependency = 0, totalProtection = 0;
    int totalIdealization = 0, totalBoundary = 0, totalRegulation = 0;
    int totalSelfAwareness = 0;

    for (final TextAnalysisResult r in results.values) {
      totalAttachment += r.attachmentSignals;
      totalDependency += r.dependencySignals;
      totalProtection += r.protectionSignals;
      totalIdealization += r.idealizationSignals;
      totalBoundary += r.boundarySignals;
      totalRegulation += r.regulationSignals;
      totalSelfAwareness += r.selfAwarenessSignals;
    }

    // Baskın kalıpları tespit et
    if (totalAttachment < -4 && totalDependency < -3) {
      patterns.add('Kaygılı bağlanma örüntüsü: hızlı bağlanma + güvence arama döngüsü');
    }
    if (totalProtection < -4 && totalBoundary < -2) {
      patterns.add('Kaçıngan koruma örüntüsü: duvarlar + yakınlıktan kaçınma');
    }
    if (totalIdealization < -4) {
      patterns.add('İdealleştirme-hayal kırıklığı döngüsü: yüksek beklenti → düşüş');
    }
    if (totalDependency < -4 && totalRegulation < -3) {
      patterns.add('Duygusal bağımlılık kalıbı: ruh hali karşı tarafa bağlı + düzenleme zorluğu');
    }
    if (totalBoundary < -4 && totalSelfAwareness > 2) {
      patterns.add('Bilinçli sınır sorunu: farkındalık yüksek ama uygulama zayıf — bilmek yetmiyor');
    }
    if (totalSelfAwareness > 6) {
      patterns.add('Güçlü yansıtma kapasitesi: deneyimlerden öğrenme eğilimi belirgin');
    }
    if (totalSelfAwareness < -4) {
      patterns.add('Dış yükleme eğilimi: sorumluluk dışarıya atılıyor — bu fark edilmeden tekrar eder');
    }
    if (totalAttachment < -3 && totalProtection < -3) {
      patterns.add('Yaklaş-kaç döngüsü: hem hızlı bağlanma hem kaçınma sinyalleri — çelişkili bağlanma');
    }

    // Çapraz doğrulama bayraklarından ek kalıplar
    final int highFlagCount = flags.where((CrossReferenceFlag f) => f.severity == FlagSeverity.high).length;
    if (highFlagCount >= 2) {
      patterns.add('Öz algı tutarsızlığı: söylediğin ile anlattığın arasında önemli farklar var');
    }

    return patterns;
  }

  // ══════════════════════════════════════════════════════════════
  //  Kelime Listeleri
  // ══════════════════════════════════════════════════════════════

  static const List<String> _positiveWords = <String>[
    'mutlu', 'güzel', 'harika', 'sevgi', 'huzur', 'güven', 'umut',
    'büyü', 'güçlü', 'olumlu', 'keyif', 'neşe', 'rahat', 'özgür',
    'başar', 'gurur', 'minnett', 'şükür', 'destek', 'anlayış',
  ];

  static const List<String> _negativeWords = <String>[
    'kötü', 'acı', 'üzgün', 'kırg', 'öfke', 'sinir', 'kork',
    'endişe', 'kaygı', 'yalnız', 'boş', 'çaresiz', 'umutsuz',
    'değersiz', 'yetersiz', 'terk', 'kayıp', 'ihanet', 'yalan',
    'aldatı', 'hayal kırık', 'pişman', 'suçlu', 'utanç',
  ];

  static const List<String> _anxiousWords = <String>[
    'kaygı', 'endişe', 'panik', 'tedirgin', 'huzursuz', 'gergin',
    'stres', 'baskı', 'bunaltı', 'daraltı', 'sıkıntı', 'belirsiz',
    'emin olam', 'ya ... olursa', 'acaba', 'korkuyorum',
  ];

  static const List<String> _reflectiveWords = <String>[
    'fark ettim', 'farkındayım', 'anladım', 'öğrendim', 'kabul ediyorum',
    'biliyorum ki', 'üzerinde çalış', 'geliştir', 'sorguladım',
    'düşünüyorum ki', 'eğilimim', 'kalıbım', 'ders aldım',
  ];

  static const List<String> _amplifierWords = <String>[
    'çok', 'aşırı', 'sürekli', 'daima', 'her zaman', 'hiçbir zaman',
    'asla', 'kesinlikle', 'mutlaka', 'korkunç', 'inanılmaz',
    'berbat', 'dehşet', 'delicesine', 'aşk', 'sapla',
  ];
}

// ══════════════════════════════════════════════════════════════
//  Dahili Kural Yapısı
// ══════════════════════════════════════════════════════════════

class _KeywordRule {
  const _KeywordRule({
    required this.keyword,
    this.selfAwareness = 0,
    this.boundary = 0,
    this.attachment = 0,
    this.idealization = 0,
    this.regulation = 0,
    this.dependency = 0,
    this.protection = 0,
  });

  final String keyword;
  final int selfAwareness;
  final int boundary;
  final int attachment;
  final int idealization;
  final int regulation;
  final int dependency;
  final int protection;
}
