// ══════════════════════════════════════════════════════════════
//  Derin Analiz Orkestratörü
//  ──────────────────────────────────
//  Tüm AI servislerini tek bir arayüzde birleştirir.
//  Controller bu sınıf üzerinden AI pipeline'a erişir.
//
//  Katman Mimarisi:
//  ┌─────────────────────────────────────────┐
//  │  Controller (UI katmanı)                │
//  ├─────────────────────────────────────────┤
//  │  DeepAnalysisOrchestrator (bu dosya)    │
//  ├──────────┬──────────┬───────────────────┤
//  │ Embedding│  Groq    │  VectorStore      │
//  │ Service  │  LLM     │  (profil vektör)  │
//  ├──────────┴──────────┴───────────────────┤
//  │  TextAnalysisEngine (kural tabanlı)     │
//  │  → AI yoksa bu katman tek başına çalışır│
//  └─────────────────────────────────────────┘
//
//  Graceful Degradation:
//  Groq + HF varsa → Tam AI analiz
//  Sadece HF varsa → Vektörel + kural tabanlı
//  Hiçbiri yoksa   → Sadece kural tabanlı motor
// ══════════════════════════════════════════════════════════════

import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models.dart';
import '../mock_analysis_engine.dart';
import '../text_analysis_engine.dart';
import 'adaptive_follow_up_service.dart';
import 'ai_config.dart';
import 'ai_contracts.dart';
import 'dynamic_prompt_builder.dart';
import 'gemini_chat_service.dart';
import 'groq_analysis_service.dart';
import 'vector_profile_store.dart';

/// Birleşik analiz sonucu — hem kural tabanlı hem AI
class DeepAnalysisResult {
  const DeepAnalysisResult({
    required this.ruleBasedAnalysis,
    this.llmAnalysis,
    this.conceptMeanings = const <String, String>{},
    this.isAIEnhanced = false,
    this.processingTimeMs = 0,
  });

  /// Kural tabanlı motor sonucu (her zaman var)
  final CompositeAnalysis ruleBasedAnalysis;

  /// LLM analiz sonucu (AI pipeline aktifse)
  final LLMAnalysisResult? llmAnalysis;

  /// Kavramsal anlamlar: "güven" → bu kullanıcı için ne demek
  final Map<String, String> conceptMeanings;

  /// AI pipeline kullanıldı mı?
  final bool isAIEnhanced;

  /// İşlem süresi (ms)
  final int processingTimeMs;

  /// Birleşik profil içgörüsü
  String get profileInsight {
    if (llmAnalysis != null && llmAnalysis!.profileInsight.isNotEmpty) {
      return llmAnalysis!.profileInsight;
    }
    // Kural tabanlı fallback
    if (ruleBasedAnalysis.detectedPatterns.isNotEmpty) {
      return ruleBasedAnalysis.detectedPatterns.first;
    }
    return '';
  }

  /// Birleşik kör nokta uyarısı
  String get blindSpotWarning {
    if (llmAnalysis != null && llmAnalysis!.blindSpotWarning.isNotEmpty) {
      return llmAnalysis!.blindSpotWarning;
    }
    // Kural tabanlı: en yüksek seviyeli çapraz doğrulama
    final List<CrossReferenceFlag> high = ruleBasedAnalysis.crossReferenceFlags
        .where((CrossReferenceFlag f) => f.severity == FlagSeverity.high)
        .toList();
    if (high.isNotEmpty) return high.first.issue;
    return '';
  }

  /// Birleşik kişisel tavsiye
  String get personalizedAdvice {
    if (llmAnalysis != null && llmAnalysis!.personalizedAdvice.isNotEmpty) {
      return llmAnalysis!.personalizedAdvice;
    }
    return '';
  }

  /// Birleşik önyargı bayrakları
  List<String> get biasFlags {
    if (llmAnalysis != null && llmAnalysis!.biasFlags.isNotEmpty) {
      return llmAnalysis!.biasFlags;
    }
    return const <String>[];
  }

  /// Birleşik değer çıkarımları
  List<String> get valueExtractions {
    if (llmAnalysis != null && llmAnalysis!.valueExtractions.isNotEmpty) {
      return llmAnalysis!.valueExtractions;
    }
    return const <String>[];
  }
}

class DeepAnalysisOrchestrator {
  DeepAnalysisOrchestrator._();
  static final DeepAnalysisOrchestrator instance =
      DeepAnalysisOrchestrator._();

  bool get hasChatAi => AIConfig.instance.isChatLlmAvailable;
  bool get hasDeepAnalysisAi =>
      AIConfig.instance.hasGemini || AIConfig.instance.hasGroq;
  bool get hasFullMotor =>
      hasDeepAnalysisAi && AIConfig.instance.hasHuggingFace;

  Future<AiEnvelope<ChatTurnPayload>> runChatOnboardingTurn({
    required String systemPrompt,
    required String userMessage,
    required String fallbackReply,
  }) async {
    final Stopwatch sw = Stopwatch()..start();
    final String contentHash = _buildHash(<Object?>[
      systemPrompt,
      userMessage,
      AIConfig.instance.hasGemini,
      AIConfig.instance.hasGroq,
    ]);

    Future<AiEnvelope<ChatTurnPayload>> runWithProvider({
      required Future<Map<String, dynamic>> Function() call,
      required String provider,
    }) async {
      final Map<String, dynamic> json = await call();
      sw.stop();
      return AiEnvelope<ChatTurnPayload>(
        task: AiTaskType.chatOnboardingTurn,
        mode: AiRunMode.llm,
        payload: _parseChatTurnPayload(json, fallbackReply),
        latencyMs: sw.elapsedMilliseconds,
        contentHash: contentHash,
        isEnhanced: true,
        provider: provider,
        note: 'Sohbet ve profil cikarma tek cagrida uretildi.',
      );
    }

    if (AIConfig.instance.hasGemini) {
      try {
        return await runWithProvider(
          call: () => GeminiChatService.instance.generateJson(
            systemPrompt: systemPrompt,
            userMessage: userMessage,
          ),
          provider: 'Gemini 2.5 Flash',
        );
      } catch (e) {
        debugPrint('Chat onboarding Gemini hatasi, Groq deneniyor: $e');
      }
    }

    if (AIConfig.instance.hasGroq) {
      try {
        return await runWithProvider(
          call: () => GroqAnalysisService.instance.completeJson(
            systemPrompt: systemPrompt,
            userMessage: userMessage,
          ),
          provider: 'Groq Qwen3 32B',
        );
      } catch (e) {
        debugPrint('Chat onboarding Groq hatasi: $e');
      }
    }

    sw.stop();
    return AiEnvelope<ChatTurnPayload>(
      task: AiTaskType.chatOnboardingTurn,
      mode: AiRunMode.local,
      payload: ChatTurnPayload(reply: fallbackReply),
      latencyMs: sw.elapsedMilliseconds,
      contentHash: contentHash,
      provider: 'Yerel sohbet fallback',
      note: 'LLM olmadigi icin yerel soru kullanildi.',
    );
  }

  Future<AiEnvelope<BeliefExtractionPayload>> extractBeliefScores({
    required String systemPrompt,
    required String userMessage,
  }) async {
    final Stopwatch sw = Stopwatch()..start();
    final String contentHash = _buildHash(<Object?>[
      systemPrompt,
      userMessage,
      AIConfig.instance.hasGemini,
      AIConfig.instance.hasGroq,
    ]);

    BeliefExtractionPayload fallback = const BeliefExtractionPayload(
      beliefRightPersonFindsWay: 4,
      beliefChemistryFeltFast: 4,
      beliefStrongAttractionIsSign: 4,
      beliefFeelsRightOrNot: 4,
      beliefFirstFeelingsAreTruth: 4,
      beliefPotentialEqualsValue: 4,
      beliefAmbiguityIsNormal: 4,
      beliefLoveOvercomesIssues: 4,
    );

    if (AIConfig.instance.hasGemini) {
      try {
        final Map<String, dynamic> json =
            await GeminiChatService.instance.generateJson(
          systemPrompt: systemPrompt,
          userMessage: userMessage,
        );
        sw.stop();
        return AiEnvelope<BeliefExtractionPayload>(
          task: AiTaskType.beliefExtraction,
          mode: AiRunMode.llm,
          payload: _parseBeliefPayload(json),
          latencyMs: sw.elapsedMilliseconds,
          contentHash: contentHash,
          isEnhanced: true,
          provider: 'Gemini 2.5 Flash',
        );
      } catch (e) {
        debugPrint('Belief extraction Gemini hatasi, Groq deneniyor: $e');
      }
    }

    if (AIConfig.instance.hasGroq) {
      try {
        final Map<String, dynamic> json =
            await GroqAnalysisService.instance.completeJson(
          systemPrompt: systemPrompt,
          userMessage: userMessage,
        );
        sw.stop();
        return AiEnvelope<BeliefExtractionPayload>(
          task: AiTaskType.beliefExtraction,
          mode: AiRunMode.llm,
          payload: _parseBeliefPayload(json),
          latencyMs: sw.elapsedMilliseconds,
          contentHash: contentHash,
          isEnhanced: true,
          provider: 'Groq Qwen3 32B',
        );
      } catch (e) {
        debugPrint('Belief extraction Groq hatasi: $e');
      }
    }

    sw.stop();
    return AiEnvelope<BeliefExtractionPayload>(
      task: AiTaskType.beliefExtraction,
      mode: AiRunMode.local,
      payload: fallback,
      latencyMs: sw.elapsedMilliseconds,
      contentHash: contentHash,
      provider: 'Yerel varsayilan',
      note: 'Inanc skorlarina erisilemedigi icin varsayilan orta skorlar kullanildi.',
    );
  }

  Future<AiEnvelope<UserPsycheAnchor>> generatePsycheAnchor(
    OnboardingProfile profile,
  ) async {
    final Stopwatch sw = Stopwatch()..start();
    final String contentHash = _buildHash(<Object?>[
      profile.displayName,
      profile.selfDescription,
      profile.datingChallenge,
      profile.freeformAboutMe,
      profile.misunderstandingRisk,
      profile.partnerShouldKnowEarly,
      profile.freeformForProfile,
    ]);

    UserPsycheAnchor payload = _buildLocalPsycheAnchor(profile);
    bool enhanced = false;
    String? error;
    String provider = 'Yerel temel motor';
    String note = AIConfig.instance.hasGemini
        ? 'Gemini 2.5 Flash denemesi baslatildi.'
        : (AIConfig.instance.hasGroq
            ? 'Groq fallback denemesi baslatildi.'
            : 'LLM anahtari olmadigi icin yerel ayna raporu kullanildi.');

    if (AIConfig.instance.hasGemini) {
      try {
        final Map<String, dynamic> json =
            await GeminiChatService.instance.generateJson(
          systemPrompt: DynamicPromptBuilder.buildPsycheAnchorPrompt(profile),
          userMessage: _buildProfileNarrativeMessage(profile),
        );
        payload = _parsePsycheAnchor(json, fallback: payload);
        enhanced = true;
        provider = 'Gemini 2.5 Flash';
        note = 'Gemini 2.5 Flash JSON cevabi basariyla cozuldu.';
      } catch (e) {
        debugPrint('Psyche anchor Gemini hatasi, Groq deneniyor: $e');
        error = e.toString();
        note = 'Gemini cagrisi basarisiz oldu; Groq fallback denenecek.';
      }
    }

    if (!enhanced && AIConfig.instance.hasGroq) {
      try {
        final Map<String, dynamic> json =
            await GroqAnalysisService.instance.completeJson(
          systemPrompt: DynamicPromptBuilder.buildPsycheAnchorPrompt(profile),
          userMessage: _buildProfileNarrativeMessage(profile),
        );
        payload = _parsePsycheAnchor(json, fallback: payload);
        enhanced = true;
        provider = 'Groq Qwen3 32B';
        error = null;
        note = 'Groq fallback JSON cevabi basariyla cozuldu.';
      } catch (e) {
        debugPrint('Psyche anchor Groq hatasi: $e');
        error = e.toString();
        note = 'Gemini ve Groq cagrilari basarisiz oldu; temel ayna raporuna donuldu.';
      }
    }

    sw.stop();
    return AiEnvelope<UserPsycheAnchor>(
      task: AiTaskType.onboardingMirror,
      mode: enhanced ? AiRunMode.llm : AiRunMode.local,
      payload: payload,
      latencyMs: sw.elapsedMilliseconds,
      contentHash: contentHash,
      isEnhanced: enhanced,
      provider: enhanced
          ? provider
          : ((AIConfig.instance.hasGemini || AIConfig.instance.hasGroq)
              ? 'LLM denendi -> yerel temel motor'
              : 'Yerel temel motor'),
      note: note,
      error: error,
    );
  }

  Future<AiEnvelope<List<AdaptiveFollowUpQuestion>>> generateAdaptiveFollowUps(
    OnboardingProfile profile,
  ) async {
    final Stopwatch sw = Stopwatch()..start();
    final List<AdaptiveFollowUpQuestion> payload =
        AdaptiveFollowUpService.buildQuestions(profile);
    sw.stop();
    return AiEnvelope<List<AdaptiveFollowUpQuestion>>(
      task: AiTaskType.adaptiveFollowUps,
      mode: AiRunMode.local,
      payload: payload,
      latencyMs: sw.elapsedMilliseconds,
      contentHash: _buildHash(<Object?>[
        profile.displayName,
        profile.values.join('|'),
        profile.blindSpots.join('|'),
        profile.alarmTriggers.join('|'),
        profile.relationshipExperience.label,
      ]),
    );
  }

  Future<AiEnvelope<InsightReport>> generateReflectionReport({
    required OnboardingProfile profile,
    required ReflectionDraft draft,
    required String sessionId,
  }) async {
    final Stopwatch sw = Stopwatch()..start();
    final String contentHash = _buildHash(<Object?>[
      sessionId,
      draft.dateContext,
      draft.sensoryObservations,
      draft.specificDialogs,
      draft.valueTests,
      draft.emotionalReactions,
      draft.followUpOffer,
      draft.futurePlanSignal,
      draft.comfortLevel,
      draft.clarityLevel,
      draft.physicalBoundaryIssue,
      draft.clarificationAnswers.join('|'),
    ]);

    final InsightReport fallback = MockAnalysisEngine.build(
      draft: draft,
      profile: profile,
      sessionId: sessionId,
    );

    InsightReport payload = fallback;
    bool enhanced = false;
    String? error;
    String provider = 'Yerel mock analiz';
    String note = AIConfig.instance.hasGemini
        ? 'Gemini 2.5 Flash reflection analizi denendi.'
        : (AIConfig.instance.hasGroq
            ? 'Groq reflection fallback denendi.'
            : 'LLM anahtari olmadigi icin reflection yerel motordan uretildi.');

    if (AIConfig.instance.hasGemini) {
      try {
        final Map<String, dynamic> json =
            await GeminiChatService.instance.generateJson(
          systemPrompt: DynamicPromptBuilder.buildReflectionReportPrompt(
            profile,
          ),
          userMessage: _buildReflectionUserMessage(draft),
        );
        payload = _parseReflectionReport(
          json,
          sessionId: sessionId,
          fallback: fallback,
        );
        enhanced = true;
        provider = 'Gemini 2.5 Flash';
        note = 'Gemini 2.5 Flash reflection JSON cevabi basariyla cozuldu.';
      } catch (e) {
        debugPrint('Reflection report Gemini hatasi, Groq deneniyor: $e');
        error = e.toString();
        note = 'Gemini reflection cagrisi basarisiz oldu; Groq fallback denenecek.';
      }
    }

    if (!enhanced && AIConfig.instance.hasGroq) {
      try {
        final Map<String, dynamic> json =
            await GroqAnalysisService.instance.completeJson(
          systemPrompt: DynamicPromptBuilder.buildReflectionReportPrompt(
            profile,
          ),
          userMessage: _buildReflectionUserMessage(draft),
        );
        payload = _parseReflectionReport(
          json,
          sessionId: sessionId,
          fallback: fallback,
        );
        enhanced = true;
        provider = 'Groq Qwen3 32B';
        error = null;
        note = 'Groq reflection fallback JSON cevabi basariyla cozuldu.';
      } catch (e) {
        debugPrint('Reflection report Groq hatasi: $e');
        error = e.toString();
        note = 'Gemini ve Groq reflection cagrilari basarisiz oldu; mock analiz kullanildi.';
      }
    }

    sw.stop();
    return AiEnvelope<InsightReport>(
      task: AiTaskType.reflectionReport,
      mode: enhanced ? AiRunMode.llm : AiRunMode.local,
      payload: payload,
      latencyMs: sw.elapsedMilliseconds,
      contentHash: contentHash,
      isEnhanced: enhanced,
      provider: enhanced
          ? provider
          : ((AIConfig.instance.hasGemini || AIConfig.instance.hasGroq)
              ? 'LLM denendi -> yerel mock analiz'
              : 'Yerel mock analiz'),
      note: note,
      error: error,
    );
  }

  // ══════════════════════════════════════════════
  //  Profil Derin Analizi
  // ══════════════════════════════════════════════

  /// Profil oluşturma sonrası tam derin analiz.
  /// 1. Kural tabanlı TextAnalysisEngine çalışır
  /// 2. Metinler vektörlenir ve depolanır
  /// 3. AI varsa Groq ile derin karakter analizi yapılır
  Future<DeepAnalysisResult> analyzeProfile(OnboardingProfile profile) async {
    final Stopwatch sw = Stopwatch()..start();

    // ── 1. Kural tabanlı analiz (her zaman çalışır) ──
    final CompositeAnalysis ruleResult = profile.textAnalysis;

    // ── 2. Metin vektörleme ──
    final Map<String, String> freeTextFields = _extractFreeTextFields(profile);
    try {
      await VectorProfileStore.instance.embedProfile(freeTextFields);
    } catch (e) {
      debugPrint('Vektörleme hatası: $e');
    }

    // ── 3. Kavramsal anlam çözümleme ──
    final Map<String, String> concepts = <String, String>{};
    try {
      for (final String concept in <String>[
        'güven', 'bağlanma', 'sınırlar', 'iletişim', 'değerler'
      ]) {
        concepts[concept] =
            await VectorProfileStore.instance.resolveConceptMeaning(concept);
      }
    } catch (e) {
      debugPrint('Kavram çözümleme hatası: $e');
    }

    // ── 4. LLM derin analiz (opsiyonel) ──
    LLMAnalysisResult? llmResult;
    if (AIConfig.instance.isAIPipelineAvailable) {
      try {
        final String systemPrompt =
            DynamicPromptBuilder.buildProfileAnalysisPrompt(profile);

        llmResult = await _runStructuredAnalysis(
          systemPrompt: systemPrompt,
          userMessage: _buildProfileAnalysisUserMessage(freeTextFields),
          type: AnalysisType.profileDeepDive,
        );
      } catch (e) {
        debugPrint('LLM profil analiz hatası: $e');
      }
    }

    sw.stop();

    return DeepAnalysisResult(
      ruleBasedAnalysis: ruleResult,
      llmAnalysis: llmResult,
      conceptMeanings: concepts,
      isAIEnhanced: llmResult != null && !llmResult.hasError,
      processingTimeMs: sw.elapsedMilliseconds,
    );
  }

  // ══════════════════════════════════════════════
  //  Buluşma / Etkileşim Analizi
  // ══════════════════════════════════════════════

  /// Etkileşim kaydını analiz et
  Future<DeepAnalysisResult> analyzeInteraction({
    required OnboardingProfile profile,
    required String whatHappened,
    required String whatYouFelt,
    required String redFlagNoticed,
    required String greenFlagNoticed,
    required String personLabel,
  }) async {
    final Stopwatch sw = Stopwatch()..start();

    // Kural tabanlı
    final String combinedText = '$whatHappened $whatYouFelt';
    final TextAnalysisResult ruleText =
        TextAnalysisEngine.analyzeDailyText(combinedText);

    final CompositeAnalysis ruleResult = CompositeAnalysis(
      selfAwarenessModifier: ruleText.selfAwarenessSignals * 0.03,
      boundaryModifier: ruleText.boundarySignals * 0.03,
      emotionalRegulationModifier: ruleText.regulationSignals * 0.03,
      idealizationModifier: ruleText.idealizationSignals * 0.03,
      dependencyModifier: ruleText.dependencySignals * 0.03,
      protectionModifier: ruleText.protectionSignals * 0.03,
    );

    // Vektörel: etkileşim metnini kullanıcı profiliyle karşılaştır
    Map<String, String> concepts = <String, String>{};
    try {
      final List<SimilarityResult> similar =
          await VectorProfileStore.instance.findSimilar(
        combinedText,
        topK: 3,
      );
      if (similar.isNotEmpty) {
        concepts['en_benzer_alan'] =
            '${similar.first.entry.fieldName}: ${similar.first.score.toStringAsFixed(2)}';
      }
    } catch (_) {}

    // LLM
    LLMAnalysisResult? llmResult;
    if (AIConfig.instance.isAIPipelineAvailable) {
      try {
        final String systemPrompt =
            DynamicPromptBuilder.buildInteractionPrompt(profile);

        final StringBuffer userMsg = StringBuffer();
        userMsg.writeln('Etkileşim kaydı:');
        userMsg.writeln('Kişi: $personLabel');
        userMsg.writeln('Ne oldu: $whatHappened');
        userMsg.writeln('Ne hissettim: $whatYouFelt');
        if (redFlagNoticed.trim().isNotEmpty) {
          userMsg.writeln('Uyarı işareti: $redFlagNoticed');
        }
        if (greenFlagNoticed.trim().isNotEmpty) {
          userMsg.writeln('Olumlu işaret: $greenFlagNoticed');
        }

        llmResult = await _runStructuredAnalysis(
          systemPrompt: systemPrompt,
          userMessage: userMsg.toString(),
          type: AnalysisType.interactionInsight,
        );
      } catch (e) {
        debugPrint('LLM etkileşim analiz hatası: $e');
      }
    }

    sw.stop();

    return DeepAnalysisResult(
      ruleBasedAnalysis: ruleResult,
      llmAnalysis: llmResult,
      conceptMeanings: concepts,
      isAIEnhanced: llmResult != null && !llmResult.hasError,
      processingTimeMs: sw.elapsedMilliseconds,
    );
  }

  // ══════════════════════════════════════════════
  //  Günlük Kayıt Analizi
  // ══════════════════════════════════════════════

  /// Günlük kayıt metnini analiz et
  Future<DeepAnalysisResult> analyzeDailyCheckIn({
    required OnboardingProfile profile,
    required String miniReflection,
    required String romanticThought,
    required String moodLabel,
    required List<String> triggerLabels,
  }) async {
    final Stopwatch sw = Stopwatch()..start();

    // Kural tabanlı
    final String combined = '$miniReflection $romanticThought';
    final TextAnalysisResult ruleText =
        TextAnalysisEngine.analyzeDailyText(combined);

    final CompositeAnalysis ruleResult = CompositeAnalysis(
      selfAwarenessModifier: ruleText.selfAwarenessSignals * 0.03,
      emotionalRegulationModifier: ruleText.regulationSignals * 0.03,
      idealizationModifier: ruleText.idealizationSignals * 0.03,
      dependencyModifier: ruleText.dependencySignals * 0.03,
    );

    // LLM
    LLMAnalysisResult? llmResult;
    if (AIConfig.instance.isAIPipelineAvailable &&
        combined.trim().length > 20) {
      try {
        final String systemPrompt =
            DynamicPromptBuilder.buildDailyCheckInPrompt(profile);

        llmResult = await _runStructuredAnalysis(
          systemPrompt: systemPrompt,
          userMessage: _buildDailyCheckInUserMessage(
            miniReflection: miniReflection,
            romanticThought: romanticThought,
            moodLabel: moodLabel,
            triggerLabels: triggerLabels,
          ),
          type: AnalysisType.dailyCheckInFeedback,
        );
      } catch (e) {
        debugPrint('LLM günlük analiz hatası: $e');
      }
    }

    sw.stop();

    return DeepAnalysisResult(
      ruleBasedAnalysis: ruleResult,
      llmAnalysis: llmResult,
      isAIEnhanced: llmResult != null && !llmResult.hasError,
      processingTimeMs: sw.elapsedMilliseconds,
    );
  }

  // ══════════════════════════════════════════════
  //  Anlatı Derin Analizi
  // ══════════════════════════════════════════════

  /// Tüm serbest metin alanlarını birlikte derin analiz et
  Future<DeepAnalysisResult> analyzeNarratives(
    OnboardingProfile profile,
  ) async {
    final Stopwatch sw = Stopwatch()..start();

    final CompositeAnalysis ruleResult = profile.textAnalysis;
    final Map<String, String> freeTextFields = _extractFreeTextFields(profile);

    LLMAnalysisResult? llmResult;
    if (AIConfig.instance.isAIPipelineAvailable) {
      try {
        final String systemPrompt =
            DynamicPromptBuilder.buildNarrativeAnalysisPrompt(profile);

        llmResult = await _runStructuredAnalysis(
          systemPrompt: systemPrompt,
          userMessage: _buildProfileAnalysisUserMessage(freeTextFields),
          type: AnalysisType.narrativeAnalysis,
        );
      } catch (e) {
        debugPrint('LLM anlatı analiz hatası: $e');
      }
    }

    sw.stop();

    return DeepAnalysisResult(
      ruleBasedAnalysis: ruleResult,
      llmAnalysis: llmResult,
      isAIEnhanced: llmResult != null && !llmResult.hasError,
      processingTimeMs: sw.elapsedMilliseconds,
    );
  }

  // ══════════════════════════════════════════════
  //  Pipeline Durum Bilgisi
  // ══════════════════════════════════════════════

  /// Hangi katmanlar aktif?
  Map<String, bool> get pipelineStatus => <String, bool>{
        'temel_mod': true,
        'sohbet_ai': hasChatAi,
        'derin_analiz': hasDeepAnalysisAi,
        'tam_motor': hasFullMotor,
        'vektor_hafiza': AIConfig.instance.hasHuggingFace,
        'bulut_depo': AIConfig.instance.hasSupabase,
      };

  String get pipelineLabel {
    if (hasFullMotor) return 'Tam motor hazır';
    if (hasDeepAnalysisAi) return 'Derin analiz hazır';
    if (hasChatAi) return 'Sohbet AI hazır';
    return 'Temel mod';
  }

  // ══════════════════════════════════════════════
  //  Yardımcı
  // ══════════════════════════════════════════════

  Future<LLMAnalysisResult?> _runStructuredAnalysis({
    required String systemPrompt,
    required String userMessage,
    required AnalysisType type,
  }) async {
    if (AIConfig.instance.hasGemini) {
      try {
        final Map<String, dynamic> json =
            await GeminiChatService.instance.generateJson(
          systemPrompt: systemPrompt,
          userMessage: userMessage,
        );
        return _parseStructuredAnalysisJson(json);
      } catch (e) {
        debugPrint('Gemini structured analysis hatasi, Groq deneniyor: $e');
      }
    }

    if (AIConfig.instance.hasGroq) {
      try {
        return await GroqAnalysisService.instance.analyze(
          systemPrompt: systemPrompt,
          userMessage: userMessage,
          type: type,
        );
      } catch (e) {
        debugPrint('Groq structured analysis hatasi: $e');
      }
    }

    return null;
  }

  LLMAnalysisResult _parseStructuredAnalysisJson(Map<String, dynamic> json) {
    return LLMAnalysisResult(
      rawResponse: jsonEncode(json),
      profileInsight: _analysisString(json, 'profil_icgoru'),
      blindSpotWarning: _analysisString(json, 'kor_nokta_uyarisi'),
      patternDetection: _analysisString(json, 'dongu_tespiti'),
      personalizedAdvice: _analysisString(json, 'kisisel_tavsiye'),
      biasFlags: _analysisStringList(json, 'onyargi_bayraklari'),
      valueExtractions: _analysisStringList(json, 'deger_cikarimi'),
      emotionalToneLabel: _analysisString(json, 'duygusal_ton'),
      confidenceScore: _analysisDouble(json, 'guven_skoru'),
    );
  }

  String _analysisString(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    return value is String ? value : '';
  }

  List<String> _analysisStringList(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value is List) {
      return value
          .map((dynamic item) => item.toString())
          .toList(growable: false);
    }
    return const <String>[];
  }

  double _analysisDouble(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value is num) {
      return value.toDouble().clamp(0.0, 1.0);
    }
    return 0.0;
  }

  Map<String, String> _extractFreeTextFields(OnboardingProfile profile) {
    return <String, String>{
      'Kendini tanimlama': profile.selfDescription,
      'Arkadas gozuyle': profile.friendDescription,
      'Uc deneyim': profile.threeExperiences,
      'Tanisma zorlugu': profile.datingChallenge,
      'Serbest tanitim': profile.freeformAboutMe,
      'Ideal gun': profile.idealDay,
      'Acilma suresi': profile.openingUpTime,
      'Guven insasi': profile.trustBuilder,
      'Son zorluk': profile.recentDatingChallenge,
      'Saygi sinyali': profile.respectSignal,
      'Deger catismasi': profile.valueConflict,
      'Ilgi gosterme': profile.showsInterestHow,
      'Mesajlasma': profile.messagingImportance,
      'Duyulmamislik': profile.unheardFeeling,
      'Tekrar eden kalip': profile.recurringPattern,
      'Yakinlarin geri bildirimi': profile.feedbackFromCloseOnes,
      'En buyuk yanlis degerlendirme': profile.biggestMisjudgment,
      'Karari bulandiran': profile.judgmentCloudedBy,
      'Fazla kalinan': profile.stayedTooLong,
      'Duygu degisimi': profile.feelingsChanged,
      'Sinir zorlugu': profile.boundaryDifficulty,
      'Guvenlik deneyimi': profile.safetyExperience,
      'Baglanma gecmisi': profile.attachmentHistory,
      'Yanlis anlasilma riski': profile.misunderstandingRisk,
      'Partnerin erken bilmesi gereken': profile.partnerShouldKnowEarly,
      'Serbest profil notu': profile.freeformForProfile,
    };
  }

  String _buildProfileNarrativeMessage(OnboardingProfile profile) {
    final Map<String, String> fields = _extractFreeTextFields(profile);
    final StringBuffer buffer = StringBuffer();
    for (final MapEntry<String, String> entry in fields.entries) {
      if (entry.value.trim().isEmpty) continue;
      buffer.writeln('${entry.key}: ${entry.value.trim()}');
    }
    return buffer.toString().trim();
  }

  String _buildProfileAnalysisUserMessage(Map<String, String> freeTextFields) {
    final StringBuffer userMsg = StringBuffer();
    userMsg.writeln('Kullanicinin profil cevaplari:');
    userMsg.writeln('');

    for (final MapEntry<String, String> entry in freeTextFields.entries) {
      if (entry.value.trim().isEmpty) continue;
      userMsg.writeln('## ${entry.key}');
      userMsg.writeln(entry.value.trim());
      userMsg.writeln('');
    }

    userMsg.writeln('---');
    userMsg.writeln(
      'Yukarıdaki tüm cevapları birlikte analiz et. Satır arası değerleri, önyargıları, tutarsızlıkları ve yazışma stilinden çıkarılabilecek karakter özelliklerini tespit et.',
    );
    return userMsg.toString().trim();
  }

  String _buildDailyCheckInUserMessage({
    required String miniReflection,
    required String romanticThought,
    required String moodLabel,
    required List<String> triggerLabels,
  }) {
    final StringBuffer userMsg = StringBuffer();
    userMsg.writeln('Bugunku kayit:');
    userMsg.writeln('Ruh hali: $moodLabel');
    if (triggerLabels.isNotEmpty) {
      userMsg.writeln('Tetikleyiciler: ${triggerLabels.join(", ")}');
    }
    if (miniReflection.trim().isNotEmpty) {
      userMsg.writeln('Kisa yansitma: $miniReflection');
    }
    if (romanticThought.trim().isNotEmpty) {
      userMsg.writeln('Romantik dusunce: $romanticThought');
    }
    userMsg.writeln('---');
    userMsg.writeln('Bu kaydi kullanicinin profil baglaminda analiz et.');
    return userMsg.toString().trim();
  }

  String _buildReflectionUserMessage(ReflectionDraft draft) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Date baglami: ${draft.dateContext}');
    if (draft.sensoryObservations.trim().isNotEmpty) {
      buffer.writeln('Duyusal gozlemler: ${draft.sensoryObservations.trim()}');
    }
    if (draft.specificDialogs.trim().isNotEmpty) {
      buffer.writeln('Spesifik diyaloglar: ${draft.specificDialogs.trim()}');
    }
    if (draft.valueTests.trim().isNotEmpty) {
      buffer.writeln('Deger testleri: ${draft.valueTests.trim()}');
    }
    if (draft.emotionalReactions.trim().isNotEmpty) {
      buffer.writeln('Duygusal reaksiyonlar: ${draft.emotionalReactions.trim()}');
    }
    buffer.writeln('Follow-up teklifi: ${draft.followUpOffer}');
    buffer.writeln('Gelecek plani sinyali: ${draft.futurePlanSignal}');
    buffer.writeln('Rahatlik seviyesi: ${draft.comfortLevel}');
    buffer.writeln('Netlik seviyesi: ${draft.clarityLevel}');
    buffer.writeln(
      'Sinir/baski/fiziksel rahatsizlik: ${draft.physicalBoundaryIssue ? "var" : "yok"}',
    );
    if (draft.clarificationAnswers.isNotEmpty) {
      buffer.writeln(
        'Netlestirme cevaplari: ${draft.clarificationAnswers.join(" | ")}',
      );
    }
    return buffer.toString().trim();
  }

  UserPsycheAnchor _buildLocalPsycheAnchor(OnboardingProfile profile) {
    final List<SensitiveContextMemory> sensitiveMemories =
        _deriveSensitiveMemories(profile);
    final List<String> coreRealities = <String>[];
    if (profile.freeformAboutMe.trim().isNotEmpty) {
      coreRealities.add(profile.freeformAboutMe.trim());
    }
    if (profile.attachmentHistory.trim().isNotEmpty) {
      coreRealities.add(profile.attachmentHistory.trim());
    }
    if (profile.partnerShouldKnowEarly.trim().isNotEmpty) {
      coreRealities.add(profile.partnerShouldKnowEarly.trim());
    }

    final List<String> hiddenTriggers = <String>[
      if (profile.vulnerabilityArea.trim().isNotEmpty)
        profile.vulnerabilityArea.trim(),
      ...profile.alarmTriggers.take(2),
    ];

    final String sensitiveContext = _summarizeSensitiveContext(
      profile,
      sensitiveMemories,
    );
    final String mirrorReport = <String>[
      '${profile.displayName.isEmpty ? "Sen" : profile.displayName} ${profile.goal.label.toLowerCase()} isterken ${profile.values.isNotEmpty ? profile.values.first.toLowerCase() : "netlik"} ariyor.',
      if (sensitiveMemories.isNotEmpty)
        sensitiveMemories.first.acknowledgementLine,
      if (sensitiveContext.isNotEmpty)
        'Paylastigin ozel hayat baglami bu kararlari siradan bir tanisma akisindan daha karmasik hale getiriyor: $sensitiveContext.',
      'En dikkat isteyen yer su an ${profile.blindSpots.isNotEmpty ? profile.blindSpots.first.toLowerCase() : "belirsizlik"} tarafi.',
    ].join(' ');

    return UserPsycheAnchor(
      mirrorReport: mirrorReport,
      coreRealities: coreRealities.take(3).toList(growable: false),
      attachmentStyle: _inferAttachmentStyle(profile),
      hiddenTriggers: hiddenTriggers.toSet().take(3).toList(growable: false),
      sensitiveMemories: sensitiveMemories,
    );
  }

  String _summarizeSensitiveContext(
    OnboardingProfile profile,
    List<SensitiveContextMemory> memories,
  ) {
    if (memories.isNotEmpty) {
      return memories.first.impact;
    }

    final String combined = <String>[
      profile.freeformAboutMe,
      profile.safetyExperience,
      profile.attachmentHistory,
      profile.partnerShouldKnowEarly,
      profile.freeformForProfile,
      profile.misunderstandingRisk,
    ].join(' ').toLowerCase();

    if (combined.trim().isEmpty) return '';
    if (combined.contains('evli')) {
      return 'mevcut bir iliski veya evlilik dengesi tasiyorsun';
    }
    if (combined.contains('cocug') || combined.contains('cocuk')) {
      return 'ebeveynlik ve gorunurluk baskisi karar alanini etkiliyor';
    }
    if (combined.contains('trans') ||
        combined.contains('cinsiyet') ||
        combined.contains('gecis')) {
      return 'kimlik, guvenlik ve ne zaman acilacagi sorusu kararlarini etkiliyor';
    }
    if (combined.contains('kimseye soylemed') ||
        combined.contains('gizli')) {
      return 'gizlilik ve sonucu kontrol etme ihtiyaci iliski kararlarini etkiliyor';
    }
    return 'paylastigin mahrem baglam iliski kararinin tonunu ve riskini degistiriyor';
  }

  List<SensitiveContextMemory> _deriveSensitiveMemories(
    OnboardingProfile profile,
  ) {
    final String combined = <String>[
      profile.freeformAboutMe,
      profile.safetyExperience,
      profile.attachmentHistory,
      profile.partnerShouldKnowEarly,
      profile.freeformForProfile,
      profile.misunderstandingRisk,
    ].join(' ');
    final String lowered = combined.toLowerCase();
    final List<SensitiveContextMemory> memories = <SensitiveContextMemory>[];

    void addMemory({
      required String summary,
      required String impact,
      required String acknowledgementLine,
      required List<String> tags,
    }) {
      final bool exists = memories.any(
        (SensitiveContextMemory memory) => memory.summary == summary,
      );
      if (!exists) {
        memories.add(
          SensitiveContextMemory(
            summary: summary,
            impact: impact,
            acknowledgementLine: acknowledgementLine,
            tags: tags,
          ),
        );
      }
    }

    if (lowered.contains('evli') || lowered.contains('eşim') || lowered.contains('esim')) {
      addMemory(
        summary: 'Mevcut bir evlilik veya paralel iliski dengesi tasiyor.',
        impact:
            'Gizlilik, sadakat, görünürlük ve sonuc yönetimi bu kararlari siradan bir tanisma akısından daha yuksek riskli hale getiriyor.',
        acknowledgementLine:
            'Paylastigin mevcut iliski veya evlilik baglamini kenara koymadan okuyorum.',
        tags: const <String>['evlilik', 'gizlilik', 'risk'],
      );
    }
    if (lowered.contains('cocug') || lowered.contains('çocu') || lowered.contains('ebeveyn')) {
      addMemory(
        summary: 'Cocuk ve gorunurluk sorumlulugu karar alanini etkiliyor.',
        impact:
            'Bakim sorumlulugu, zamanlama ve kime neyin ne zaman aciklanacagi bu iliski kararlarini dogrudan etkiliyor.',
        acknowledgementLine:
            'Cocukla ilgili paylastigin baglamin tempo ve görünürlük kararlarini degistirdigini goruyorum.',
        tags: const <String>['cocuk', 'aile', 'gorunurluk'],
      );
    }
    if (lowered.contains('trans') ||
        lowered.contains('cinsiyet') ||
        lowered.contains('geçiş') ||
        lowered.contains('gecis')) {
      addMemory(
        summary: 'Kimlik ve ne zaman acilacagi konusu iliski guvenligini etkiliyor.',
        impact:
            'Gorunurluk, guvenlik ve aciklanma zamani duygusal uyum kadar fiziksel ve sosyal riski de karar denklemine sokuyor.',
        acknowledgementLine:
            'Kimlik ve gorunurluk baglamini, yalnizca arka plan bilgisi degil kararinin merkezindeki gercek olarak aliyorum.',
        tags: const <String>['kimlik', 'guvenlik', 'aciklanma'],
      );
    }
    if (lowered.contains('kimseye söylemed') ||
        lowered.contains('kimseye soylemed') ||
        lowered.contains('gizli') ||
        lowered.contains('sakli')) {
      addMemory(
        summary: 'Hayatinda herkese acilmayan veya gizli tuttugun bir katman var.',
        impact:
            'Gizlilik ihtiyaci, iliskiyi sadece duygu uyumu uzerinden degil ortaya cikma maliyeti uzerinden de tartmana neden oluyor.',
        acknowledgementLine:
            'Gizli tuttugun baglamin sende ekstra kontrol ve temkin ihtiyaci yarattigini hesaba katiyorum.',
        tags: const <String>['gizlilik', 'mahremiyet', 'kontrol'],
      );
    }

    if (memories.isEmpty && combined.trim().isNotEmpty) {
      addMemory(
        summary: 'Mahrem ve kisisel bir hayat baglami paylastin.',
        impact:
            'Bu baglam, iliski kararlarini sadece his ve cekimle degil guvenlik, gorunurluk ve sonuc yonetimiyle birlikte tartmana yol aciyor.',
        acknowledgementLine:
            'Paylastigin ozel hayatin, bu karari siradan bir flort karari olmaktan cikariyor; bunu goruyorum.',
        tags: const <String>['mahremiyet', 'baglam'],
      );
    }

    return memories;
  }

  UserPsycheAnchor _parsePsycheAnchor(
    Map<String, dynamic> json, {
    required UserPsycheAnchor fallback,
  }) {
    return UserPsycheAnchor(
      mirrorReport: _jsonString(json, 'mirror_report', fallback.mirrorReport),
      coreRealities:
          _jsonStringList(json, 'core_realities', fallback.coreRealities),
      attachmentStyle:
          _jsonString(json, 'attachment_style', fallback.attachmentStyle),
      hiddenTriggers:
          _jsonStringList(json, 'hidden_triggers', fallback.hiddenTriggers),
      sensitiveMemories: _jsonSensitiveMemories(
        json,
        'sensitive_memories',
        fallback.sensitiveMemories,
      ),
    );
  }

  InsightReport _parseReflectionReport(
    Map<String, dynamic> json, {
    required String sessionId,
    required InsightReport fallback,
  }) {
    final Map<String, dynamic> safety =
        _jsonMap(json['safety_assessment']) ?? const <String, dynamic>{};
    final Map<String, dynamic> guidance =
        _jsonMap(json['personalized_guidance']) ?? const <String, dynamic>{};

    return InsightReport(
      schemaVersion: _jsonString(json, 'schema_version', 'v_ai_reflection_1'),
      sessionId: sessionId,
      summary: _jsonString(json, 'summary', fallback.summary),
      positiveSignals: _jsonSignals(
        json['positive_signals'],
        fallback.positiveSignals,
      ),
      cautionSignals: _jsonSignals(
        json['caution_signals'],
        fallback.cautionSignals,
      ),
      uncertaintyFlags: _jsonStringList(
        json,
        'uncertainty_flags',
        fallback.uncertaintyFlags,
      ),
      missingDataPoints: _jsonStringList(
        json,
        'missing_data_points',
        fallback.missingDataPoints,
      ),
      recommendedQuestions: _jsonStringList(
        json,
        'recommended_questions',
        fallback.recommendedQuestions,
      ),
      nextStep: _jsonString(json, 'next_step', fallback.nextStep),
      safetyAssessment: SafetyAssessment(
        escalated: safety['escalated'] is bool
            ? safety['escalated'] as bool
            : fallback.safetyAssessment.escalated,
        headline: _jsonString(
          safety,
          'headline',
          fallback.safetyAssessment.headline,
        ),
        summary: _jsonString(
          safety,
          'summary',
          fallback.safetyAssessment.summary,
        ),
        actions: _jsonStringList(
          safety,
          'actions',
          fallback.safetyAssessment.actions,
        ),
      ),
      memoryUpdates: _jsonStringList(
        json,
        'memory_updates',
        fallback.memoryUpdates,
      ),
      dimensions: _jsonDimensions(json['dimensions'], fallback.dimensions),
      evidenceMix: _jsonEvidenceMix(json['evidence_mix'], fallback.evidenceMix),
      personalizedGuidance: PersonalizedGuidance(
        uniqueDirection: _jsonString(
          guidance,
          'unique_direction',
          fallback.personalizedGuidance.uniqueDirection,
        ),
        antiClicheLanguage: _jsonString(
          guidance,
          'anti_cliche_language',
          fallback.personalizedGuidance.antiClicheLanguage,
        ),
      ),
      nlpBiasFlags: _jsonStringList(
        json,
        'nlp_bias_flags',
        fallback.nlpBiasFlags,
      ),
      consistencyFlags: _jsonStringList(
        json,
        'consistency_flags',
        fallback.consistencyFlags,
      ),
    );
  }

  ChatTurnPayload _parseChatTurnPayload(
    Map<String, dynamic> json,
    String fallbackReply,
  ) {
    final Map<String, dynamic> extracted =
        _jsonMap(json['extracted_fields']) ?? const <String, dynamic>{};
    return ChatTurnPayload(
      reply: _jsonString(json, 'assistant_reply', fallbackReply),
      extractedFields: extracted,
      acknowledgedSensitiveContext: json['acknowledged_sensitive_context'] == true,
    );
  }

  BeliefExtractionPayload _parseBeliefPayload(Map<String, dynamic> json) {
    int readBelief(String key) {
      final dynamic value = json[key];
      if (value is int) return value.clamp(1, 7);
      if (value is num) return value.round().clamp(1, 7);
      return 4;
    }

    return BeliefExtractionPayload(
      beliefRightPersonFindsWay: readBelief('beliefRightPersonFindsWay'),
      beliefChemistryFeltFast: readBelief('beliefChemistryFeltFast'),
      beliefStrongAttractionIsSign: readBelief('beliefStrongAttractionIsSign'),
      beliefFeelsRightOrNot: readBelief('beliefFeelsRightOrNot'),
      beliefFirstFeelingsAreTruth: readBelief('beliefFirstFeelingsAreTruth'),
      beliefPotentialEqualsValue: readBelief('beliefPotentialEqualsValue'),
      beliefAmbiguityIsNormal: readBelief('beliefAmbiguityIsNormal'),
      beliefLoveOvercomesIssues: readBelief('beliefLoveOvercomesIssues'),
    );
  }

  List<InsightSignal> _jsonSignals(
    dynamic source,
    List<InsightSignal> fallback,
  ) {
    if (source is! List || source.isEmpty) return fallback;
    return source
        .whereType<Map<String, dynamic>>()
        .map(
          (Map<String, dynamic> item) => InsightSignal(
            id: _jsonString(item, 'id', 'signal'),
            title: _jsonString(item, 'title', 'Durum tespiti'),
            explanation: _jsonString(item, 'explanation', ''),
            signalType: _jsonString(item, 'signal_type', 'general'),
            confidenceLabel: _parseConfidenceLabel(
              _jsonString(item, 'confidence', 'medium'),
            ),
            evidenceItems: const <EvidenceItem>[],
          ),
        )
        .toList(growable: false);
  }

  List<ClarityDimension> _jsonDimensions(
    dynamic source,
    List<ClarityDimension> fallback,
  ) {
    if (source is! List || source.isEmpty) return fallback;
    final List<ClarityDimension> items = source
        .whereType<Map<String, dynamic>>()
        .map(
          (Map<String, dynamic> item) => ClarityDimension(
            title: _jsonString(item, 'title', 'Boyut'),
            state: _parseDimensionState(_jsonString(item, 'state', 'unclear')),
            note: _jsonString(item, 'note', ''),
          ),
        )
        .toList(growable: false);
    return items.isEmpty ? fallback : items;
  }

  Map<String, int> _jsonEvidenceMix(
    dynamic source,
    Map<String, int> fallback,
  ) {
    if (source is! Map) return fallback;
    final Map<String, int> values = <String, int>{};
    source.forEach((dynamic key, dynamic value) {
      if (key != null && value is num) {
        values[key.toString()] = value.toInt();
      }
    });
    return values.isEmpty ? fallback : values;
  }

  String _jsonString(
    Map<String, dynamic> json,
    String key,
    String fallback,
  ) {
    final dynamic value = json[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  List<String> _jsonStringList(
    Map<String, dynamic> json,
    String key,
    List<String> fallback,
  ) {
    final dynamic value = json[key];
    if (value is List) {
      final List<String> items = value
          .map((dynamic item) => item.toString().trim())
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
      if (items.isNotEmpty) return items;
    }
    return fallback;
  }

  List<SensitiveContextMemory> _jsonSensitiveMemories(
    Map<String, dynamic> json,
    String key,
    List<SensitiveContextMemory> fallback,
  ) {
    final dynamic value = json[key];
    if (value is! List || value.isEmpty) return fallback;
    final List<SensitiveContextMemory> items = value
        .map(_jsonMap)
        .whereType<Map<String, dynamic>>()
        .map(
          (Map<String, dynamic> item) => SensitiveContextMemory(
            summary: _jsonString(item, 'summary', ''),
            impact: _jsonString(item, 'impact', ''),
            acknowledgementLine:
                _jsonString(item, 'acknowledgement_line', ''),
            tags: _jsonStringList(item, 'tags', const <String>[]),
          ),
        )
        .where(
          (SensitiveContextMemory item) =>
              item.summary.isNotEmpty &&
              item.impact.isNotEmpty &&
              item.acknowledgementLine.isNotEmpty,
        )
        .toList(growable: false);
    return items.isEmpty ? fallback : items;
  }

  Map<String, dynamic>? _jsonMap(dynamic source) {
    if (source is Map<String, dynamic>) return source;
    if (source is Map) {
      return source.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
    }
    return null;
  }

  ConfidenceLabel _parseConfidenceLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'low':
      case 'dusuk':
        return ConfidenceLabel.low;
      case 'high':
      case 'yuksek':
        return ConfidenceLabel.high;
      default:
        return ConfidenceLabel.medium;
    }
  }

  DimensionState _parseDimensionState(String raw) {
    switch (raw.toLowerCase()) {
      case 'supported':
      case 'destekleniyor':
        return DimensionState.supported;
      case 'mixed':
      case 'karisik':
        return DimensionState.mixed;
      case 'caution':
      case 'dikkat':
        return DimensionState.caution;
      default:
        return DimensionState.unclear;
    }
  }

  String _inferAttachmentStyle(OnboardingProfile profile) {
    if (profile.highAssurance && profile.hasFastAttachment) {
      return 'Kaygili baglanmaya yatkin';
    }
    if (profile.selfProtectionScore > 0.6 && profile.hasFastElimination) {
      return 'Kacinmaya yatkin';
    }
    if (profile.boundaryHealthScore > 0.6 && profile.selfAwarenessScore > 0.6) {
      return 'Daha guvenli baglanmaya yakin';
    }
    return 'Karismik / gecisken baglanma sinyalleri';
  }

  String _buildHash(List<Object?> parts) {
    return Object.hashAll(parts).toUnsigned(32).toRadixString(16);
  }
}
