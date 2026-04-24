// ══════════════════════════════════════════════════════════════
//  Sohbet Tabanlı Onboarding Servisi
//  ──────────────────────────────────
//  Self-hosted LLM ile doğal sohbet yürüterek OnboardingProfile
//  alanlarını dolduran servis. 8 bölümlük form yerine
//  kullanıcıyla akıcı bir diyalog kurar.
//
//  Akış:
//  1. Karşılama mesajı → kullanıcı ismini öğren
//  2. 5-7 açık uçlu sohbet turu → profil alanlarını LLM çıkarsın
//  3. Eksik kritik alanlar için takip soruları
//  4. Onay & tamamlama
// ══════════════════════════════════════════════════════════════

// ignore_for_file: unused_element

import 'package:flutter/foundation.dart';

import '../models.dart';
import 'ai_contracts.dart';
import 'ai_config.dart';
import 'deep_analysis_orchestrator.dart';
import 'gemini_chat_service.dart';
import 'self_hosted_llm_service.dart';

/// Sohbet mesajı modeli
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    this.isTyping = false,
  });

  final String role; // 'assistant' | 'user'
  final String content;
  final bool isTyping;
}

/// Sohbet aşaması
enum ChatPhase {
  greeting,       // İsim öğrenme
  deepDive,       // Ana sohbet turları (5-7 tur)
  beliefs,        // İnanç skalası (kısa)
  confirmation,   // Onay
  complete,       // Tamamlandı
}

/// Çıkarılan profil alanları (kademeli doldurulan)
class ExtractedProfile {
  String displayName = '';
  String selfDescription = '';
  List<String> coreTraits = <String>[];
  String currentLifeTheme = '';
  String datingChallenge = '';
  String freeformAboutMe = '';
  String friendDescription = '';
  String threeExperiences = '';

  RelationshipGoal goal = RelationshipGoal.unsure;
  PacingPreference pacingPreference = PacingPreference.balanced;
  String openingUpTime = '';
  String trustBuilder = '';
  RelationshipExperience relationshipExperience =
      RelationshipExperience.several;
  String recentDatingChallenge = '';
  String idealDay = '';

  List<String> values = <String>[];
  String respectSignal = '';
  List<String> dealbreakers = <String>[];
  List<String> lifestyleFactors = <String>[];
  String potentialVsBehavior = 'Bugünkü davranışı';
  String valueConflict = '';

  CommunicationPreference communicationPreference =
      CommunicationPreference.balancedRegular;
  String showsInterestHow = '';
  String directVsSoft = 'Duruma göre';
  String messagingImportance = '';
  AmbiguityResponse ambiguityResponse = AmbiguityResponse.overthink;
  ConflictStyle conflictStyle = ConflictStyle.talkItOut;
  String unheardFeeling = '';

  List<String> blindSpots = <String>[];
  String recurringPattern = '';
  String feedbackFromCloseOnes = '';
  String biggestMisjudgment = '';
  String judgmentCloudedBy = '';
  String stayedTooLong = '';
  String feelingsChanged = '';

  int beliefRightPersonFindsWay = 4;
  int beliefChemistryFeltFast = 4;
  int beliefStrongAttractionIsSign = 4;
  int beliefFeelsRightOrNot = 4;
  int beliefFirstFeelingsAreTruth = 4;
  int beliefPotentialEqualsValue = 4;
  int beliefAmbiguityIsNormal = 4;
  int beliefLoveOvercomesIssues = 4;

  List<String> alarmTriggers = <String>[];
  String vulnerabilityArea = '';
  AssuranceNeed assuranceNeed = AssuranceNeed.medium;
  String jealousyLevel = 'Orta';
  FatigueResponse fatigueResponse = FatigueResponse.pullAway;
  String boundaryDifficulty = '';
  String safetyExperience = '';

  String attachmentHistory = '';
  String misunderstandingRisk = '';
  String partnerShouldKnowEarly = '';
  String freeformForProfile = '';
  String profileSummaryFeedback = '';

  // Conditional
  String? highAssuranceThought;
  String? idealizationAwareness;
  String? firstRelationshipLearning;
  String? noSecondChanceBehavior;
  String? fastAttachmentDriver;
  String? fastEliminationReason;

  OnboardingProfile toProfile() {
    return OnboardingProfile(
      displayName: displayName,
      selfDescription: selfDescription,
      coreTraits: coreTraits,
      currentLifeTheme: currentLifeTheme,
      datingChallenge: datingChallenge,
      freeformAboutMe: freeformAboutMe,
      friendDescription: friendDescription,
      threeExperiences: threeExperiences,
      goal: goal,
      pacingPreference: pacingPreference,
      openingUpTime: openingUpTime,
      trustBuilder: trustBuilder,
      relationshipExperience: relationshipExperience,
      recentDatingChallenge: recentDatingChallenge,
      idealDay: idealDay,
      values: values,
      respectSignal: respectSignal,
      dealbreakers: dealbreakers,
      lifestyleFactors: lifestyleFactors,
      potentialVsBehavior: potentialVsBehavior,
      valueConflict: valueConflict,
      communicationPreference: communicationPreference,
      showsInterestHow: showsInterestHow,
      directVsSoft: directVsSoft,
      messagingImportance: messagingImportance,
      ambiguityResponse: ambiguityResponse,
      conflictStyle: conflictStyle,
      unheardFeeling: unheardFeeling,
      blindSpots: blindSpots,
      recurringPattern: recurringPattern,
      feedbackFromCloseOnes: feedbackFromCloseOnes,
      biggestMisjudgment: biggestMisjudgment,
      judgmentCloudedBy: judgmentCloudedBy,
      stayedTooLong: stayedTooLong,
      feelingsChanged: feelingsChanged,
      beliefRightPersonFindsWay: beliefRightPersonFindsWay,
      beliefChemistryFeltFast: beliefChemistryFeltFast,
      beliefStrongAttractionIsSign: beliefStrongAttractionIsSign,
      beliefFeelsRightOrNot: beliefFeelsRightOrNot,
      beliefFirstFeelingsAreTruth: beliefFirstFeelingsAreTruth,
      beliefPotentialEqualsValue: beliefPotentialEqualsValue,
      beliefAmbiguityIsNormal: beliefAmbiguityIsNormal,
      beliefLoveOvercomesIssues: beliefLoveOvercomesIssues,
      alarmTriggers: alarmTriggers,
      vulnerabilityArea: vulnerabilityArea,
      assuranceNeed: assuranceNeed,
      jealousyLevel: jealousyLevel,
      fatigueResponse: fatigueResponse,
      boundaryDifficulty: boundaryDifficulty,
      safetyExperience: safetyExperience,
      attachmentHistory: attachmentHistory,
      misunderstandingRisk: misunderstandingRisk,
      partnerShouldKnowEarly: partnerShouldKnowEarly,
      freeformForProfile: freeformForProfile,
      profileSummaryFeedback: profileSummaryFeedback,
      highAssuranceThought: highAssuranceThought,
      idealizationAwareness: idealizationAwareness,
      firstRelationshipLearning: firstRelationshipLearning,
      noSecondChanceBehavior: noSecondChanceBehavior,
      fastAttachmentDriver: fastAttachmentDriver,
      fastEliminationReason: fastEliminationReason,
      ageConfirmed: true,
      policyAccepted: true,
    );
  }
}

/// LLM bağlantı hatası — page tarafı bunu yakalayıp UI gösterecek
class LlmUnavailableException implements Exception {
  const LlmUnavailableException(this.message);
  final String message;
  @override
  String toString() => 'LlmUnavailableException: $message';
}

class ChatOnboardingService {
  ChatOnboardingService._();
  static final ChatOnboardingService instance = ChatOnboardingService._();

  final List<ChatMessage> _history = <ChatMessage>[];
  final ExtractedProfile _extracted = ExtractedProfile();
  final Set<String> _capturedFields = <String>{};
  ChatPhase _phase = ChatPhase.greeting;
  int _turnCount = 0;
  int _consecutiveLlmFailures = 0;

  List<ChatMessage> get history => List<ChatMessage>.unmodifiable(_history);
  ChatPhase get phase => _phase;
  ExtractedProfile get extracted => _extracted;
  bool get isComplete => _phase == ChatPhase.complete;
  int get capturedFieldCount => _capturedFields.length;
  bool get canFinishNow =>
      _phase == ChatPhase.deepDive && _hasEnoughDataForEarlyClose();

  /// LLM kullanılabilir mi? Page tarafı bunu onboarding başlamadan kontrol eder.
  /// Sohbet ve profil çıkarma için önce self-hosted LLM, sonra Gemini kullanılır.
  /// İkisi de yoksa onboarding başlatılamaz.
  bool get isLlmAvailable => AIConfig.instance.isChatLlmAvailable;

  /// Ardışık LLM hata sayısı — page tarafı 3+ olunca uyarı gösterebilir
  int get consecutiveLlmFailures => _consecutiveLlmFailures;

  void applyQuickStartSeed({
    RelationshipGoal? goal,
    PacingPreference? pacingPreference,
    CommunicationPreference? communicationPreference,
    AssuranceNeed? assuranceNeed,
  }) {
    if (goal != null) {
      _extracted.goal = goal;
      _capturedFields.add('goal');
    }
    if (pacingPreference != null) {
      _extracted.pacingPreference = pacingPreference;
      _capturedFields.add('pacingPreference');
    }
    if (communicationPreference != null) {
      _extracted.communicationPreference = communicationPreference;
      _capturedFields.add('communicationPreference');
    }
    if (assuranceNeed != null) {
      _extracted.assuranceNeed = assuranceNeed;
      _capturedFields.add('assuranceNeed');
    }
  }

  Future<ChatMessage?> createQuickStartKickoff() async {
    if (!AIConfig.instance.isChatLlmAvailable) {
      throw const LlmUnavailableException(
        'Self-hosted LLM veya Gemini API anahtarı bulunamadı. Sohbet tabanlı onboarding için en az birinin yapılandırılması gerekli.',
      );
    }

    if (_phase == ChatPhase.greeting) {
      _phase = ChatPhase.deepDive;
      _turnCount = 0;
    }

    final String reply = await _requestAssistantOnlyMessage(
      systemPrompt: _buildQuickStartKickoffSystemPrompt(),
      userMessage:
          'Kullanıcı hızlı başlangıç seçimlerini yaptı. Şimdi ona kısa, doğal ve somut ilk derinleşme sorusunu sor.',
    );
    if (reply.trim().isEmpty) return null;
    return _addAssistant(reply.trim());
  }

  Future<ChatMessage?> requestWrapUp() async {
    if (_phase != ChatPhase.deepDive) return null;
    return _handleDeepDive('analize geç');
  }

  /// İlk karşılama mesajını LLM ile üretir. Yanıt gelmezse null döner.
  Future<ChatMessage?> getGreeting() async {
    if (!AIConfig.instance.isChatLlmAvailable) {
      throw const LlmUnavailableException(
        'Self-hosted LLM veya Gemini API anahtarı bulunamadı. '
        'Sohbet tabanlı onboarding için en az birinin yapılandırılması gerekli.',
      );
    }

    final String reply = await _requestAssistantOnlyMessage(
      systemPrompt: _buildFocusedGreetingSystemPrompt(),
      userMessage:
          'İlk mesajı yaz. Boş küçük sohbet yapma. Ya hitap biçimini sor ya da doğrudan kendini birkaç cümleyle anlatmasını iste.',
    );
    if (reply.trim().isEmpty) return null;
    return _addAssistant(reply.trim());
  }

  /// Kullanıcı mesajını işle ve yanıt üret.
  /// LLM yoksa [LlmUnavailableException] fırlatır.
  Future<ChatMessage?> processUserMessage(String userText) async {
    // Kullanıcı mesajını ekle
    _history.add(ChatMessage(role: 'user', content: userText));

    switch (_phase) {
      case ChatPhase.greeting:
        return _handleGreeting(userText);
      case ChatPhase.deepDive:
        return _handleDeepDive(userText);
      case ChatPhase.beliefs:
        return _handleBeliefs(userText);
      case ChatPhase.confirmation:
        return _handleConfirmation(userText);
      case ChatPhase.complete:
        return null;
    }
  }

  void reset() {
    _history.clear();
    _capturedFields.clear();
    _phase = ChatPhase.greeting;
    _turnCount = 0;
    _consecutiveLlmFailures = 0;
    final ExtractedProfile fresh = ExtractedProfile();
    _extracted.displayName = fresh.displayName;
    _extracted.selfDescription = fresh.selfDescription;
    _extracted.coreTraits = fresh.coreTraits;
    _extracted.currentLifeTheme = fresh.currentLifeTheme;
    _extracted.datingChallenge = fresh.datingChallenge;
    _extracted.freeformAboutMe = fresh.freeformAboutMe;
    _extracted.friendDescription = fresh.friendDescription;
    _extracted.threeExperiences = fresh.threeExperiences;
    _extracted.goal = fresh.goal;
    _extracted.pacingPreference = fresh.pacingPreference;
    _extracted.openingUpTime = fresh.openingUpTime;
    _extracted.trustBuilder = fresh.trustBuilder;
    _extracted.relationshipExperience = fresh.relationshipExperience;
    _extracted.recentDatingChallenge = fresh.recentDatingChallenge;
    _extracted.idealDay = fresh.idealDay;
    _extracted.values = fresh.values;
    _extracted.respectSignal = fresh.respectSignal;
    _extracted.blindSpots = fresh.blindSpots;
    _extracted.dealbreakers = fresh.dealbreakers;
    _extracted.lifestyleFactors = fresh.lifestyleFactors;
    _extracted.potentialVsBehavior = fresh.potentialVsBehavior;
    _extracted.valueConflict = fresh.valueConflict;
    _extracted.communicationPreference = fresh.communicationPreference;
    _extracted.showsInterestHow = fresh.showsInterestHow;
    _extracted.directVsSoft = fresh.directVsSoft;
    _extracted.messagingImportance = fresh.messagingImportance;
    _extracted.ambiguityResponse = fresh.ambiguityResponse;
    _extracted.conflictStyle = fresh.conflictStyle;
    _extracted.unheardFeeling = fresh.unheardFeeling;
    _extracted.recurringPattern = fresh.recurringPattern;
    _extracted.feedbackFromCloseOnes = fresh.feedbackFromCloseOnes;
    _extracted.biggestMisjudgment = fresh.biggestMisjudgment;
    _extracted.judgmentCloudedBy = fresh.judgmentCloudedBy;
    _extracted.stayedTooLong = fresh.stayedTooLong;
    _extracted.feelingsChanged = fresh.feelingsChanged;
    _extracted.beliefRightPersonFindsWay = fresh.beliefRightPersonFindsWay;
    _extracted.beliefChemistryFeltFast = fresh.beliefChemistryFeltFast;
    _extracted.beliefStrongAttractionIsSign = fresh.beliefStrongAttractionIsSign;
    _extracted.beliefFeelsRightOrNot = fresh.beliefFeelsRightOrNot;
    _extracted.beliefFirstFeelingsAreTruth = fresh.beliefFirstFeelingsAreTruth;
    _extracted.beliefPotentialEqualsValue = fresh.beliefPotentialEqualsValue;
    _extracted.beliefAmbiguityIsNormal = fresh.beliefAmbiguityIsNormal;
    _extracted.beliefLoveOvercomesIssues = fresh.beliefLoveOvercomesIssues;
    _extracted.alarmTriggers = fresh.alarmTriggers;
    _extracted.vulnerabilityArea = fresh.vulnerabilityArea;
    _extracted.assuranceNeed = fresh.assuranceNeed;
    _extracted.jealousyLevel = fresh.jealousyLevel;
    _extracted.fatigueResponse = fresh.fatigueResponse;
    _extracted.boundaryDifficulty = fresh.boundaryDifficulty;
    _extracted.safetyExperience = fresh.safetyExperience;
    _extracted.attachmentHistory = fresh.attachmentHistory;
    _extracted.misunderstandingRisk = fresh.misunderstandingRisk;
    _extracted.partnerShouldKnowEarly = fresh.partnerShouldKnowEarly;
    _extracted.freeformForProfile = fresh.freeformForProfile;
    _extracted.profileSummaryFeedback = fresh.profileSummaryFeedback;
    _extracted.highAssuranceThought = fresh.highAssuranceThought;
    _extracted.idealizationAwareness = fresh.idealizationAwareness;
    _extracted.firstRelationshipLearning = fresh.firstRelationshipLearning;
    _extracted.noSecondChanceBehavior = fresh.noSecondChanceBehavior;
    _extracted.fastAttachmentDriver = fresh.fastAttachmentDriver;
    _extracted.fastEliminationReason = fresh.fastEliminationReason;
  }

  // ══════════════════════════════════════════════
  //  Faz İşleyicileri
  // ══════════════════════════════════════════════

  Future<ChatMessage?> _handleGreeting(String userText) async {
    if (!AIConfig.instance.isChatLlmAvailable) {
      throw const LlmUnavailableException(
        'Self-hosted LLM veya Gemini API anahtarı bulunamadı. '
        'Sohbet tabanlı onboarding için en az birinin yapılandırılması gerekli.',
      );
    }

    final String guessedName = _extractDisplayNameFallback(userText);
    if (guessedName.isNotEmpty) {
      _extracted.displayName = guessedName;
    }

    _phase = ChatPhase.deepDive;
    _turnCount = 0;
    final String reply = await _requestAssistantOnlyMessage(
      systemPrompt: _buildFocusedPostNameSystemPrompt(
        hasName: guessedName.isNotEmpty,
        displayName: guessedName,
      ),
      userMessage:
          'Kullanıcı az önce ya adını söyledi ya da adını paylaşmak istemedi. Şimdi ilk gerçek profil sorusunu sor.',
    );
    if (reply.trim().isEmpty) return null;
    return _addAssistant(reply.trim());
  }

  Future<ChatMessage?> _handleDeepDive(String userText) async {
    _turnCount++;

    if (!AIConfig.instance.isChatLlmAvailable) {
      throw const LlmUnavailableException(
        'Self-hosted LLM veya Gemini API anahtarı bulunamadı. '
        'Sohbet tabanlı onboarding için en az birinin yapılandırılması gerekli.',
      );
    }

    return _llmDrivenTurn(userText);
  }

  Future<ChatMessage?> _handleBeliefs(String userText) async {
    if (!AIConfig.instance.isChatLlmAvailable) {
      throw const LlmUnavailableException(
        'Self-hosted LLM veya Gemini API anahtarı bulunamadı. İnanç analizi için LLM gerekli.',
      );
    }

    try {
      final envelope = await DeepAnalysisOrchestrator.instance.extractBeliefScores(
        systemPrompt: _buildFocusedBeliefExtractionPrompt(),
        userMessage: userText,
      );
      _applyBeliefs(envelope.payload);
    } catch (e) {
      debugPrint('İnanç çıkarma hatası: $e');
      // İnanç çıkaramadıysak varsayılan skorlarla devam et — kritik değil
    }
    _phase = ChatPhase.complete;
    final String reply = await _requestAssistantOnlyMessage(
      systemPrompt: _buildFocusedCompletionSystemPrompt(),
      userMessage:
          'Kullanici son inanc sorusunu yanitladi. Kisa sekilde profil taslagini hazirladigini soyle. Yasal onay isteme; uygulama bunu ayri ekranda alacak.',
    );
    if (reply.trim().isEmpty) return null;
    return _addAssistant(reply.trim());
  }

  Future<ChatMessage?> _handleConfirmation(String userText) async {
    final String lower = userText.trim().toLowerCase();
    if (lower.contains('evet') ||
        lower.contains('onay') ||
        lower.contains('tamam') ||
        lower.contains('kabul') ||
        lower == 'e') {
      _phase = ChatPhase.complete;
      final String reply = await _requestAssistantOnlyMessage(
        systemPrompt: _buildFocusedCompletionSystemPrompt(),
        userMessage:
            'Kullanici onay verdi. Cok kisa bir sekilde kaydetmeye gectigini soyle.',
      );
      if (reply.trim().isEmpty) return null;
      return _addAssistant(reply.trim());
    }
    final String reply = await _requestAssistantOnlyMessage(
      systemPrompt: _buildFocusedConfirmationSystemPrompt(),
      userMessage:
          'Kullanici net bir onay vermedi. Ayni seyi tekrar etmeden, kisa ve nazik bir sekilde onay iste.',
    );
    if (reply.trim().isEmpty) return null;
    return _addAssistant(reply.trim());
  }

  // ══════════════════════════════════════════════
  //  LLM Tabanlı Sohbet Turu
  // ══════════════════════════════════════════════

  /// Tek LLM turu — retry mekanizmalı, fallback yok.
  /// Her türlü kullanıcı mesajını (anlamadım, alakasız, kısa, uzun)
  /// LLM'e gönderir — LLM doğal sohbette her şeyi yönetir.
  Future<ChatMessage?> _llmDrivenTurn(String userText) async {
    const int maxRetries = 2;
    Exception? lastError;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final StringBuffer conversationSoFar = StringBuffer();
        final List<ChatMessage> recent = _history.length > 12
            ? _history.sublist(_history.length - 12)
            : _history;
        for (final ChatMessage msg in recent) {
          final String role = msg.role == 'assistant' ? 'Sırdaş' : 'Kullanıcı';
          conversationSoFar.writeln('$role: ${msg.content}');
          conversationSoFar.writeln();
        }

        final List<String> missingFields = _getMissingFields();
        final List<String> filledFields = _getFilledFields();
        final envelope = await DeepAnalysisOrchestrator.instance.runChatOnboardingTurn(
          systemPrompt: _buildFocusedChatTurnSystemPrompt(
            missingFields: missingFields,
            filledFields: filledFields,
          ),
          userMessage: _buildFocusedChatTurnUserPayload(
            conversationSoFar: conversationSoFar.toString(),
            latestUserMessage: userText,
          ),
          fallbackReply: '',
        );

        if (envelope.payload.extractedFields.isNotEmpty) {
          _applyExtracted(envelope.payload.extractedFields);
        }

        if (_isWrapIntent(userText)) {
          _consecutiveLlmFailures = 0;
          if (_hasEnoughData() || _hasEnoughDataForEarlyClose()) {
            _phase = ChatPhase.beliefs;
            final String reply = await _requestAssistantOnlyMessage(
              systemPrompt: _buildFocusedBeliefTransitionSystemPrompt(),
              userMessage:
                  'Kullanici sohbeti bitirmek istiyor ve profil icin yeterli veri toplandi. Simdi ask ve sezgi inancini acan kisa, dogal, tek soruluk son bir gecis sor.',
            );
            if (reply.trim().isEmpty) return null;
            return _addAssistant(reply.trim());
          }

          final String reply = await _requestAssistantOnlyMessage(
            systemPrompt: _buildFocusedClosingGapSystemPrompt(
              missingFields: missingFields,
            ),
            userMessage:
                'Kullanici sohbeti kapatmak istiyor ama profil henuz eksik. Kapanisi saygiyla kabul et ve sadece tek bir en kritik soruyu sor.',
          );
          if (reply.trim().isEmpty) return null;
          return _addAssistant(reply.trim());
        }

        // 2) Yeterli bilgi toplandıysa inanç aşamasına geç
        //    Minimum 10 tur + tüm kritik alanlar dolu olmalı
        if ((_turnCount >= 5 && _hasEnoughDataForEarlyClose()) ||
            (_turnCount >= 7 && _hasEnoughData())) {
          _consecutiveLlmFailures = 0;
          _phase = ChatPhase.beliefs;
          final String reply = await _requestAssistantOnlyMessage(
            systemPrompt: _buildFocusedBeliefTransitionSystemPrompt(),
            userMessage:
                'Kullaniciyla ana profil toplama turu tamamlandi. Simdi ask ve sezgi inancini acan kisa, dogal, tek soruluk bir gecis sor.',
          );
          if (reply.trim().isEmpty) return null;
          return _addAssistant(reply.trim());
        }

        final String nextQuestion = envelope.payload.reply.trim();
        _consecutiveLlmFailures = 0;
        if (nextQuestion.isEmpty) return null;
        return _addAssistant(nextQuestion);
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint('LLM sohbet hatası (deneme ${attempt + 1}/$maxRetries): $e');
        // Son denemeden sonra fırlatacağız
        if (attempt < maxRetries - 1) {
          // Kısa bir bekleme sonra tekrar dene
          await Future<void>.delayed(const Duration(milliseconds: 800));
        }
      }
    }

    // Tüm denemeler başarısız
    _consecutiveLlmFailures++;
    debugPrint('LLM tümüyle başarısız. Ardışık hata: $_consecutiveLlmFailures');

    // 3 ardışık hatadan sonra page tarafı uyarı gösterir
    if (_consecutiveLlmFailures >= 3) {
      throw LlmUnavailableException(
        'LLM yanıt vermiyor. Lütfen internet bağlantını ve API anahtarını kontrol et. '
        'Hata: $lastError',
      );
    }

    return null;
  }

  Future<String> _requestAssistantOnlyMessage({
    required String systemPrompt,
    required String userMessage,
  }) async {
    if (AIConfig.instance.hasSelfHostedLlm) {
      try {
        return (await SelfHostedLlmService.instance.completeText(
          systemPrompt: systemPrompt,
          userMessage: userMessage,
          task: 'assistant_reply',
        ))
            .trim();
      } catch (e) {
        debugPrint('Assistant-only self-hosted hatasi, Gemini deneniyor: $e');
      }
    }

    if (AIConfig.instance.hasGemini) {
      try {
        return (await GeminiChatService.instance.generateReply(
          systemPrompt: systemPrompt,
          userMessage: userMessage,
        ))
            .trim();
      } catch (e) {
        debugPrint('Assistant-only Gemini hatasi: $e');
      }
    }

    throw const LlmUnavailableException(
      'Assistant-only cevap uretilemedi. LLM baglantisi su an kullanilamiyor.',
    );
  }

  String _buildGreetingSystemPrompt() {
    return '''
Sen "Sirdas"sin. Turkceyi dogal, akici ve sicak kullan.

KURALLAR:
- En fazla 2 cumle yaz.
- Kendini kisaca tanit.
- Karsindaki kisiye guven veren ama yapay durmayan bir acilis yap.
- Sadece tek soru sor.
- "Kendini nasil tanimlarim?" gibi bozuk veya ceviri kokan ifadeler kullanma.
- "Ismini paylasmak istemezsen sorun degil" gibi erken savunma cümlesi kurma; simdilik sadece acilis yap.
''';
  }

  String _buildBeliefTransitionSystemPrompt() {
    return '''
Sen "Sirdas"sin. Turkceyi dogal, kisa ve temiz kullan.

KURALLAR:
- En fazla 2 cumle yaz.
- Profil toplama kismindan inanc/sezgi sorusuna zarif bir gecis yap.
- Tek soru sor.
- Yapay ceviri dili kullanma.
- Asiri samimi veya laubali olma.
''';
  }

  String _buildConfirmationSystemPrompt() {
    return '''
Sen "Sirdas"sin. Turkceyi dogal, nazik ve kisa kullan.

KURALLAR:
- En fazla 2 cumle yaz.
- Tek soru sor veya tek bir onay cümlesi yaz.
- Hukuki/onay metnini robot gibi degil, insan gibi ifade et.
- "onayliyosun di mi" gibi gevsek dil kullanma.
''';
  }

  String _buildCompletionSystemPrompt() {
    return '''
Sen "Sirdas"sin. Turkceyi kisa, guven veren ve dogal kullan.

KURALLAR:
- Tek cumle yaz.
- Kullanicinin onay verdigini anla ve kaydetmeye gectigini kisaca soyle.
- Kutlama tonu olabilir ama asiriya kacma.
''';
  }

  String _buildClosingGapSystemPrompt({
    required List<String> missingFields,
  }) {
    return '''
Sen "Sirdas"sin. Turkceyi dogal, kisa ve nazik kullan.

KURALLAR:
- Kullanici sohbeti kapatmak istedigini hissettiriyor.
- Bunu kabul et ama profili saglam kapatmak icin sadece tek bir en kritik soruyu sor.
- En fazla 2 cumle yaz.
- "Baska bir sey var mi?" gibi bos kapanis sorulari sorma.
- Eksik alanlardan en yuksek degerli olani sec.

EKSIK ALANLAR:
${missingFields.isEmpty ? 'yok' : missingFields.join('\n')}
''';
  }

  String _buildChatTurnSystemPrompt({
    required List<String> missingFields,
    required List<String> filledFields,
  }) {
    return '''
Sen "Sırdaş"sın. Samimi, kısa, güven veren ama laubali olmayan bir Türkçe ile konuş.

GÖREV:
Tek bir JSON döndür. Aynı cevap içinde hem kullanıcının mesajından profil alanlarını çıkar hem de doğal bir sonraki sohbet mesajını üret.

KONUŞMA KURALLARI:
- assistant_reply en fazla 2 cümle olsun.
- Tek bir ana soru sor.
- "kanka", "ya", "valla", "canım", "tatlım" gibi aşırı gündelik hitaplar kullanma.
- Önce kısa bir karşılık ver, sonra tek bir soru sor.
- Kullanıcının daha önce söylediğini tekrar sorma; gerekiyorsa farklı açıdan yaklaş.
- Mahrem bir bağlam fark edersen bunu dramatikleştirme ama gerçekten gördüğünü hissettir.

PROFİL ÇIKARMA KURALLARI:
- Sadece kullanıcının yazdığı mesajda net olan alanları doldur.
- Tahmin yapma.
- Bulamadığın alanları ekleme.
- extracted_fields içinde sadece bu turda gerçekten yakaladığın alanlar olsun.

TOPLANAN: ${filledFields.isEmpty ? 'henüz yok' : filledFields.join(', ')}
EKSİK: ${missingFields.isEmpty ? 'tamam' : missingFields.join(', ')}

JSON FORMATI:
{
  "assistant_reply": "Kisa dogal yanit + tek soru",
  "acknowledged_sensitive_context": true,
  "extracted_fields": {
    "displayName": "varsa",
    "selfDescription": "varsa",
    "friendDescription": "varsa",
    "threeExperiences": "varsa",
    "currentLifeTheme": "varsa",
    "datingChallenge": "varsa",
    "freeformAboutMe": "varsa",
    "goal": "serious|openExplore|slowBond|shortTerm|unsure",
    "pacingPreference": "slow|balanced|fastButClear",
    "relationshipExperience": "first|few|several|extensive",
    "idealDay": "varsa",
    "communicationPreference": "frequentContact|balancedRegular|spaceGiving|deepConversation|lightFun",
    "conflictStyle": "talkItOut|coolDownFirst|shutDown|distance|overEngage|appease",
    "ambiguityResponse": "wait|ask|withdraw|overthink|testInterest|assumeAndDecide",
    "fatigueResponse": "seekCloseness|pullAway|test|goSilent|overAnalyze",
    "assuranceNeed": "low|medium|high",
    "vulnerabilityArea": "varsa",
    "coreTraits": ["Ozellik 1"],
    "values": ["Deger 1"],
    "blindSpots": ["Kor nokta 1"],
    "dealbreakers": ["sinir 1"],
    "lifestyleFactors": ["uyum basligi 1"],
    "alarmTriggers": ["alarm 1"],
    "recurringPattern": "varsa",
    "feedbackFromCloseOnes": "varsa",
    "biggestMisjudgment": "varsa",
    "trustBuilder": "varsa",
    "openingUpTime": "varsa",
    "recentDatingChallenge": "varsa",
    "showsInterestHow": "varsa",
    "directVsSoft": "Doğrudan ve net|Yumuşak ve dolaylı|Duruma göre",
    "boundaryDifficulty": "varsa",
    "attachmentHistory": "varsa",
    "stayedTooLong": "varsa",
    "jealousyLevel": "Düşük|Orta|Yüksek",
    "respectSignal": "varsa",
    "valueConflict": "varsa",
    "unheardFeeling": "varsa",
    "feelingsChanged": "varsa",
    "messagingImportance": "varsa",
    "misunderstandingRisk": "varsa",
    "partnerShouldKnowEarly": "varsa",
    "potentialVsBehavior": "varsa",
    "safetyExperience": "varsa",
    "judgmentCloudedBy": "varsa",
    "freeformForProfile": "varsa",
    "profileSummaryFeedback": "varsa",
    "highAssuranceThought": "varsa",
    "idealizationAwareness": "varsa",
    "firstRelationshipLearning": "varsa",
    "noSecondChanceBehavior": "varsa",
    "fastAttachmentDriver": "varsa",
    "fastEliminationReason": "varsa"
  }
}
''';
  }

  String _buildChatTurnUserPayload({
    required String conversationSoFar,
    required String latestUserMessage,
  }) {
    return 'Şimdiye kadarki sohbet:\n$conversationSoFar\n'
        'Son kullanıcı mesajı:\n$latestUserMessage';
  }

  /// JSON'dan çıkarılan alanları uygula (boş olmayanları)
  String _buildFocusedGreetingSystemPrompt() {
    return '''
Sen "Sırdaş"sın. Doğal, temiz ve güncel Türkçe kullan.

AMAÇ:
- İlk mesajdan itibaren profil toplamaya başla.
- Boş küçük sohbet yapma.

KURALLAR:
- En fazla 2 kısa cümle yaz.
- İlk cümlede kendini kısaca tanıt.
- İkinci cümlede tek bir soru sor.
- İlk soru profile giriş açsın.
- "Bugün nasılsın?" diye sorma.
- "Sohbet etmekten memnuniyet duyarım", "Kendini nasıl tanımlarım?" gibi yapay kalıplar kullanma.
- Güven veren ama resmi durmayan bir ton kullan.

İYİ ÖRNEKLER:
- "Merhaba, ben Sırdaş. Sana nasıl hitap etmemi istersin?"
- "Merhaba, ben Sırdaş. Seni biraz tanımam için kendini birkaç cümleyle anlatır mısın?"
''';
  }

  String _buildFocusedPostNameSystemPrompt({
    required bool hasName,
    required String displayName,
  }) {
    final String addressee =
        hasName && displayName.trim().isNotEmpty ? '$displayName,' : '';
    return '''
Sen "Sırdaş"sın. Doğal, temiz ve güncel Türkçe kullan.

AMAÇ:
- Kullanıcı adını verdi ya da vermek istemedi.
- Şimdi ilk gerçek profil sorusunu sor.
- Hedef: kendini anlatma + temel özellikler + ilişki tarafında zorlandığı şey.

KURALLAR:
- En fazla 2 kısa cümle yaz.
- İstersen adı bir kez kullanabilirsin: "$addressee"
- Tek soru sor.
- Soyut ve çeviri kokan kalıplar kullanma.
- "Kendini nasıl biri olarak tanımlarım?", "Kendini en çok hangi özellikle tanımlarım?" gibi bozuk ifadeleri kullanma.
- Soruyu kolay cevaplanır yap.
- Boş nezaket cümlesi ekleme.

İYİ ÖRNEKLER:
- "$addressee seni biraz tanımam için kendini birkaç cümleyle anlatır mısın?"
- "$addressee ilişkilerde seni en çok zorlayan şey ne oluyor?"
- "$addressee seni tanıyan biri senin için ilk ne der?"
''';
  }

  String _buildFocusedBeliefTransitionSystemPrompt() {
    return '''
Sen "Sırdaş"sın. Doğal, kısa ve net Türkçe kullan.

AMAÇ:
- Profil sohbetini uzatmadan tek bir yüksek verimli inanç sorusuna geç.

KURALLAR:
- En fazla 2 kısa cümle yaz.
- Kısa bir köprü kur ve tek soru sor.
- Soru; güçlü çekim, ilk his, belirsizlik ve potansiyeli nasıl okuduğunu açsın.
- Yapay ya da akademik dil kullanma.
- Aşırı samimi veya laubali olma.
''';
  }

  String _buildQuickStartKickoffSystemPrompt() {
    final List<String> seeded = <String>[
      if (_hasField('goal')) 'hedef: ${_extracted.goal.label}',
      if (_hasField('pacingPreference'))
        'tempo: ${_extracted.pacingPreference.label}',
      if (_hasField('communicationPreference'))
        'iletisim: ${_extracted.communicationPreference.label}',
      if (_hasField('assuranceNeed'))
        'guvence: ${_extracted.assuranceNeed.label}',
    ];

    return '''
Sen "Sırdaş"sın. Doğal, kısa ve mobil uygulamaya uygun Türkçe kullan.

BAĞLAM:
- Kullanıcı hızlı başlangıç seçimlerini yaptı.
- Toplanan ilk sinyaller: ${seeded.isEmpty ? 'henüz yok' : seeded.join(', ')}

AMAÇ:
- İlk yazma yükünü azalt.
- Kullanıcıyı sıkmadan ilk derin bilgiyi al.
- Tek soruda intro veya blind spot tarafını aç.

KURALLAR:
- En fazla 2 kısa cümle yaz.
- Tek soru sor.
- Soru somut olsun.
- "Kendini nasıl biri olarak tanımlarım?" gibi bozuk kalıplar kullanma.
- Mümkünse seçilen ayarlardan doğal bir köprü kur.

İYİ ÖRNEKLER:
- "Bunu gördüm. İlişkilerde seni en çok ne yoruyor?"
- "Tamam, bunu not aldım. Sana iyi gelen ilişki nasıl bir şey?"
- "Bunu anladım. Sende sık tekrar eden şey ne oluyor?"
''';
  }

  String _buildFocusedConfirmationSystemPrompt() {
    return '''
Sen "Sırdaş"sın. Doğal, kısa ve sakin Türkçe kullan.

AMAÇ:
- Onboarding'i tek soruda kapat.

KURALLAR:
- Tercihen tek cümle yaz; en fazla 2 cümle.
- Profil taslaginin review ekraninda onaylanacagini soyle.
- Yasal onay isteme; uygulama bunu ayri checkbox'larla alacak.
- Bürokratik ya da robotik dil kullanma.
- "onaylıyosun di mi" gibi gevşek dil kullanma.
''';
  }

  String _buildFocusedCompletionSystemPrompt() {
    return '''
Sen "Sırdaş"sın. Kısa, güven veren ve doğal Türkçe kullan.

KURALLAR:
- Tek cümle yaz.
- Profili kaydetmeye ve analize geçtiğini somut şekilde söyle.
- Aşırı kutlama yapma.
''';
  }

  String _buildFocusedClosingGapSystemPrompt({
    required List<String> missingFields,
  }) {
    return '''
Sen "Sırdaş"sın. Doğal, kısa ve saygılı Türkçe kullan.

AMAÇ:
- Kullanıcı sıkılmış ya da bitirmek istiyor olabilir.
- Onu tutma; profili sağlam kapatmak için yalnızca tek kritik soru sor.

KURALLAR:
- En fazla 2 kısa cümle yaz.
- Kapanış isteğini kabul et.
- Sadece tek bir yüksek değerli soru sor.
- "Başka bir şey var mı?" gibi boş sorular sorma.
- Eksik alan listesinin ilk yüksek değerli maddesine öncelik ver.
- Soyut ifadeleri günlük Türkçeye çevir.

EKSİK ALANLAR:
${missingFields.isEmpty ? 'yok' : missingFields.join('\n')}
''';
  }

  String _buildFocusedChatTurnSystemPrompt({
    required List<String> missingFields,
    required List<String> filledFields,
  }) {
    return '''
Sen "Sırdaş"sın. Kısa, doğal, güven veren ama laubali olmayan bir Türkçe ile konuş.

AMAÇ:
- Bu sohbetin tek amacı onboarding profili çıkarmak.
- Her turda eksik alanlardan sadece bir ana hedef seç.
- Kullanıcıyı yormadan yüksek değerli veri topla.

KONUŞMA KURALLARI:
- assistant_reply en fazla 2 kısa cümle olsun.
- Tek bir ana soru sor.
- Boş küçük sohbet yapma.
- "Bugün nasılsın?", "Sohbet etmekten memnuniyet duyarım", "Kendini nasıl tanımlarım?", "Başka bir konu var mı?" gibi kalıpları kullanma.
- "Kendini nasıl biri olarak tanımlarım?", "Kendini en çok hangi özellikle tanımlarım?", "Senin adına nasıl tarif ederim?" gibi bozuk/çeviri kokan sorular kullanma.
- "kanka", "ya", "valla", "canım", "tatlım" gibi aşırı gündelik hitaplar kullanma.
- Önce kısa bir karşılık ver, sonra tek bir soru sor.
- Kullanıcı kısa cevap verdiyse daha somut ve kolay cevaplanır bir soru sor.
- Kullanıcı uzun ya da mahrem bir şey anlattıysa bunu gerçekten gördüğünü hissettir ama dramatikleştirme.
- Daha önce sorduğun aynı şeyi aynen tekrar sorma; gerekiyorsa farklı açıdan sor.
- Aynı cümle kalıbını üst üste kullanma.

HEDEFLEME KURALLARI:
- EKSİK listesinin sırası önemlidir; normalde en üstteki maddeyi hedefle.
- İlk turlarda öncelik: kendini anlatma, temel özellikler, ilişki zorluğu, ilişki niyeti, güven.
- Orta turlarda öncelik: değerler, sınırlar, iletişim, belirsizlik, çatışma.
- Son turlarda öncelik: kör noktalar, tekrar eden döngü, hassas alanlar, geçmiş etkisi, partnerin erken bilmesi gereken şey.
- Kullanıcının son mesajı doğal olarak birden çok alanı dolduruyorsa extracted_fields içinde hepsini çıkar.
- Eksik alan soyutsa, günlük dile çevirerek sor.

DİL KURALLARI:
- Kolay Türkçe kullan.
- "yaşam ritmi" yerine "günlük düzen", "aile değerleri" yerine "aileyle ilişkin" gibi daha anlaşılır ifadeler seç.
- Sorular kısa olsun; mümkünse 6-14 kelime aralığında kal.

İYİ SORU ÖRNEKLERİ:
- "İlişkilerde seni en çok ne yoruyor?"
- "Birine güvenmen için sende ne oluşması gerekiyor?"
- "Sende sık tekrar eden şey ne oluyor?"
- "Bir anlaşmazlıkta ilk yaptığın şey ne?"
- "Sınır koymak senin için kolay mı?"
- "Seni tanıyan biri en başta neyi bilmeli?"

PROFİL ÇIKARMA KURALLARI:
- Sadece kullanıcının son mesajında net olan alanları doldur.
- Tahmin yapma.
- Bulamadığın alanı ekleme.
- extracted_fields içinde sadece bu turda gerçekten yakaladığın alanlar olsun.

TOPLANAN: ${filledFields.isEmpty ? 'henüz yok' : filledFields.join(', ')}
EKSİK: ${missingFields.isEmpty ? 'tamam' : missingFields.join(', ')}

JSON FORMATI:
{
  "assistant_reply": "Kisa dogal yanit + tek soru",
  "acknowledged_sensitive_context": true,
  "extracted_fields": {
    "displayName": "varsa",
    "selfDescription": "varsa",
    "friendDescription": "varsa",
    "threeExperiences": "varsa",
    "currentLifeTheme": "varsa",
    "datingChallenge": "varsa",
    "freeformAboutMe": "varsa",
    "goal": "serious|openExplore|slowBond|shortTerm|unsure",
    "pacingPreference": "slow|balanced|fastButClear",
    "relationshipExperience": "first|few|several|extensive",
    "idealDay": "varsa",
    "communicationPreference": "frequentContact|balancedRegular|spaceGiving|deepConversation|lightFun",
    "conflictStyle": "talkItOut|coolDownFirst|shutDown|distance|overEngage|appease",
    "ambiguityResponse": "wait|ask|withdraw|overthink|testInterest|assumeAndDecide",
    "fatigueResponse": "seekCloseness|pullAway|test|goSilent|overAnalyze",
    "assuranceNeed": "low|medium|high",
    "vulnerabilityArea": "varsa",
    "coreTraits": ["Ozellik 1"],
    "values": ["Deger 1"],
    "blindSpots": ["Kor nokta 1"],
    "dealbreakers": ["sinir 1"],
    "lifestyleFactors": ["uyum basligi 1"],
    "alarmTriggers": ["alarm 1"],
    "recurringPattern": "varsa",
    "feedbackFromCloseOnes": "varsa",
    "biggestMisjudgment": "varsa",
    "trustBuilder": "varsa",
    "openingUpTime": "varsa",
    "recentDatingChallenge": "varsa",
    "showsInterestHow": "varsa",
    "directVsSoft": "Doğrudan ve net|Yumuşak ve dolaylı|Duruma göre",
    "boundaryDifficulty": "varsa",
    "attachmentHistory": "varsa",
    "stayedTooLong": "varsa",
    "jealousyLevel": "Düşük|Orta|Yüksek",
    "respectSignal": "varsa",
    "valueConflict": "varsa",
    "unheardFeeling": "varsa",
    "feelingsChanged": "varsa",
    "messagingImportance": "varsa",
    "misunderstandingRisk": "varsa",
    "partnerShouldKnowEarly": "varsa",
    "potentialVsBehavior": "varsa",
    "safetyExperience": "varsa",
    "judgmentCloudedBy": "varsa",
    "freeformForProfile": "varsa",
    "profileSummaryFeedback": "varsa",
    "highAssuranceThought": "varsa",
    "idealizationAwareness": "varsa",
    "firstRelationshipLearning": "varsa",
    "noSecondChanceBehavior": "varsa",
    "fastAttachmentDriver": "varsa",
    "fastEliminationReason": "varsa"
  }
}
''';
  }

  String _buildFocusedChatTurnUserPayload({
    required String conversationSoFar,
    required String latestUserMessage,
  }) {
    return 'Şimdiye kadarki sohbet:\n$conversationSoFar\n\n'
        'Son kullanıcı mesajı:\n$latestUserMessage\n\n'
        'Yeni soruda boş sohbet yapma; eksik listedeki en değerli bilgiyi hedefle.';
  }

  String _buildFocusedBeliefExtractionPrompt() {
    return '''
Kullanıcının aşk ve ilişki inançlarıyla ilgili serbest yanıtını oku.
Bu tek mesajdan aşağıdaki 8 inanç boyutunu 1-7 arasında puanla.
1 = hiç katılmıyor, 7 = tamamen katılıyor.
Sadece metinde dayanağı olan çıkarımı yap. Emin değilsen 4 ver.
Belirsizlik, güçlü çekim, ilk his, potansiyel ve sevginin sorunları aşıp aşamayacağı temalarını ayrı ayrı değerlendir.

Sadece JSON döndür:
{
  "beliefRightPersonFindsWay": 4,
  "beliefChemistryFeltFast": 4,
  "beliefStrongAttractionIsSign": 4,
  "beliefFeelsRightOrNot": 4,
  "beliefFirstFeelingsAreTruth": 4,
  "beliefPotentialEqualsValue": 4,
  "beliefAmbiguityIsNormal": 4,
  "beliefLoveOvercomesIssues": 4
}
''';
  }

  void _applyExtracted(Map<String, dynamic> json) {
    void setIfPresent(String key, void Function(String val) setter) {
      final dynamic val = json[key];
      if (val is String && val.trim().isNotEmpty) {
        setter(val.trim());
        _capturedFields.add(key);
      }
    }

    void setListIfPresent(
        String key, void Function(List<String> val) setter) {
      final dynamic val = json[key];
      if (val is List && val.isNotEmpty) {
        final List<String> items = val
            .map((dynamic v) => v.toString().trim())
            .where((String item) => item.isNotEmpty)
            .toList(growable: false);
        if (items.isNotEmpty) {
          setter(items);
          _capturedFields.add(key);
        }
      }
    }

    setIfPresent('displayName', (String v) => _extracted.displayName = v);
    setIfPresent(
        'selfDescription', (String v) => _extracted.selfDescription = v);
    setIfPresent(
        'datingChallenge', (String v) => _extracted.datingChallenge = v);
    setIfPresent(
        'freeformAboutMe', (String v) => _extracted.freeformAboutMe = v);
    setIfPresent('recurringPattern',
        (String v) => _extracted.recurringPattern = v);
    setIfPresent('feedbackFromCloseOnes',
        (String v) => _extracted.feedbackFromCloseOnes = v);
    setIfPresent('biggestMisjudgment',
        (String v) => _extracted.biggestMisjudgment = v);
    setIfPresent('trustBuilder', (String v) => _extracted.trustBuilder = v);
    setIfPresent(
        'openingUpTime', (String v) => _extracted.openingUpTime = v);
    setIfPresent('recentDatingChallenge',
        (String v) => _extracted.recentDatingChallenge = v);
    setIfPresent(
        'showsInterestHow', (String v) => _extracted.showsInterestHow = v);
    setIfPresent('directVsSoft', (String v) => _extracted.directVsSoft = v);
    setIfPresent('boundaryDifficulty',
        (String v) => _extracted.boundaryDifficulty = v);
    setIfPresent('attachmentHistory',
        (String v) => _extracted.attachmentHistory = v);
    setIfPresent(
        'stayedTooLong', (String v) => _extracted.stayedTooLong = v);
    setIfPresent('vulnerabilityArea',
        (String v) => _extracted.vulnerabilityArea = v);
    setIfPresent(
        'currentLifeTheme', (String v) => _extracted.currentLifeTheme = v);
    setIfPresent('respectSignal', (String v) => _extracted.respectSignal = v);
    setIfPresent(
        'valueConflict', (String v) => _extracted.valueConflict = v);
    setIfPresent('messagingImportance',
        (String v) => _extracted.messagingImportance = v);
    setIfPresent(
        'unheardFeeling', (String v) => _extracted.unheardFeeling = v);
    setIfPresent('judgmentCloudedBy',
        (String v) => _extracted.judgmentCloudedBy = v);
    setIfPresent('feelingsChanged',
        (String v) => _extracted.feelingsChanged = v);
    setIfPresent('misunderstandingRisk',
        (String v) => _extracted.misunderstandingRisk = v);
    setIfPresent('partnerShouldKnowEarly',
        (String v) => _extracted.partnerShouldKnowEarly = v);
    setIfPresent('freeformForProfile',
        (String v) => _extracted.freeformForProfile = v);
    setIfPresent('friendDescription',
        (String v) => _extracted.friendDescription = v);
    setIfPresent('threeExperiences',
        (String v) => _extracted.threeExperiences = v);
    setIfPresent('idealDay', (String v) => _extracted.idealDay = v);
    setIfPresent('potentialVsBehavior',
        (String v) => _extracted.potentialVsBehavior = v);
    setIfPresent(
        'safetyExperience', (String v) => _extracted.safetyExperience = v);
    setIfPresent('profileSummaryFeedback',
        (String v) => _extracted.profileSummaryFeedback = v);

    // Enum alanları
    setIfPresent('goal', (String v) {
      _extracted.goal = _parseGoal(v);
    });
    setIfPresent('pacingPreference', (String v) {
      _extracted.pacingPreference = _parsePacing(v);
    });
    setIfPresent('relationshipExperience', (String v) {
      _extracted.relationshipExperience = _parseExperience(v);
    });
    setIfPresent('communicationPreference', (String v) {
      _extracted.communicationPreference = _parseCommPref(v);
    });
    setIfPresent('conflictStyle', (String v) {
      _extracted.conflictStyle = _parseConflict(v);
    });
    setIfPresent('ambiguityResponse', (String v) {
      _extracted.ambiguityResponse = _parseAmbiguity(v);
    });
    setIfPresent('fatigueResponse', (String v) {
      _extracted.fatigueResponse = _parseFatigue(v);
    });
    setIfPresent('assuranceNeed', (String v) {
      _extracted.assuranceNeed = _parseAssurance(v);
    });
    setIfPresent('jealousyLevel', (String v) {
      _extracted.jealousyLevel = v;
    });

    // Liste alanları — mevcut listeye ekle (çift girişi önle)
    setListIfPresent('coreTraits', (List<String> v) {
      for (final String trait in v) {
        if (!_extracted.coreTraits.contains(trait)) {
          _extracted.coreTraits.add(trait);
        }
      }
    });
    setListIfPresent('values', (List<String> v) {
      for (final String val in v) {
        if (!_extracted.values.contains(val)) {
          _extracted.values.add(val);
        }
      }
    });
    setListIfPresent('blindSpots', (List<String> v) {
      for (final String spot in v) {
        if (!_extracted.blindSpots.contains(spot)) {
          _extracted.blindSpots.add(spot);
        }
      }
    });
    setListIfPresent('dealbreakers', (List<String> v) {
      for (final String db in v) {
        if (!_extracted.dealbreakers.contains(db)) {
          _extracted.dealbreakers.add(db);
        }
      }
    });
    setListIfPresent('alarmTriggers', (List<String> v) {
      for (final String trigger in v) {
        if (!_extracted.alarmTriggers.contains(trigger)) {
          _extracted.alarmTriggers.add(trigger);
        }
      }
    });
    setListIfPresent('lifestyleFactors', (List<String> v) {
      for (final String factor in v) {
        if (!_extracted.lifestyleFactors.contains(factor)) {
          _extracted.lifestyleFactors.add(factor);
        }
      }
    });

    setIfPresent('highAssuranceThought',
        (String v) => _extracted.highAssuranceThought = v);
    setIfPresent('idealizationAwareness',
        (String v) => _extracted.idealizationAwareness = v);
    setIfPresent('firstRelationshipLearning',
        (String v) => _extracted.firstRelationshipLearning = v);
    setIfPresent('noSecondChanceBehavior',
        (String v) => _extracted.noSecondChanceBehavior = v);
    setIfPresent('fastAttachmentDriver',
        (String v) => _extracted.fastAttachmentDriver = v);
    setIfPresent('fastEliminationReason',
        (String v) => _extracted.fastEliminationReason = v);
  }

  String _beliefExtractionPrompt() {
    return '''
Kullanıcının aşk ve ilişki inançları hakkındaki mesajını oku.
Her inanç için 1-7 arası bir skor belirle (1=hiç katılmıyorum, 7=tamamen katılıyorum).
Kullanıcının söylediklerinden çıkarım yap, tahmin etme. Emin değilsen 4 ver.

JSON formatında döndür:
{
  "beliefRightPersonFindsWay": 4,
  "beliefChemistryFeltFast": 4,
  "beliefStrongAttractionIsSign": 4,
  "beliefFeelsRightOrNot": 4,
  "beliefFirstFeelingsAreTruth": 4,
  "beliefPotentialEqualsValue": 4,
  "beliefAmbiguityIsNormal": 4,
  "beliefLoveOvercomesIssues": 4
}
''';
  }

  void _applyBeliefs(BeliefExtractionPayload payload) {
    _extracted.beliefRightPersonFindsWay =
        payload.beliefRightPersonFindsWay;
    _extracted.beliefChemistryFeltFast =
        payload.beliefChemistryFeltFast;
    _extracted.beliefStrongAttractionIsSign =
        payload.beliefStrongAttractionIsSign;
    _extracted.beliefFeelsRightOrNot = payload.beliefFeelsRightOrNot;
    _extracted.beliefFirstFeelingsAreTruth =
        payload.beliefFirstFeelingsAreTruth;
    _extracted.beliefPotentialEqualsValue =
        payload.beliefPotentialEqualsValue;
    _extracted.beliefAmbiguityIsNormal =
        payload.beliefAmbiguityIsNormal;
    _extracted.beliefLoveOvercomesIssues =
        payload.beliefLoveOvercomesIssues;
    _capturedFields.addAll(<String>[
      'beliefRightPersonFindsWay',
      'beliefChemistryFeltFast',
      'beliefStrongAttractionIsSign',
      'beliefFeelsRightOrNot',
      'beliefFirstFeelingsAreTruth',
      'beliefPotentialEqualsValue',
      'beliefAmbiguityIsNormal',
      'beliefLoveOvercomesIssues',
    ]);
  }

  /// Bir sonraki sohbet yanıtını LLM ile oluştur.
  /// Kullanıcı ne derse desin (profil bilgisi, anlamadım, emoji, alakasız konu,
  /// tek kelime cevap, vs.) LLM doğal şekilde yanıt verir.
  ///
  /// Öncelik: self-hosted HF Space. Yedek: Gemini 2.5 ailesi.
  Future<String> _generateNextQuestion() async {
    final StringBuffer conversationSoFar = StringBuffer();
    // Son 12 tur yeterli — token tasarrufu + Gemini ücretsiz katmanını korur.
    final List<ChatMessage> recent = _history.length > 12
        ? _history.sublist(_history.length - 12)
        : _history;
    for (final ChatMessage msg in recent) {
      final String role = msg.role == 'assistant' ? 'Sırdaş' : 'Kullanıcı';
      conversationSoFar.writeln('$role: ${msg.content}');
      conversationSoFar.writeln();
    }

    final List<String> missingFields = _getMissingFields();
    final List<String> filledFields = _getFilledFields();

    final String systemPrompt = '''
Sen "Sırdaş"sın. Sıcak, kısa ve güven veren bir dille konuş. Türkçen akıcı ve doğal olmalı.

KURALLAR:
- Max 1-2 cümle. 3 cümleyi geçme.
- Samimi ol ama laubali olma.
- "kanka", "ya", "hani", "valla", "canım", "tatlım" gibi aşırı gündelik hitaplar kullanma.
- Yakın arkadaş rahatlığında ol ama saygılı kal.
- TEK soru sor. Çoklu soru sorma.
- Önce kısa bir karşılık ver ("Anladım", "Bu önemli", "Bu zorlayıcı olabilir"), sonra sorunu sor.
- Hassas konuda empati göster ama dramatikleşme.
- Son 12 tur sana veriliyor — zaten sorduğun soruyu TEKRAR sorma, gerekiyorsa farklı açıdan yaklaş.
- Aynı cümle kalıbını arka arkaya kullanma.

ÖRNEK İYİ SORULAR:
"İlişkilerde seni en çok ne yoruyor?"
"Birine güvenmen için sende ne oluşması gerekiyor?"
"Sende sık tekrar eden şey ne oluyor?"
"En hassas olduğun yer neresi?"
"Arkadaşların senin hakkında en çok ne söylüyor?"
"Bir anlaşmazlıkta ilk yaptığın şey ne oluyor?"
"Sınır koymak senin için kolay mı?"
"Seni tanıyan biri en başta neyi bilse iyi olur?"

TOPLANAN: ${filledFields.isEmpty ? 'henüz yok' : filledFields.join(', ')}

EKSİK: ${missingFields.isEmpty ? 'tamam' : missingFields.join(', ')}

Eksiklerden birini doğal sohbetle topla. SADECE sohbet mesajını yaz — başka hiçbir şey ekleme.
''';

    final String userPayload =
        'Şimdiye kadarki sohbet:\n$conversationSoFar\n\n'
        'Sıradaki doğal sohbet yanıtını yaz. Sadece metni döndür, JSON veya etiket kullanma.';

    // ── Öncelik 1: Gemini 2.5 Flash (kaliteli Türkçe)
    if (AIConfig.instance.hasGemini) {
      try {
        final String reply = await GeminiChatService.instance.generateReply(
          systemPrompt: systemPrompt,
          userMessage: userPayload,
        );
        final String trimmed = reply.trim();
        if (trimmed.isNotEmpty) return trimmed;
      } catch (e) {
        debugPrint('Gemini sohbet hatası: $e');
      }
    }

    // ── Yedek: self-hosted LLM (eski yardımcı akış)
    if (AIConfig.instance.hasSelfHostedLlm) {
      try {
        final String reply = await SelfHostedLlmService.instance.completeText(
          systemPrompt: systemPrompt,
          userMessage: userPayload,
          task: 'next_question',
        );
        final String trimmed = reply.trim();
        if (trimmed.isNotEmpty) return trimmed;
      } catch (e) {
        debugPrint('Self-hosted sohbet yedek hatası: $e');
      }
    }

    // LLM boş yanıt verdiyse basit bir takip sorusu
    return _getDefaultFollowUp();
  }

  /// İnanç puanlarını metinden çıkar
  Future<void> _extractBeliefsFromText(String userText) async {
    final String systemPrompt = '''
Kullanıcının aşk ve ilişki inançları hakkındaki mesajını oku.
Her inanç için 1-7 arası bir skor belirle (1=hiç katılmıyorum, 7=tamamen katılıyorum).
Kullanıcının söylediklerinden çıkarım yap, tahmin etme. Emin değilsen 4 ver.

JSON formatında döndür:
{
  "beliefRightPersonFindsWay": 4,
  "beliefChemistryFeltFast": 4,
  "beliefStrongAttractionIsSign": 4,
  "beliefFeelsRightOrNot": 4,
  "beliefFirstFeelingsAreTruth": 4,
  "beliefPotentialEqualsValue": 4,
  "beliefAmbiguityIsNormal": 4,
  "beliefLoveOvercomesIssues": 4
}
''';

    final AiEnvelope<BeliefExtractionPayload> envelope =
        await DeepAnalysisOrchestrator.instance.extractBeliefScores(
      systemPrompt: systemPrompt,
      userMessage: userText,
    );
    _applyBeliefs(envelope.payload);
    return;

  }

  // ══════════════════════════════════════════════
  //  Yardımcı Fonksiyonlar
  // ══════════════════════════════════════════════

  ChatMessage _addAssistant(String content) {
    final ChatMessage msg =
        ChatMessage(role: 'assistant', content: content);
    _history.add(msg);
    return msg;
  }

  bool _hasField(String key) => _capturedFields.contains(key);

  int _countFields(Iterable<String> keys) =>
      keys.where(_capturedFields.contains).length;

  List<String> _applicableConditionalFields() {
    final List<String> fields = <String>[];

    if (_hasField('assuranceNeed') &&
        _extracted.assuranceNeed == AssuranceNeed.high) {
      fields.add('highAssuranceThought');
    }
    if ((_hasField('blindSpots') &&
            _extracted.blindSpots.contains('Yoğun çekimi gerçek uyum sanma')) ||
        (_hasField('potentialVsBehavior') &&
            _extracted.potentialVsBehavior.toLowerCase().contains('potansiyel')) ||
        _hasField('judgmentCloudedBy')) {
      fields.add('idealizationAwareness');
    }
    if (_hasField('relationshipExperience') &&
        _extracted.relationshipExperience == RelationshipExperience.first) {
      fields.add('firstRelationshipLearning');
    }
    if ((_hasField('alarmTriggers') && _extracted.alarmTriggers.length >= 4) ||
        _hasField('boundaryDifficulty')) {
      fields.add('noSecondChanceBehavior');
    }
    if (_hasField('blindSpots') &&
        _extracted.blindSpots.contains('Çok erken duygusal bağlanma')) {
      fields.add('fastAttachmentDriver');
    }
    if (_hasField('blindSpots') &&
        _extracted.blindSpots.contains('Çok hızlı eleme ve vazgeçme')) {
      fields.add('fastEliminationReason');
    }

    return fields;
  }

  /// Eski 8 bölümlük form kadar kapsayıcı olmak için yalnızca toplam sayıya değil,
  /// bölüm bazlı kapsama ve koşullu follow-up'lara da bakıyoruz.
  bool _hasEnoughData() {
    final Map<String, List<String>> sectionFields = <String, List<String>>{
      'intro': <String>[
        'selfDescription',
        'coreTraits',
        'currentLifeTheme',
        'datingChallenge',
        'freeformAboutMe',
        'friendDescription',
        'threeExperiences',
      ],
      'intent': <String>[
        'goal',
        'pacingPreference',
        'openingUpTime',
        'trustBuilder',
        'relationshipExperience',
        'recentDatingChallenge',
        'idealDay',
      ],
      'values': <String>[
        'values',
        'respectSignal',
        'dealbreakers',
        'lifestyleFactors',
        'potentialVsBehavior',
        'valueConflict',
      ],
      'communication': <String>[
        'communicationPreference',
        'showsInterestHow',
        'directVsSoft',
        'messagingImportance',
        'ambiguityResponse',
        'conflictStyle',
        'unheardFeeling',
      ],
      'blindSpots': <String>[
        'blindSpots',
        'recurringPattern',
        'feedbackFromCloseOnes',
        'biggestMisjudgment',
        'judgmentCloudedBy',
        'stayedTooLong',
        'feelingsChanged',
      ],
      'safety': <String>[
        'alarmTriggers',
        'vulnerabilityArea',
        'assuranceNeed',
        'jealousyLevel',
        'fatigueResponse',
        'boundaryDifficulty',
        'safetyExperience',
      ],
      'open': <String>[
        'attachmentHistory',
        'misunderstandingRisk',
        'partnerShouldKnowEarly',
        'freeformForProfile',
      ],
    };

    final Map<String, int> minimumPerSection = <String, int>{
      'intro': 5,
      'intent': 5,
      'values': 4,
      'communication': 5,
      'blindSpots': 5,
      'safety': 5,
      'open': 3,
    };

    for (final MapEntry<String, List<String>> entry in sectionFields.entries) {
      final int captured = _countFields(entry.value);
      if (captured < (minimumPerSection[entry.key] ?? entry.value.length)) {
        return false;
      }
    }

    final List<String> allBaseFields = sectionFields.values
        .expand((List<String> fields) => fields)
        .toList(growable: false);
    if (_countFields(allBaseFields) < 32) {
      return false;
    }

    final List<String> conditionalFields = _applicableConditionalFields();
    if (_countFields(conditionalFields) < conditionalFields.length) {
      return false;
    }

    return true;
  }

  bool _hasEnoughDataForEarlyClose() {
    final Map<String, List<String>> sectionFields = <String, List<String>>{
      'intro': <String>[
        'selfDescription',
        'coreTraits',
        'currentLifeTheme',
        'datingChallenge',
        'friendDescription',
      ],
      'intent': <String>[
        'goal',
        'pacingPreference',
        'trustBuilder',
        'relationshipExperience',
      ],
      'values': <String>[
        'values',
        'respectSignal',
        'dealbreakers',
      ],
      'communication': <String>[
        'communicationPreference',
        'showsInterestHow',
        'ambiguityResponse',
        'conflictStyle',
      ],
      'blindSpots': <String>[
        'blindSpots',
        'recurringPattern',
        'feedbackFromCloseOnes',
      ],
      'safety': <String>[
        'alarmTriggers',
        'vulnerabilityArea',
        'assuranceNeed',
      ],
      'open': <String>[
        'attachmentHistory',
        'partnerShouldKnowEarly',
      ],
    };

    final Map<String, int> minimumPerSection = <String, int>{
      'intro': 3,
      'intent': 3,
      'values': 2,
      'communication': 3,
      'blindSpots': 2,
      'safety': 2,
      'open': 1,
    };

    for (final MapEntry<String, List<String>> entry in sectionFields.entries) {
      final int captured = _countFields(entry.value);
      if (captured < (minimumPerSection[entry.key] ?? entry.value.length)) {
        return false;
      }
    }

    final List<String> allBaseFields = sectionFields.values
        .expand((List<String> fields) => fields)
        .toList(growable: false);
    return _countFields(allBaseFields) >= 18;
  }

  bool _isWrapIntent(String raw) {
    final String text = raw.trim().toLowerCase();
    if (text.isEmpty) return false;

    const List<String> directSignals = <String>[
      'bitirelim',
      'sonlandir',
      'sonlandır',
      'tamam bu kadar',
      'bu kadar',
      'ilerleyelim',
      'analize gec',
      'analize geç',
      'rapora gec',
      'rapora geç',
      'profili cikar',
      'profili çıkar',
      'baska yok',
      'başka yok',
      'yeter bu kadar',
    ];

    if (directSignals.any(text.contains)) {
      return true;
    }

    final String previousAssistant = _lastAssistantMessage().toLowerCase();
    final bool assistantWasWrapping =
        previousAssistant.contains('eklemek istedigin') ||
        previousAssistant.contains('eklemek istediğin') ||
        previousAssistant.contains('baska bir sey var mi') ||
        previousAssistant.contains('başka bir şey var mı') ||
        previousAssistant.contains('aklina takilan') ||
        previousAssistant.contains('aklına takılan') ||
        previousAssistant.contains('ilerlemek istiyor musun') ||
        previousAssistant.contains('sohbeti sonlandirma');

    if (assistantWasWrapping) {
      return text == 'yok' ||
          text == 'hayir' ||
          text == 'hayır' ||
          text == 'baska yok' ||
          text == 'başka yok' ||
          text == 'yok artık' ||
          text == 'bu kadar';
    }

    return false;
  }

  String _lastAssistantMessage() {
    for (int i = _history.length - 1; i >= 0; i--) {
      final ChatMessage msg = _history[i];
      if (msg.role == 'assistant') {
        return msg.content;
      }
    }
    return '';
  }

  List<String> _getMissingFields() {
    final List<String> missing = <String>[];

    if (!_hasField('selfDescription')) {
      missing.add('[KENDİNİ TANIT] Kendini nasıl biri olarak gördüğü');
    }
    if (!_hasField('coreTraits')) {
      missing.add('[KENDİNİ TANIT] Temel karakter özellikleri');
    }
    if (!_hasField('currentLifeTheme')) {
      missing.add('[KENDİNİ TANIT] Hayatındaki baskın tema');
    }
    if (!_hasField('datingChallenge')) {
      missing.add('[KENDİNİ TANIT] İlişkilerde en çok zorlandığı şey');
    }
    if (!_hasField('friendDescription')) {
      missing.add('[KENDİNİ TANIT] Yakın çevrenin onu nasıl gördüğü');
    }
    if (!_hasField('freeformAboutMe')) {
      missing.add('[KENDİNİ TANIT] Aile / kültür / özel geçmiş bağlamı');
    }
    if (!_hasField('threeExperiences')) {
      missing.add('[KENDİNİ TANIT] Son birkaç deneyimin ortak teması');
    }

    if (!_hasField('goal')) {
      missing.add('[İLİŞKİ NİYETİ] İlişkiden ne istediği');
    }
    if (!_hasField('pacingPreference')) {
      missing.add('[İLİŞKİ NİYETİ] Doğal ilerleme temposu');
    }
    if (!_hasField('openingUpTime')) {
      missing.add('[İLİŞKİ NİYETİ] Birine açılma süresi / şartı');
    }
    if (!_hasField('trustBuilder')) {
      missing.add('[İLİŞKİ NİYETİ] Güven inşa eden ilk davranış');
    }
    if (!_hasField('relationshipExperience')) {
      missing.add('[İLİŞKİ NİYETİ] Deneyim seviyesi');
    }
    if (!_hasField('recentDatingChallenge')) {
      missing.add('[İLİŞKİ NİYETİ] Son dönemde zorlayan deneyim');
    }
    if (!_hasField('idealDay')) {
      missing.add('[İLİŞKİ NİYETİ] İstediği ilişkinin günlük hali');
    }

    if (!_hasField('values')) {
      missing.add('[DEĞERLER] Olmazsa olmaz değerler');
    }
    if (!_hasField('respectSignal')) {
      missing.add('[DEĞERLER] Saygı gördüğünü nasıl anladığı');
    }
    if (!_hasField('dealbreakers')) {
      missing.add('[DEĞERLER] Kesin sınırlar / kabul etmeyeceği şeyler');
    }
    if (!_hasField('lifestyleFactors')) {
      missing.add('[DEĞERLER] Günlük uyum için önemli konular');
    }
    if (!_hasField('potentialVsBehavior')) {
      missing.add('[DEĞERLER] Potansiyel mi bugünkü davranış mı');
    }
    if (!_hasField('valueConflict')) {
      missing.add('[DEĞERLER] Değer-istek çatışmasında ne yaptığı');
    }

    if (!_hasField('communicationPreference')) {
      missing.add('[İLETİŞİM] Doğal iletişim temposu');
    }
    if (!_hasField('showsInterestHow')) {
      missing.add('[İLETİŞİM] İlgi gösterme biçimi');
    }
    if (!_hasField('directVsSoft')) {
      missing.add('[İLETİŞİM] Direkt mi yumuşak mı konuştuğu');
    }
    if (!_hasField('messagingImportance')) {
      missing.add('[İLETİŞİM] Mesaj sıklığı / yanıt hızına verdiği anlam');
    }
    if (!_hasField('ambiguityResponse')) {
      missing.add('[İLETİŞİM] Belirsizlikte ilk tepkisi');
    }
    if (!_hasField('conflictStyle')) {
      missing.add('[İLETİŞİM] Anlaşmazlıkta ilk davranışı');
    }
    if (!_hasField('unheardFeeling')) {
      missing.add('[İLETİŞİM] Duyulmadığında ne yaptığı');
    }

    if (!_hasField('blindSpots')) {
      missing.add('[KÖR NOKTALAR] Kendinde gördüğü kör noktalar');
    }
    if (!_hasField('recurringPattern')) {
      missing.add('[KÖR NOKTALAR] Tekrar eden ilişki döngüsü');
    }
    if (!_hasField('feedbackFromCloseOnes')) {
      missing.add('[KÖR NOKTALAR] Yakın çevreden gelen geri bildirim');
    }
    if (!_hasField('biggestMisjudgment')) {
      missing.add('[KÖR NOKTALAR] En büyük yanlış değerlendirme');
    }
    if (!_hasField('judgmentCloudedBy')) {
      missing.add('[KÖR NOKTALAR] Kararı en çok neyin bulandırdığı');
    }
    if (!_hasField('stayedTooLong')) {
      missing.add('[KÖR NOKTALAR] İyi gelmediği halde kaldığı durum');
    }
    if (!_hasField('feelingsChanged')) {
      missing.add('[KÖR NOKTALAR] Hisleri değişince ne yaptığı');
    }

    if (!_hasField('alarmTriggers')) {
      missing.add('[GÜVENLİK] Alarm yaratan davranışlar');
    }
    if (!_hasField('vulnerabilityArea')) {
      missing.add('[GÜVENLİK] En hassas / kırılgan alan');
    }
    if (!_hasField('assuranceNeed')) {
      missing.add('[GÜVENLİK] Güvence ihtiyacı seviyesi');
    }
    if (!_hasField('jealousyLevel')) {
      missing.add('[GÜVENLİK] Kıskançlık / sahiplenme düzeyi');
    }
    if (!_hasField('fatigueResponse')) {
      missing.add('[GÜVENLİK] Yorulduğunda ilişkide ne yaptığı');
    }
    if (!_hasField('boundaryDifficulty')) {
      missing.add('[GÜVENLİK] Sınır koymakta zorlandığı alan');
    }
    if (!_hasField('safetyExperience')) {
      missing.add('[GÜVENLİK] Sezgisini küçümsediği veya güvenliği sarsan deneyim');
    }

    if (!_hasField('attachmentHistory')) {
      missing.add('[AÇIK ALAN] Çocukluk / aile etkisinin bugüne yansıması');
    }
    if (!_hasField('misunderstandingRisk')) {
      missing.add('[AÇIK ALAN] Yanlış anlaşılma riski taşıyan tarafı');
    }
    if (!_hasField('partnerShouldKnowEarly')) {
      missing.add('[AÇIK ALAN] Partnerin erken bilmesi gereken şey');
    }
    if (!_hasField('freeformForProfile')) {
      missing.add('[AÇIK ALAN] Form dışı ama profil için kritik bilgi');
    }
    for (final String key in _applicableConditionalFields()) {
      if (_hasField(key)) continue;
      switch (key) {
        case 'highAssuranceThought':
          missing.add('[KOŞULLU] Belirsizlikte aklından ilk geçen düşünce');
          break;
        case 'idealizationAwareness':
          missing.add('[KOŞULLU] Birine gerçekte olmayan özellik yüklediği örnek');
          break;
        case 'firstRelationshipLearning':
          missing.add('[KOŞULLU] Az deneyimliyse şu an en çok öğrenmek istediği şey');
          break;
        case 'noSecondChanceBehavior':
          missing.add('[KOŞULLU] Asla ikinci şans vermeyeceği davranış');
          break;
        case 'fastAttachmentDriver':
          missing.add('[KOŞULLU] Hızlı bağlanmayı neyin tetiklediği');
          break;
        case 'fastEliminationReason':
          missing.add('[KOŞULLU] Hızlı elemenin korunma mı uyumsuzluk mu olduğu');
          break;
      }
    }

    return missing;
  }

  /// LLM prompt'una bağlam olarak "şu an ne toplandı" bilgisi verir
  List<String> _getFilledFields() {
    final List<String> filled = <String>[];

    if (_hasField('selfDescription')) {
      filled.add('✓ [TANITIM] Kendini anlatan ana metin var');
    }
    if (_hasField('coreTraits')) {
      filled.add(
        '✓ [TANITIM] Özellikler: ${_extracted.coreTraits.take(4).join(", ")}',
      );
    }
    if (_hasField('currentLifeTheme')) {
      filled.add('✓ [TANITIM] Hayat odağı yakalandı');
    }
    if (_hasField('datingChallenge')) {
      filled.add('✓ [TANITIM] İlişki zorluğu netleşti');
    }
    if (_hasField('friendDescription')) {
      filled.add('✓ [TANITIM] Dışarıdan nasıl göründüğünü anlattı');
    }
    if (_hasField('freeformAboutMe')) {
      filled.add('✓ [TANITIM] Arka plan / hassas bağlam paylaştı');
    }

    // Bölüm 2: İlişki Niyeti
    if (_hasField('goal')) {
      filled.add('✓ [NİYET] Hedef: ${_extracted.goal.name}');
    }
    if (_hasField('pacingPreference')) {
      filled.add('✓ [NİYET] Tempo tercihi var');
    }
    if (_hasField('openingUpTime')) {
      filled.add('✓ [NİYET] Açılma süresi netleşti');
    }
    if (_hasField('trustBuilder')) {
      filled.add('✓ [NİYET] Güven inşa bilgisi var');
    }
    if (_hasField('relationshipExperience')) {
      filled.add('✓ [NİYET] Deneyim seviyesi: ${_extracted.relationshipExperience.name}');
    }
    if (_hasField('recentDatingChallenge')) {
      filled.add('✓ [NİYET] Son deneyim paylaşıldı');
    }
    if (_hasField('idealDay')) {
      filled.add('✓ [NİYET] İdeal ilişki günü var');
    }

    // Bölüm 3: Değerler
    if (_hasField('values')) {
      filled.add('✓ [DEĞERLER] ${_extracted.values.take(3).join(", ")}');
    }
    if (_hasField('respectSignal')) {
      filled.add('✓ [DEĞERLER] Saygı sinyali var');
    }
    if (_hasField('dealbreakers')) {
      filled.add('✓ [DEĞERLER] Vazgeçilmezler: ${_extracted.dealbreakers.take(2).join(", ")}');
    }
    if (_hasField('potentialVsBehavior')) {
      filled.add('✓ [DEĞERLER] Potansiyel/davranış tercihi var');
    }
    if (_hasField('valueConflict')) {
      filled.add('✓ [DEĞERLER] Değer çatışması tepkisi var');
    }

    // Bölüm 4: İletişim
    if (_hasField('communicationPreference')) {
      filled.add('✓ [İLETİŞİM] Tempo: ${_extracted.communicationPreference.name}');
    }
    if (_hasField('showsInterestHow')) {
      filled.add('✓ [İLETİŞİM] İlgi gösterme biçimi var');
    }
    if (_hasField('conflictStyle')) {
      filled.add('✓ [İLETİŞİM] Çatışma stili: ${_extracted.conflictStyle.name}');
    }
    if (_hasField('ambiguityResponse')) {
      filled.add('✓ [İLETİŞİM] Belirsizlik tepkisi: ${_extracted.ambiguityResponse.name}');
    }
    if (_hasField('unheardFeeling')) {
      filled.add('✓ [İLETİŞİM] Duyulmama tepkisi var');
    }

    // Bölüm 5: Kör Noktalar
    if (_hasField('blindSpots')) {
      filled.add('✓ [KÖR NOKTA] ${_extracted.blindSpots.take(2).join(", ")}');
    }
    if (_hasField('recurringPattern')) {
      filled.add('✓ [KÖR NOKTA] Tekrar eden kalıp var');
    }
    if (_hasField('feedbackFromCloseOnes')) {
      filled.add('✓ [KÖR NOKTA] Çevre geri bildirimi var');
    }
    if (_hasField('biggestMisjudgment')) {
      filled.add('✓ [KÖR NOKTA] Yanlış değerlendirme paylaşıldı');
    }
    if (_hasField('stayedTooLong')) {
      filled.add('✓ [KÖR NOKTA] Aşırı kalma deneyimi var');
    }

    // Bölüm 7: Güvenlik
    if (_hasField('alarmTriggers')) {
      filled.add('✓ [GÜVENLİK] Alarm tetikleyiciler: ${_extracted.alarmTriggers.take(2).join(", ")}');
    }
    if (_hasField('vulnerabilityArea')) {
      filled.add('✓ [GÜVENLİK] Hassas alan var');
    }
    if (_hasField('assuranceNeed')) {
      filled.add('✓ [GÜVENLİK] Güvence ihtiyacı: ${_extracted.assuranceNeed.name}');
    }
    if (_hasField('boundaryDifficulty')) {
      filled.add('✓ [GÜVENLİK] Sınır zorluğu var');
    }
    if (_hasField('attachmentHistory')) {
      filled.add('✓ [GÜVENLİK] Bağlanma geçmişi var');
    }

    // Bölüm 8: Açık Alan
    if (_hasField('partnerShouldKnowEarly')) {
      filled.add('✓ [AÇIK ALAN] Erken bilinmesi gereken paylaşıldı');
    }
    if (_hasField('misunderstandingRisk')) {
      filled.add('✓ [AÇIK ALAN] Yanlış anlaşılma riski var');
    }

    return filled;
  }

  String _getDefaultFollowUp() {
    final List<String> missing = _getMissingFields();
    if (missing.isEmpty) {
      return 'Tamam, seni anlamak için iyi bir zemin oluştu.';
    }

    // Bölüm 1: Kendini Tanıt
    if (!_hasField('selfDescription')) {
      return 'Kendini üç kelimeyle anlatsan neler derdin?';
    }
    if (!_hasField('coreTraits')) {
      return 'Seni en iyi tanımlayan 3 özellik ne olurdu?';
    }
    if (!_hasField('friendDescription')) {
      return 'Arkadaşların seni birine tanıtsa ne der?';
    }
    if (!_hasField('datingChallenge')) {
      return 'İlişkilerde seni en çok ne yoruyor?';
    }

    // Bölüm 2: İlişki
    if (!_hasField('goal')) {
      return 'Şu ara ilişkiden en çok ne bekliyorsun?';
    }
    if (!_hasField('trustBuilder')) {
      return 'Birine güvenmen için sende ne oluşması gerekiyor?';
    }
    if (!_hasField('openingUpTime')) {
      return 'Birine açılman ne kadar sürer genelde?';
    }

    // Bölüm 3: Değerler
    if (!_hasField('values')) {
      return 'İlişkide senin için en önemli şey ne?';
    }
    if (!_hasField('dealbreakers')) {
      return 'Asla kabul etmeyeceğin bir davranış var mı?';
    }
    if (!_hasField('respectSignal')) {
      return 'Sana saygı duyulduğunu nasıl anlarsın?';
    }

    // Bölüm 4: İletişim
    if (!_hasField('showsInterestHow')) {
      return 'Sen ilgini nasıl gösterirsin birine?';
    }
    if (!_hasField('unheardFeeling')) {
      return 'Dinlenmediğini hissettiğinde ne yaparsın?';
    }
    if (!_hasField('conflictStyle')) {
      return 'Bir anlaşmazlıkta ilk yaptığın şey ne oluyor?';
    }

    // Bölüm 5: Kör Noktalar
    if (!_hasField('recurringPattern')) {
      return 'Sende sık tekrar eden bir ilişki döngüsü var mı?';
    }
    if (!_hasField('feedbackFromCloseOnes')) {
      return 'Yakınların ilişki konusunda sana en çok ne söylüyor?';
    }
    if (!_hasField('stayedTooLong')) {
      return 'Gereğinden fazla kaldığın bir durum oldu mu?';
    }

    // Bölüm 7: Güvenlik
    if (!_hasField('vulnerabilityArea')) {
      return 'İlişkide en hassas olduğun alan neresi?';
    }
    if (!_hasField('alarmTriggers')) {
      return 'Birinde gördüğünde sende alarm yaratan şeyler ne?';
    }
    if (!_hasField('boundaryDifficulty')) {
      return 'Sınır koymak senin için kolay mı, zorlayıcı mı?';
    }
    if (!_hasField('attachmentHistory')) {
      return 'Ailen bağlanma konusunda seni nasıl etkiledi?';
    }

    // Bölüm 8: Açık Alan
    if (!_hasField('partnerShouldKnowEarly')) {
      return 'Seninle tanışan biri ilk başta ne bilse iyi olur?';
    }

    return 'Bunu biraz daha açar mısın? Seni daha net anlamak istiyorum.';
  }

  // ── Enum Parsers ──

  String _extractDisplayNameFallback(String raw) {
    final String text = raw.trim();
    if (text.isEmpty) return '';

    final List<RegExp> patterns = <RegExp>[
      RegExp(r"(?:benim\s+adım|adım)\s+([A-Za-zÇĞİÖŞÜçğıöşü'-]+)", caseSensitive: false),
      RegExp(r"(?:benim\s+ismim|ismim)\s+([A-Za-zÇĞİÖŞÜçğıöşü'-]+)", caseSensitive: false),
      RegExp(r"(?:bana)\s+([A-Za-zÇĞİÖŞÜçğıöşü'-]+)\s+(?:de|diyebilirsin)", caseSensitive: false),
    ];

    for (final RegExp pattern in patterns) {
      final RegExpMatch? match = pattern.firstMatch(text);
      if (match != null) {
        return _normalizeDisplayName(match.group(1) ?? '');
      }
    }

    final List<String> tokens = text
        .split(RegExp(r'\s+'))
        .map(_normalizeDisplayName)
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);

    if (tokens.length == 1) return tokens.first;
    if (tokens.length == 2 &&
        !text.toLowerCase().contains('benim') &&
        !text.toLowerCase().contains('adım') &&
        !text.toLowerCase().contains('ismim')) {
      return tokens.first;
    }

    return '';
  }

  String _normalizeDisplayName(String raw) {
    final String cleaned =
        raw.replaceAll(RegExp(r"[^A-Za-zÇĞİÖŞÜçğıöşü'-]"), '').trim();
    if (cleaned.isEmpty) return '';
    return cleaned[0].toUpperCase() +
        (cleaned.length > 1 ? cleaned.substring(1) : '');
  }

  RelationshipGoal _parseGoal(String v) {
    return RelationshipGoal.values.firstWhere(
      (RelationshipGoal e) => e.name == v,
      orElse: () => RelationshipGoal.unsure,
    );
  }

  PacingPreference _parsePacing(String v) {
    return PacingPreference.values.firstWhere(
      (PacingPreference e) => e.name == v,
      orElse: () => PacingPreference.balanced,
    );
  }

  RelationshipExperience _parseExperience(String v) {
    return RelationshipExperience.values.firstWhere(
      (RelationshipExperience e) => e.name == v,
      orElse: () => RelationshipExperience.several,
    );
  }

  CommunicationPreference _parseCommPref(String v) {
    return CommunicationPreference.values.firstWhere(
      (CommunicationPreference e) => e.name == v,
      orElse: () => CommunicationPreference.balancedRegular,
    );
  }

  ConflictStyle _parseConflict(String v) {
    return ConflictStyle.values.firstWhere(
      (ConflictStyle e) => e.name == v,
      orElse: () => ConflictStyle.talkItOut,
    );
  }

  AmbiguityResponse _parseAmbiguity(String v) {
    return AmbiguityResponse.values.firstWhere(
      (AmbiguityResponse e) => e.name == v,
      orElse: () => AmbiguityResponse.overthink,
    );
  }

  FatigueResponse _parseFatigue(String v) {
    return FatigueResponse.values.firstWhere(
      (FatigueResponse e) => e.name == v,
      orElse: () => FatigueResponse.pullAway,
    );
  }

  AssuranceNeed _parseAssurance(String v) {
    return AssuranceNeed.values.firstWhere(
      (AssuranceNeed e) => e.name == v,
      orElse: () => AssuranceNeed.medium,
    );
  }
}
