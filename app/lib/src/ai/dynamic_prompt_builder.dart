// ══════════════════════════════════════════════════════════════
//  Dinamik Sistem Prompt Oluşturucu
//  ──────────────────────────────────
//  Her kullanıcıya "ayrı bir uygulama" hissi veren parça bu.
//  Profil verileri, kör noktalar, geçmiş kalıplar ve anlatı
//  tonu bir "sözleşme" olarak LLM'e enjekte edilir.
//  Klişe tavsiyeler yerine, o kullanıcıya özel dil ve mantıkla
//  çalışan bir karar asistanı oluşturur.
// ══════════════════════════════════════════════════════════════

import '../models.dart';
import '../text_analysis_engine.dart';

class DynamicPromptBuilder {
  const DynamicPromptBuilder._();

  // ══════════════════════════════════════════════
  //  Profil Derin Analiz Prompt'u
  // ══════════════════════════════════════════════

  /// Profil oluşturma sonrası derin karakter analizi için sistem talimatı
  static String buildProfileAnalysisPrompt(OnboardingProfile profile) {
    final StringBuffer sb = StringBuffer();

    sb.writeln(_coreIdentity(profile));
    sb.writeln('');
    sb.writeln(_profileContext(profile));
    sb.writeln('');
    sb.writeln(_highSensitivityContext(profile));
    sb.writeln('');
    sb.writeln(_analysisInstructions('profil_analizi'));
    sb.writeln('');
    sb.writeln(_responseFormat());

    return sb.toString();
  }

  /// Onboarding sonunda kisinin "ayna" raporu ve derin hafiza capasi.
  static String buildPsycheAnchorPrompt(OnboardingProfile profile) {
    final StringBuffer sb = StringBuffer();
    sb.writeln('## Kimlik');
    sb.writeln(
      'Sen yargilamayan ama fazla naziklesip gercegi bulandirmayan bir romantik karar analistisin.',
    );
    sb.writeln(
      'Amacin, kullanicinin onboarding cevaplarindan derin bir psikolojik capayi cikarmak.',
    );
    sb.writeln('');
    sb.writeln(_profileContext(profile));
    sb.writeln('');
    sb.writeln(_highSensitivityContext(profile));
    sb.writeln('');
    sb.writeln('## Gorev');
    sb.writeln('- Kullanicinin anlatisinin altindaki ana duygusal gercegi bul');
    sb.writeln('- Tekrar eden ihtiyacini veya yarali noktasini isimlendir');
    sb.writeln('- Baglanma stiline dair ihtiyatli ama isabetli bir yorum yap');
    sb.writeln('- Kullaniciya hitaben kisa bir ayna raporu yaz');
    sb.writeln(
      '- Gizli, hassas veya sosyal riski olan hayat bilgilerini yan not degil ana baglam olarak kullan',
    );
    sb.writeln(
      '- Evlilik, gizli iliski, cocuk, aile baskisi, kimlik gecisi, aciklanmamis hayat parcasi gibi bilgileri karari degistiren faktor say',
    );
    sb.writeln('');
    sb.writeln('## Yanit Formati (JSON)');
    sb.writeln('{');
    sb.writeln('  "mirror_report": "Kullaniciya hitaben 3-4 cumlelik kisa ayna raporu",');
    sb.writeln('  "core_realities": ["hayatini etkileyen keskin gercek 1", "gercek 2"],');
    sb.writeln('  "attachment_style": "ihtiyatli baglanma stili yorumu",');
    sb.writeln('  "hidden_triggers": ["tetikleyici 1", "tetikleyici 2"],');
    sb.writeln('  "sensitive_memories": [');
    sb.writeln('    {');
    sb.writeln('      "summary": "mahrem baglamin kisa ozeti",');
    sb.writeln('      "impact": "bu baglamin kararina etkisi",');
    sb.writeln('      "acknowledgement_line": "kullaniciya bunu gordugunu hissettiren tek cumle",');
    sb.writeln('      "tags": ["gizlilik", "aile", "guvenlik"]');
    sb.writeln('    }');
    sb.writeln('  ]');
    sb.writeln('}');
    return sb.toString();
  }

  // ══════════════════════════════════════════════
  //  Buluşma Yansıtma Prompt'u
  // ══════════════════════════════════════════════

  /// Buluşma analizi için kişiselleştirilmiş sistem talimatı
  static String buildDateReflectionPrompt(OnboardingProfile profile) {
    final StringBuffer sb = StringBuffer();

    sb.writeln(_coreIdentity(profile));
    sb.writeln('');
    sb.writeln(_profileContext(profile));
    sb.writeln('');
    sb.writeln(_highSensitivityContext(profile));
    sb.writeln('');
    sb.writeln('## Analiz Görevi');
    sb.writeln('Kullanıcının anlattığı buluşmayı/etkileşimi analiz et.');
    sb.writeln('');
    sb.writeln('Özel odak noktaları:');
    _blindSpotDirectives(sb, profile);
    sb.writeln('');
    sb.writeln(_patternMemory(profile));
    sb.writeln('');
    sb.writeln(_toneDirective(profile));
    sb.writeln('');
    sb.writeln(_responseFormat());

    return sb.toString();
  }

  /// Reflection raporu icin tek sozlesmeli JSON uretimi.
  static String buildReflectionReportPrompt(OnboardingProfile profile) {
    final String primaryValue =
        profile.values.isNotEmpty ? profile.values.first : 'netlik';

    final StringBuffer sb = StringBuffer();
    sb.writeln(_coreIdentity(profile));
    sb.writeln('');
    sb.writeln(_profileContext(profile));
    sb.writeln('');
    sb.writeln(_highSensitivityContext(profile));
    sb.writeln('');
    sb.writeln('## Reflection Analiz Gorevi');
    sb.writeln(
      'Kullanicinin anlattigi son bulusma veya etkilesimi, kendi profiliyle birlikte analiz et.',
    );
    sb.writeln(
      'Hem olumlu sinyalleri hem riskli sinyalleri ayir. Karsi tarafin somut davranisi ile kullanicinin yorumu arasindaki farki koru.',
    );
    sb.writeln('');
    _blindSpotDirectives(sb, profile);
    sb.writeln('');
    sb.writeln(_patternMemory(profile));
    sb.writeln('');
    sb.writeln(_toneDirective(profile));
    sb.writeln('');
    sb.writeln('## Cikti Kurallari');
    sb.writeln('- Kisa, anlasilir, kullanicinin yasina ve kavrama seviyesine uygun yaz');
    sb.writeln('- Ortaokul duzeyinde okunur netlik hedefle');
    sb.writeln('- Klişe tavsiye verme');
    sb.writeln('- Somut veri ile yorum arasini karistirma');
    sb.writeln('- Eger veri yetersizse bunu acikca soyle');
    sb.writeln(
      '- Kullanici daha once hassas bir hayat baglami paylastiysa ve bu yorumun tonunu veya riskini degistiriyorsa bunu nazik ama gorunur sekilde hesaba kat',
    );
    sb.writeln('');
    sb.writeln('## Yanit Formati (JSON)');
    sb.writeln('{');
    sb.writeln('  "summary": "2 cumlelik ana okuma",');
    sb.writeln('  "positive_signals": [');
    sb.writeln('    {"id": "pos_1", "title": "Baslik", "explanation": "Aciklama", "signal_type": "curiosity", "confidence": "medium"}');
    sb.writeln('  ],');
    sb.writeln('  "caution_signals": [');
    sb.writeln('    {"id": "cau_1", "title": "Baslik", "explanation": "Aciklama", "signal_type": "ambiguity", "confidence": "high"}');
    sb.writeln('  ],');
    sb.writeln('  "uncertainty_flags": ["Belirsizlik notu"],');
    sb.writeln('  "missing_data_points": ["Henuz gormedigimiz veri"],');
    sb.writeln('  "recommended_questions": ["Kullanicinin kendine soracagi net soru"],');
    sb.writeln('  "next_step": "Bu kullanici icin bir sonraki saglikli adim",');
    sb.writeln('  "safety_assessment": {');
    sb.writeln('    "escalated": false,');
    sb.writeln('    "headline": "Baslik",');
    sb.writeln('    "summary": "Kisa guvenlik aciklamasi",');
    sb.writeln('    "actions": ["Aksiyon 1"]');
    sb.writeln('  },');
    sb.writeln('  "memory_updates": ["Kullanicinin hafizasina yazilacak ogrenim"],');
    sb.writeln('  "dimensions": [');
    sb.writeln('    {"title": "$primaryValue", "state": "supported", "note": "Kisa yorum"}');
    sb.writeln('  ],');
    sb.writeln('  "evidence_mix": {"Serbest anlatim": 2, "Structured cevap": 1},');
    sb.writeln('  "personalized_guidance": {');
    sb.writeln('    "unique_direction": "Bu kullaniciya ozel yon",');
    sb.writeln('    "anti_cliche_language": "Klise olmayan vurucu hatirlatma"');
    sb.writeln('  },');
    sb.writeln('  "nlp_bias_flags": ["Idealizasyon", "Projeksiyon"],');
    sb.writeln('  "consistency_flags": ["Profil ve davranis arasinda dikkat noktasi"]');
    sb.writeln('}');
    return sb.toString();
  }

  // ══════════════════════════════════════════════
  //  Günlük Kayıt Prompt'u
  // ══════════════════════════════════════════════

  /// Günlük kayıt geri bildirimi için sistem talimatı
  static String buildDailyCheckInPrompt(OnboardingProfile profile) {
    final StringBuffer sb = StringBuffer();

    sb.writeln(_coreIdentity(profile));
    sb.writeln('');
    sb.writeln(_compactProfileContext(profile));
    sb.writeln('');
    sb.writeln(_highSensitivityContext(profile));
    sb.writeln('');
    sb.writeln('## Analiz Görevi');
    sb.writeln('Kullanıcının günlük duygusal kaydını analiz et.');
    sb.writeln('Kısa, isabetli ve kişisel geri bildirim ver.');
    sb.writeln('');
    sb.writeln('Kurallar:');
    sb.writeln('- Klişe motivasyon cümleleri KULLANMA');
    sb.writeln('- Kullanıcının kör noktalarıyla bağlantı kur');
    sb.writeln('- Eğer ruh hali düşükse ve güvence ihtiyacı yüksekse, bunu nazikçe hatırlat');
    sb.writeln('- Eğer ruh hali yüksekse ve idealleştirme eğilimi varsa, temkinli bir hatırlatma yap');
    sb.writeln('- 3-5 cümle yeterli, roman yazma');
    sb.writeln('');
    sb.writeln(_responseFormat());

    return sb.toString();
  }

  // ══════════════════════════════════════════════
  //  Etkileşim İçgörü Prompt'u
  // ══════════════════════════════════════════════

  /// Etkileşim kaydı analizi için sistem talimatı
  static String buildInteractionPrompt(OnboardingProfile profile) {
    final StringBuffer sb = StringBuffer();

    sb.writeln(_coreIdentity(profile));
    sb.writeln('');
    sb.writeln(_compactProfileContext(profile));
    sb.writeln('');
    sb.writeln(_highSensitivityContext(profile));
    sb.writeln('');
    sb.writeln('## Analiz Görevi');
    sb.writeln('Kullanıcının kaydettiği romantik etkileşimi analiz et.');
    sb.writeln('');
    sb.writeln('Sorulacak sorular:');
    sb.writeln('- Bu etkileşimde kullanıcının bilinen kör noktaları devrede miydi?');
    sb.writeln('- Anlattığı duygular gerçeklikle mi yoksa projeksiyonla mı besleniyor?');
    sb.writeln('- Karşı tarafın davranışı somut mu yoksa kullanıcının yorumu mu?');
    _blindSpotDirectives(sb, profile);
    sb.writeln('');
    sb.writeln(_responseFormat());

    return sb.toString();
  }

  // ══════════════════════════════════════════════
  //  Anlatı Derin Analiz Prompt'u
  // ══════════════════════════════════════════════

  /// Serbest metin derinlik analizi için sistem talimatı
  static String buildNarrativeAnalysisPrompt(OnboardingProfile profile) {
    final StringBuffer sb = StringBuffer();

    sb.writeln(_coreIdentity(profile));
    sb.writeln('');
    sb.writeln('## Anlatı Analiz Görevi');
    sb.writeln('Kullanıcının açık uçlu sorulara verdiği cevapları derin analiz et.');
    sb.writeln('');
    sb.writeln('Analiz katmanları:');
    sb.writeln('1. **Önyargı Tespiti**: Dış yükleme mi iç yükleme mi? Sorumluluk nereye atılıyor?');
    sb.writeln('2. **Değer Hiyerarşisi**: Satır arası hangi değerler ortaya çıkıyor?');
    sb.writeln('3. **Yazış Stili**: Analitik mi, duygusal mı, kaçıngan mı, savunmacı mı?');
    sb.writeln('4. **Tutarsızlık**: Farklı sorulara verilen cevaplar birbiriyle çelişiyor mu?');
    sb.writeln('5. **Bastırılmış İçerik**: Ne yazılmamış? Hangi konular atlanmış veya geçiştirilmiş?');
    sb.writeln('');
    sb.writeln('Önemli:');
    sb.writeln('- "Mükemmel" veya "harika" gibi kelimeler kullanma — dürüst ve keskin ol');
    sb.writeln('- Kullanıcıyı rahatsız edecek tespitlerden kaçınma, ama nazik ol');
    sb.writeln('- Somut örneklerle destekle: "X sorusuna verdiğin cevapta Y değerine atıf yapıyorsun ama Z sorusunda bunun tersi görünüyor"');
    sb.writeln('');
    sb.writeln(_responseFormat());

    return sb.toString();
  }

  // ══════════════════════════════════════════════
  //  Prompt Parçaları
  // ══════════════════════════════════════════════

  /// Temel kimlik: LLM'in rolü
  static String _coreIdentity(OnboardingProfile profile) {
    return '''## Kimlik
Sen, ${profile.displayName} için çalışan kişisel bir romantik karar asistanısın.
Görevin klişe tavsiyeler vermek DEĞİL — bu kullanıcının spesifik kalıplarını, kör noktalarını ve değer sistemini anlayarak ona özel içgörüler üretmek.
Her analizinde bu kullanıcının geçmiş hatalarını ve güçlü yanlarını göz önünde bulundur.
Türkçe yaz. Kısa, keskin, klişesiz.''';
  }

  /// Detaylı profil bağlamı
  static String _profileContext(OnboardingProfile profile) {
    final StringBuffer sb = StringBuffer();
    sb.writeln('## Kullanıcı Profili');
    sb.writeln('');

    // Temel özellikler
    sb.writeln('**Hedef**: ${profile.goal.label}');
    sb.writeln('**Tempo**: ${profile.pacingPreference.label}');
    sb.writeln('**Deneyim**: ${profile.relationshipExperience.label}');
    sb.writeln('**İletişim**: ${profile.communicationPreference.label}');
    sb.writeln('**Çatışma stili**: ${profile.conflictStyle.label}');
    sb.writeln('**Belirsizlik tepkisi**: ${profile.ambiguityResponse.label}');
    sb.writeln('**Güvence ihtiyacı**: ${profile.assuranceNeed.label}');
    sb.writeln('**Yorgunluk tepkisi**: ${profile.fatigueResponse.label}');
    sb.writeln('');

    // Skorlar
    sb.writeln('**Skorlar**:');
    sb.writeln('- İdealleştirme: ${(profile.idealizationScore * 100).toStringAsFixed(0)}%');
    sb.writeln('- Sınır sağlığı: ${(profile.boundaryHealthScore * 100).toStringAsFixed(0)}%');
    sb.writeln('- Öz farkındalık: ${(profile.selfAwarenessScore * 100).toStringAsFixed(0)}%');
    sb.writeln('- Duygu düzenleme: ${(profile.emotionalRegulationScore * 100).toStringAsFixed(0)}%');
    sb.writeln('- Duygusal bağımlılık riski: ${(profile.emotionalDependencyRisk * 100).toStringAsFixed(0)}%');
    sb.writeln('- Kendini koruma: ${(profile.selfProtectionScore * 100).toStringAsFixed(0)}%');
    sb.writeln('- İlişki hazırlığı: ${(profile.relationshipReadiness * 100).toStringAsFixed(0)}%');
    sb.writeln('');

    // Kör noktalar
    if (profile.blindSpots.isNotEmpty) {
      sb.writeln('**Kör noktalar**: ${profile.blindSpots.join(", ")}');
    }

    // Temel özellikler
    if (profile.coreTraits.isNotEmpty) {
      sb.writeln('**Temel özellikler**: ${profile.coreTraits.join(", ")}');
    }

    // Değerler
    if (profile.values.isNotEmpty) {
      sb.writeln('**Değerler**: ${profile.values.join(", ")}');
    }

    // Alarm tetikleyicileri
    if (profile.alarmTriggers.isNotEmpty) {
      sb.writeln('**Alarm tetikleyicileri**: ${profile.alarmTriggers.join(", ")}');
    }

    // Anlatı analizi sonuçları
    if (profile.detectedNarrativePatterns.isNotEmpty) {
      sb.writeln('');
      sb.writeln('**Metin analizinden tespit edilen kalıplar**:');
      for (final String pattern in profile.detectedNarrativePatterns) {
        sb.writeln('- $pattern');
      }
    }

    // Çapraz doğrulama bulguları
    final List<CrossReferenceFlag> highFlags = profile.crossReferenceFlags
        .where((CrossReferenceFlag f) => f.severity == FlagSeverity.high)
        .toList();
    if (highFlags.isNotEmpty) {
      sb.writeln('');
      sb.writeln('**Kritik çapraz doğrulama bulguları**:');
      for (final CrossReferenceFlag flag in highFlags) {
        sb.writeln('- [${flag.field}]: ${flag.issue}');
      }
    }

    // Tutarsızlıklar
    final List<ProfileInconsistency> inconsistencies = profile.detectInconsistencies();
    if (inconsistencies.isNotEmpty) {
      sb.writeln('');
      sb.writeln('**Profil tutarsızlıkları**:');
      for (final ProfileInconsistency inc in inconsistencies.take(5)) {
        sb.writeln('- ${inc.title}: ${inc.explanation}');
      }
    }

    return sb.toString();
  }

  /// Kompakt profil bağlamı (token tasarrufu için)
  static String _compactProfileContext(OnboardingProfile profile) {
    final StringBuffer sb = StringBuffer();
    sb.writeln('## Kullanıcı Özeti');
    sb.writeln('Hedef: ${profile.goal.label} | Tempo: ${profile.pacingPreference.label}');
    sb.writeln('Güvence: ${profile.assuranceNeed.label} | Çatışma: ${profile.conflictStyle.label}');
    sb.writeln('İdealleştirme: ${(profile.idealizationScore * 100).toStringAsFixed(0)}% | '
        'Sınır: ${(profile.boundaryHealthScore * 100).toStringAsFixed(0)}% | '
        'Farkındalık: ${(profile.selfAwarenessScore * 100).toStringAsFixed(0)}%');

    if (profile.blindSpots.isNotEmpty) {
      sb.writeln('Kör noktalar: ${profile.blindSpots.take(3).join(", ")}');
    }

    if (profile.detectedNarrativePatterns.isNotEmpty) {
      sb.writeln('Ana kalıp: ${profile.detectedNarrativePatterns.first}');
    }

    return sb.toString();
  }

  /// Kör nokta bazlı yönlendirmeler
  static void _blindSpotDirectives(StringBuffer sb, OnboardingProfile profile) {
    sb.writeln('');
    sb.writeln('### Bu kullanıcı için kritik kontrol noktaları:');

    if (profile.highIdealization) {
      sb.writeln('- İDEALLEŞTİRME YÜKSEK: Karşı tarafı abartıp abartmadığını sorgula. '
          '"Mükemmel" veya "tam istediğim" gibi ifadeler kırmızı bayrak.');
    }
    if (profile.highAssurance) {
      sb.writeln('- GÜVENCE İHTİYACI YÜKSEK: Güvence arama davranışının etkileşimi nasıl şekillendirdiğini analiz et. '
          'Mesaj bekleme, cevap süresine takılma gibi sinyallere dikkat.');
    }
    if (profile.hasFastAttachment) {
      sb.writeln('- HIZLI BAĞLANMA: Henüz erken aşamada aşırı yatırım yapıp yapmadığını kontrol et. '
          '"Sürekli düşünüyorum" tipi ifadeler uyarı sinyali.');
    }
    if (profile.hasFastElimination) {
      sb.writeln('- HIZLI ELEME: Küçük bir kusur yüzünden potansiyeli kaçırıp kaçırmadığını sorgula.');
    }
    if (profile.hasBlindSpot('Uyarı işaretlerini mantığa bürüme')) {
      sb.writeln('- RASYONALIZE ETME: Olumsuz davranışları mantıklı açıklamalarla geçiştirip geçiştirmediğini kontrol et.');
    }
    if (profile.hasBlindSpot('Kendi ihtiyacını sürekli geri plana atma')) {
      sb.writeln('- KENDİNİ GERI PLANA ATMA: Bu etkileşimde kendi ihtiyaçlarını ifade edip etmediğini sorgula.');
    }
    if (profile.hasBlindSpot('Kurtarıcı rolüne girme')) {
      sb.writeln('- KURTARICI ROLÜ: Karşı tarafın sorunlarını çözmeye mi yoksa ilişki kurmaya mı odaklandığını analiz et.');
    }
    if (profile.selfProtectionScore > 0.5) {
      sb.writeln('- KORUMA REFLEKSİ YÜKSEK: Duvarları gereksiz yere yükseltip yükseltmediğini kontrol et.');
    }
    if (profile.emotionalDependencyRisk > 0.5) {
      sb.writeln('- BAĞIMLILIK RİSKİ: Ruh hali karşı tarafın davranışına bağlı mı? Kendi kendine yeterliliği sorgula.');
    }
  }

  /// Döngü hafızası: geçmiş kalıplar
  static String _patternMemory(OnboardingProfile profile) {
    final StringBuffer sb = StringBuffer();
    sb.writeln('## Döngü Hafızası');

    if (profile.recurringPattern.trim().isNotEmpty) {
      sb.writeln('Kullanıcının bildiği tekrar eden kalıbı: "${profile.recurringPattern}"');
      sb.writeln('Bu kalıbın bu etkileşimde de geçerli olup olmadığını kontrol et.');
    }

    if (profile.biggestMisjudgment.trim().isNotEmpty) {
      sb.writeln('En büyük yanlış değerlendirmesi: "${profile.biggestMisjudgment}"');
      sb.writeln('Benzer bir yanlış değerlendirme riski var mı?');
    }

    if (profile.stayedTooLong.trim().isNotEmpty) {
      sb.writeln('Fazla kaldığı deneyim: "${profile.stayedTooLong}"');
    }

    if (profile.detectedNarrativePatterns.isNotEmpty) {
      sb.writeln('');
      sb.writeln('Metin analizinden tespit edilen kalıplar:');
      for (final String p in profile.detectedNarrativePatterns) {
        sb.writeln('- $p');
      }
    }

    return sb.toString();
  }

  /// Kullanıcının yazış stiline göre yanıt tonu
  static String _highSensitivityContext(OnboardingProfile profile) {
    final List<SensitiveContextMemory> memories =
        profile.psycheAnchor?.sensitiveMemories ?? const <SensitiveContextMemory>[];
    if (memories.isNotEmpty) {
      final StringBuffer sb = StringBuffer();
      sb.writeln('## Hassas Baglam');
      sb.writeln(
        'Buradaki mahrem baglamlari yorumun merkezindeki gercekler gibi kullan. Bunlari sadece not olarak gecme.',
      );
      for (final SensitiveContextMemory memory in memories.take(4)) {
        sb.writeln('- Ozet: ${memory.summary}');
        sb.writeln('  Etki: ${memory.impact}');
        sb.writeln('  Kullaniciya hissettir: ${memory.acknowledgementLine}');
        if (memory.tags.isNotEmpty) {
          sb.writeln('  Etiketler: ${memory.tags.join(", ")}');
        }
      }
      sb.writeln(
        'Bu baglam karari degistiriyorsa bunu nazik ama gorunur sekilde soyle. Kullanici siradan bir profile indirgenmemeli.',
      );
      return sb.toString();
    }

    final List<String> clues = <String>[
      profile.freeformAboutMe,
      profile.safetyExperience,
      profile.attachmentHistory,
      profile.partnerShouldKnowEarly,
      profile.freeformForProfile,
      profile.misunderstandingRisk,
    ]
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);

    if (clues.isEmpty) {
      return '## Hassas Baglam\nKullanici hassas bir baglam paylasmadiysa bunu uydurma.';
    }

    final StringBuffer sb = StringBuffer();
    sb.writeln('## Hassas Baglam');
    sb.writeln(
      'Burada kullanicinin hayatini, riskini veya mahremiyetini degistiren bilgiler olabilir. Bunlari yan not degil yorumun merkezindeki baglam olarak oku.',
    );
    for (final String clue in clues.take(6)) {
      sb.writeln('- $clue');
    }
    sb.writeln(
      'Bu bilgiler karari etkiliyorsa bunu nazik ama gorunur sekilde hesaba kat. Kullanici anlasildigini hissetsin.',
    );
    return sb.toString();
  }

  static String _toneDirective(OnboardingProfile profile) {
    final double depth = profile.narrativeDepthScore;
    final String tone;

    if (depth > 0.7) {
      tone = 'Bu kullanıcı derin ve analitik yazıyor. Yanıtlarında da aynı derinlikte ol. '
          'Soyut kavramları kullan, metaforlardan çekinme. Entelektüel bir ton.';
    } else if (depth > 0.4) {
      tone = 'Bu kullanıcı orta düzeyde detay veriyor. Dengeli bir ton kullan — '
          'ne fazla akademik ne fazla yüzeysel. Somut örneklerle destekle.';
    } else {
      tone = 'Bu kullanıcı kısa ve öz yazıyor. Yanıtlarını da kısa tut. '
          'Doğrudan, net, jargonsuz. Madde madde değil ama paragraf da yazma — 2-3 cümle yeterli.';
    }

    return '## Ton Direktifi\n$tone';
  }

  /// Analiz talimatları
  static String _analysisInstructions(String context) {
    return '''## Analiz Talimatları
- Klişe motivasyon cümleleri KULLANMA ("güçlüsün", "doğru kişi gelecek" gibi)
- Her tespitin somut olsun: "X yazmışsın ama Y de söylüyorsun — bu çelişki"
- Kullanıcının yazış stilini de analiz et (savunmacı/kaçıngan/açık/analitik)
- "Satır arası" değerleri çıkar — hobi değil, ihtiyaç olarak kodla
- Önyargı varsa belirt: iç yükleme mi dış yükleme mi (internal/external attribution)
- Bastırılmış içeriği fark et: hangi sorular geçiştirilmiş, neden?''';
  }

  /// JSON yanıt formatı
  static String _responseFormat() {
    return '''## Yanıt Formatı (JSON)
Yanıtını aşağıdaki JSON formatında ver:
{
  "profil_icgoru": "Ana profil içgörüsü (2-4 cümle)",
  "kor_nokta_uyarisi": "Aktif kör nokta uyarısı (varsa, yoksa boş string)",
  "dongu_tespiti": "Tekrar eden kalıp tespiti (varsa)",
  "kisisel_tavsiye": "Bu kullanıcıya özel, klişe olmayan tavsiye (1-2 cümle)",
  "onyargi_bayraklari": ["tespit edilen önyargı 1", "önyargı 2"],
  "deger_cikarimi": ["satır arası çıkarılan değer 1", "değer 2"],
  "duygusal_ton": "yazıdaki baskın duygusal ton",
  "guven_skoru": 0.0-1.0 arası analiz güven skoru
}''';
  }
}
