import 'package:flutter/foundation.dart';

import 'ai/adaptive_follow_up_service.dart';
import 'ai/ai_config.dart';
import 'ai/ai_contracts.dart';
import 'ai/deep_analysis_orchestrator.dart';
import 'ai/vector_profile_store.dart';
import 'models.dart';
import 'notification_service.dart';
import 'text_analysis_engine.dart';

class MatchProfileController extends ChangeNotifier {
  MatchProfileController();

  OnboardingProfile? _profile;
  int _selectedTab = 0;
  final List<JournalEntry> _journalEntries = <JournalEntry>[];
  final List<DailyCheckIn> _dailyCheckIns = <DailyCheckIn>[];
  final List<InteractionLogEntry> _interactionLog = <InteractionLogEntry>[];
  final List<ReadinessHistoryPoint> _readinessHistory = <ReadinessHistoryPoint>[];

  OnboardingProfile? get profile => _profile;
  int get selectedTab => _selectedTab;
  bool get hasCompletedOnboarding => _profile != null;
  List<JournalEntry> get journalEntries =>
      List<JournalEntry>.unmodifiable(_journalEntries);
  JournalEntry? get latestEntry =>
      _journalEntries.isEmpty ? null : _journalEntries.first;

  int get pendingCheckInCount => pendingCheckInTasks.length;

  int get sessionCount => _journalEntries.length;

  int get completedCheckInCount => _journalEntries.fold<int>(
        0,
        (int sum, JournalEntry entry) => sum + entry.completedCheckIns.length,
      );

  List<PendingCheckInTask> get pendingCheckInTasks {
    final List<PendingCheckInTask> tasks = <PendingCheckInTask>[];
    for (int index = 0; index < _journalEntries.length; index += 1) {
      final JournalEntry entry = _journalEntries[index];
      for (final int day in entry.pendingCheckIns) {
        tasks.add(
          PendingCheckInTask(
            entryIndex: index,
            title: entry.title,
            day: day,
            scheduledFor: entry.createdAt.add(Duration(days: day)),
          ),
        );
      }
    }
    tasks.sort(
      (PendingCheckInTask a, PendingCheckInTask b) =>
          a.scheduledFor.compareTo(b.scheduledFor),
    );
    return tasks;
  }

  String get patternStageLabel {
    if (sessionCount >= 8) return 'Güçlü tekrar eden örüntü';
    if (sessionCount >= 5) return 'Beliren örüntü';
    if (sessionCount >= 3) return 'Zayıf sinyal';
    return 'Örüntü motoru ısınıyor';
  }

  int get sessionsUntilPatternUnlock {
    if (sessionCount >= 3) return 0;
    return 3 - sessionCount;
  }

  String get repeatedSignalSnapshot {
    final Map<String, int> counts = <String, int>{};
    for (final JournalEntry entry in _journalEntries) {
      for (final InsightSignal signal in entry.report.cautionSignals) {
        counts.update(
          signal.title,
          (int value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }
    if (counts.isEmpty) return 'Henüz örüntü oluşmadı';
    final MapEntry<String, int> top = counts.entries.reduce(
      (MapEntry<String, int> a, MapEntry<String, int> b) =>
          a.value >= b.value ? a : b,
    );
    return '${top.key} · ${top.value} oturum';
  }

  String get missingDataSnapshot {
    final JournalEntry? entry = latestEntry;
    if (entry == null) {
      return 'İlk yansıtma sonrasında eksik veri alanları burada görünür.';
    }
    if (entry.report.missingDataPoints.isEmpty) {
      return 'Son oturumda kritik eksik veri yok.';
    }
    return entry.report.missingDataPoints.first;
  }

  String get todayFocus {
    final List<PendingCheckInTask> tasks = pendingCheckInTasks;
    if (tasks.isNotEmpty) {
      final PendingCheckInTask task = tasks.first;
      return '${task.title} için ${task.day}. gün sonuç kontrolü seni bekliyor.';
    }
    final JournalEntry? entry = latestEntry;
    if (entry == null) {
      return 'Romantik karar profilin hazır. Şimdi ilk yansıtma ile kişiselleştirilmiş içgörü akışını başlat.';
    }
    return entry.report.nextStep;
  }

  String get latestOutcomeSnapshot {
    final JournalEntry? entry = latestEntry;
    if (entry == null) return 'Henüz outcome verisi yok.';
    if (entry.completedCheckIns.isEmpty) {
      return 'İlk sonuç kontrolü henüz tamamlanmadı.';
    }
    final CheckInRecord latest = entry.completedCheckIns.last;
    return '${latest.day}. gün: ${latest.outcome.label}';
  }

  String get evidenceMixSnapshot {
    final JournalEntry? entry = latestEntry;
    if (entry == null) return 'İlk raporla kanıt dağılımı görünecek.';
    final List<MapEntry<String, int>> sorted =
        entry.report.evidenceMix.entries.toList()
          ..sort(
            (MapEntry<String, int> a, MapEntry<String, int> b) =>
                b.value.compareTo(a.value),
          );
    return sorted
        .take(2)
        .map((MapEntry<String, int> item) => '${item.key}: ${item.value}')
        .join(' · ');
  }

  String get calibrationSnapshot {
    if (_journalEntries.isEmpty) {
      return 'Doğrulama döngüsü ilk rapordan sonra güçlenir.';
    }
    int disputed = 0;
    int incomplete = 0;
    for (final JournalEntry entry in _journalEntries) {
      for (final ValidationChoice choice in entry.validations.values) {
        if (choice == ValidationChoice.yanlis) {
          disputed += 1;
        } else if (choice == ValidationChoice.veriYetersiz ||
            choice == ValidationChoice.eksik) {
          incomplete += 1;
        }
      }
    }
    return 'Yanlış: $disputed · Eksik/veri yetersiz: $incomplete';
  }

  /// Rich profile highlights for dashboard
  List<String> get anchorHighlights {
    final OnboardingProfile? p = _profile;
    if (p == null) return const <String>[];
    return p.profileHighlights;
  }

  /// Profile summary text
  String get profileSummary {
    final OnboardingProfile? p = _profile;
    if (p == null) return '';
    return p.generateProfileSummary();
  }

  List<String> get strongestPatternCandidates {
    final Map<String, int> counts = <String, int>{};
    for (final JournalEntry entry in _journalEntries) {
      for (final InsightSignal signal in entry.report.cautionSignals) {
        counts.update(
          signal.title,
          (int value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }
    final List<MapEntry<String, int>> sorted = counts.entries.toList()
      ..sort(
        (MapEntry<String, int> a, MapEntry<String, int> b) =>
            b.value.compareTo(a.value),
      );
    return sorted
        .take(3)
        .map((MapEntry<String, int> entry) => entry.key)
        .toList();
  }

  // ── AI Pipeline Durumu ──
  DeepAnalysisResult? _latestDeepAnalysis;
  bool _aiAnalysisInProgress = false;
  AiEnvelope<UserPsycheAnchor>? _lastMirrorRun;

  DeepAnalysisResult? get latestDeepAnalysis => _latestDeepAnalysis;
  bool get aiAnalysisInProgress => _aiAnalysisInProgress;
  AiEnvelope<UserPsycheAnchor>? get lastMirrorRun => _lastMirrorRun;
  bool get isAIPipelineActive => DeepAnalysisOrchestrator.instance.hasChatAi;
  String get pipelineLabel => DeepAnalysisOrchestrator.instance.pipelineLabel;
  String get personalizationEngineLabel {
    if (DeepAnalysisOrchestrator.instance.hasFullMotor) {
      return 'Tam motor hazır';
    }
    if (DeepAnalysisOrchestrator.instance.hasDeepAnalysisAi) {
      return 'Derin analiz hazır';
    }
    if (DeepAnalysisOrchestrator.instance.hasChatAi) {
      return 'Sohbet AI hazır';
    }
    return 'Temel mod';
  }

  void completeOnboarding(OnboardingProfile profile) {
    _profile = profile;
    notifyListeners();
    // Arka planda derin analiz başlat
    _runDeepProfileAnalysis(profile);
  }

  /// AI pipeline ile derin profil analizi (arka plan)
  Future<void> _runDeepProfileAnalysis(OnboardingProfile profile) async {
    _aiAnalysisInProgress = true;
    notifyListeners();

    try {
      _latestDeepAnalysis =
          await DeepAnalysisOrchestrator.instance.analyzeProfile(profile);
    } catch (e) {
      debugPrint('Derin analiz hatası: $e');
    }

    _aiAnalysisInProgress = false;
    notifyListeners();
  }

  /// AI pipeline yapılandır
  void configureAI({
    String? selfHostedLlmUrl,
    String? selfHostedLlmToken,
    String? geminiApiKey,
    String? huggingFaceApiKey,
    String? supabaseUrl,
    String? supabaseAnonKey,
  }) {
    AIConfig.instance.configure(
      selfHostedLlmUrl: selfHostedLlmUrl,
      selfHostedLlmToken: selfHostedLlmToken,
      geminiApiKey: geminiApiKey,
      huggingFaceApiKey: huggingFaceApiKey,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );
    notifyListeners();

    // Yeniden analiz
    final OnboardingProfile? p = _profile;
    if (p != null) _runDeepProfileAnalysis(p);
  }

  /// Tüm AI anahtarlarını RAM + diskten temizle.
  /// UI katmanında onay alındıktan sonra çağrılmalı.
  Future<void> clearAIKeys() async {
    await AIConfig.instance.clearAll();
    notifyListeners();
  }

  /// Etkileşim kaydı için AI derin analizi
  Future<DeepAnalysisResult?> deepAnalyzeInteraction({
    required String whatHappened,
    required String whatYouFelt,
    required String redFlagNoticed,
    required String greenFlagNoticed,
    required String personLabel,
  }) async {
    final OnboardingProfile? p = _profile;
    if (p == null) return null;

    return DeepAnalysisOrchestrator.instance.analyzeInteraction(
      profile: p,
      whatHappened: whatHappened,
      whatYouFelt: whatYouFelt,
      redFlagNoticed: redFlagNoticed,
      greenFlagNoticed: greenFlagNoticed,
      personLabel: personLabel,
    );
  }

  /// Günlük kayıt için AI derin analizi
  Future<DeepAnalysisResult?> deepAnalyzeDailyCheckIn({
    required String miniReflection,
    required String romanticThought,
    required String moodLabel,
    required List<String> triggerLabels,
  }) async {
    final OnboardingProfile? p = _profile;
    if (p == null) return null;

    return DeepAnalysisOrchestrator.instance.analyzeDailyCheckIn(
      profile: p,
      miniReflection: miniReflection,
      romanticThought: romanticThought,
      moodLabel: moodLabel,
      triggerLabels: triggerLabels,
    );
  }

  /// Kavramsal anlam sorgulama
  Future<String> resolveConceptForUser(String concept) async {
    if (VectorProfileStore.instance.isEmpty) return '';
    return VectorProfileStore.instance.resolveConceptMeaning(concept);
  }

  void switchTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();
  }

  Future<InsightReport> generateReport(ReflectionDraft draft) async {
    final OnboardingProfile activeProfile = _profile!;
    final result = await DeepAnalysisOrchestrator.instance.generateReflectionReport(
      profile: activeProfile,
      draft: draft,
      sessionId: DateTime.now().microsecondsSinceEpoch.toString(),
    );
    return result.payload;
  }

  Future<UserPsycheAnchor> generatePsycheAnchor(OnboardingProfile profile) async {
    final AiEnvelope<UserPsycheAnchor> result =
        await generatePsycheAnchorEnvelope(profile);
    return result.payload;
  }

  Future<AiEnvelope<UserPsycheAnchor>> generatePsycheAnchorEnvelope(
    OnboardingProfile profile,
  ) async {
    final AiEnvelope<UserPsycheAnchor> result =
        await DeepAnalysisOrchestrator.instance.generatePsycheAnchor(profile);
    _lastMirrorRun = result;
    notifyListeners();
    return result;
  }

  List<AdaptiveFollowUpQuestion> buildAdaptiveFollowUps(
    OnboardingProfile profile,
  ) {
    return AdaptiveFollowUpService.buildQuestions(profile);
  }

  void saveValidatedReport({
    required String title,
    required InsightReport report,
    required Map<String, ValidationChoice> validations,
    ValidationFeedback feedback = const ValidationFeedback(),
  }) {
    final InsightReport updatedReport = report.applyValidations(validations);
    final String outcomeLabel = _deriveOutcomeLabel(updatedReport);
    _journalEntries.insert(
      0,
      JournalEntry(
        title: title,
        createdAt: DateTime.now(),
        report: updatedReport,
        outcomeLabel: outcomeLabel,
        pendingCheckIns: const <int>[7, 14],
        validationFeedback: feedback,
        validations: Map<String, ValidationChoice>.unmodifiable(validations),
      ),
    );
    _selectedTab = 0;
    notifyListeners();
  }

  void completeCheckIn({
    required int entryIndex,
    required int day,
    required CheckInOutcome outcome,
    required String interactionState,
    required String consistencyState,
    required String note,
  }) {
    final JournalEntry current = _journalEntries[entryIndex];
    final List<int> pending = current.pendingCheckIns
        .where(
          (int pendingDay) =>
              pendingDay != day &&
              (outcome.keepsFutureCheckIns ? pendingDay > day : false),
        )
        .toList(growable: false);
    final List<CheckInRecord> completed = <CheckInRecord>[
      ...current.completedCheckIns,
      CheckInRecord(
        day: day,
        outcome: outcome,
        interactionState: interactionState,
        consistencyState: consistencyState,
        note: note,
        createdAt: DateTime.now(),
      ),
    ];

    _journalEntries[entryIndex] = current.copyWith(
      pendingCheckIns: pending,
      completedCheckIns: completed,
      outcomeLabel: outcome.label,
    );
    notifyListeners();
  }

  void openJournal() {
    _selectedTab = 2;
    notifyListeners();
  }

  String _deriveOutcomeLabel(InsightReport report) {
    if (report.safetyAssessment.escalated) return 'yeniden gözlenmeli';
    if (report.cautionSignals.isEmpty) return 'olumlu ilerledi';
    if (report.missingDataPoints.isNotEmpty) return 'umut verici ama belirsiz';
    return 'düşük tutarlılık';
  }

  // ══════════════════════════════════════════════
  //  Daily Check-in
  // ══════════════════════════════════════════════

  List<DailyCheckIn> get dailyCheckIns =>
      List<DailyCheckIn>.unmodifiable(_dailyCheckIns);

  DailyCheckIn? get latestDailyCheckIn =>
      _dailyCheckIns.isEmpty ? null : _dailyCheckIns.first;

  bool get hasTodayCheckIn {
    if (_dailyCheckIns.isEmpty) return false;
    final DateTime now = DateTime.now();
    final DailyCheckIn last = _dailyCheckIns.first;
    return last.date.year == now.year &&
        last.date.month == now.month &&
        last.date.day == now.day;
  }

  int get checkInStreak {
    if (_dailyCheckIns.isEmpty) return 0;
    int streak = 1;
    for (int i = 0; i < _dailyCheckIns.length - 1; i++) {
      final DateTime current = _dailyCheckIns[i].date;
      final DateTime previous = _dailyCheckIns[i + 1].date;
      final int diff = current.difference(previous).inDays;
      if (diff <= 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  double get averageMoodLast7Days {
    final List<DailyCheckIn> recent = _dailyCheckIns.take(7).toList();
    if (recent.isEmpty) return 0.5;
    return recent.fold<double>(
            0, (double sum, DailyCheckIn c) => sum + c.mood.numericValue) /
        recent.length;
  }

  Map<EmotionalTrigger, int> get triggerFrequency {
    final Map<EmotionalTrigger, int> counts = <EmotionalTrigger, int>{};
    for (final DailyCheckIn checkIn in _dailyCheckIns.take(14)) {
      for (final EmotionalTrigger trigger in checkIn.triggers) {
        counts.update(trigger, (int v) => v + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  EmotionalTrigger? get mostFrequentTrigger {
    final Map<EmotionalTrigger, int> freq = triggerFrequency;
    if (freq.isEmpty) return null;
    return freq.entries
        .reduce((MapEntry<EmotionalTrigger, int> a,
                MapEntry<EmotionalTrigger, int> b) =>
            a.value >= b.value ? a : b)
        .key;
  }

  double get dailyProgressValue => (_dailyCheckIns.length / 7).clamp(0.0, 1.0);

  String get dailyProgressStage {
    final int count = _dailyCheckIns.length;
    if (count >= 14) return 'Kişisel ritim netleşiyor';
    if (count >= 7) return 'Güçlü günlük örüntü oluşuyor';
    if (count >= 3) return 'İlk desenler görünmeye başladı';
    if (count >= 1) return 'Veri birikiyor';
    return 'Başlangıç';
  }

  String get dailyProgressSummary {
    final int count = _dailyCheckIns.length;
    if (count == 0) {
      return 'İlk günlük kayıtla birlikte ruh hali, tetikleyici ve karar kalıpların görünmeye başlar.';
    }
    if (count < 3) {
      return '$count kayıt var. 3 kayıtta ilk kişisel tekrar sinyallerin görünür hale gelir.';
    }
    if (count < 7) {
      return '$count kayıt var. 7 güne yaklaşırken hangi duygu ve tetikleyicilerin seni sürüklediği daha netleşecek.';
    }
    return '$count kayıt birikti. Artık yalnızca gününü değil, döngülerini de okuyabiliyoruz.';
  }

  String get latestDailyCoachInsight {
    final DailyCheckIn? latest = latestDailyCheckIn;
    if (latest == null) return '';
    if (latest.coachInsight.trim().isNotEmpty) return latest.coachInsight;
    return generateCheckInFeedback();
  }

  String get latestDailyMicroAction {
    final DailyCheckIn? latest = latestDailyCheckIn;
    if (latest != null && latest.microAction.trim().isNotEmpty) {
      return latest.microAction;
    }
    return generateDailyInsight().prompt;
  }

  String get latestDailyPatternNote {
    final DailyCheckIn? latest = latestDailyCheckIn;
    if (latest != null && latest.patternNote.trim().isNotEmpty) {
      return latest.patternNote;
    }
    final EmotionalTrigger? trigger = mostFrequentTrigger;
    if (trigger != null) {
      final int count = triggerFrequency[trigger] ?? 0;
      return count >= 3
          ? '"${trigger.label}" son günlerde tekrar ediyor.'
          : 'Bugünkü kayıt örüntü motoruna eklendi.';
    }
    return 'Bugünkü kayıt örüntü motoruna eklendi.';
  }

  Future<void> saveDailyCheckIn({
    required MoodLevel mood,
    required List<EmotionalTrigger> triggers,
    required EnergyLevel energyLevel,
    required String romanticThought,
    required String miniReflection,
  }) async {
    final DateTime now = DateTime.now();
    _dailyCheckIns.insert(
      0,
      DailyCheckIn(
        date: now,
        mood: mood,
        triggers: triggers,
        energyLevel: energyLevel,
        romanticThought: romanticThought,
        miniReflection: miniReflection,
        readinessSnapshot: _profile?.relationshipReadiness ?? 0,
      ),
    );
    _recordReadinessHistory();
    notifyListeners();

    // Bildirimler
    _checkStreakCelebration();
    _checkPatternAlerts();

    final String combined = '$miniReflection $romanticThought'.trim();
    if (combined.length >= 5) {
      try {
        await VectorProfileStore.instance.embedEntry(
          'gunluk_${now.microsecondsSinceEpoch}',
          combined,
        );
      } catch (e) {
        debugPrint('Günlük vektörleme hatası: $e');
      }
    }

    DeepAnalysisResult? deepResult;
    try {
      deepResult = await deepAnalyzeDailyCheckIn(
        miniReflection: miniReflection,
        romanticThought: romanticThought,
        moodLabel: mood.label,
        triggerLabels: triggers.map((EmotionalTrigger t) => t.label).toList(),
      );
    } catch (e) {
      debugPrint('Günlük derin analiz hatası: $e');
    }

    if (_dailyCheckIns.isEmpty) return;
    final DailyCheckIn current = _dailyCheckIns.first;
    _dailyCheckIns[0] = current.copyWith(
      coachInsight: _composeDailyCoachInsight(
        deepResult: deepResult,
        fallback: generateCheckInFeedback(),
      ),
      microAction: _composeDailyMicroAction(
        deepResult: deepResult,
        mood: mood,
        triggers: triggers,
      ),
      patternNote: _composeDailyPatternNote(
        deepResult: deepResult,
        triggers: triggers,
      ),
      aiEnhanced: deepResult?.isAIEnhanced ?? false,
    );
    notifyListeners();
  }

  /// Kayıt serisi milestonelarında tebrik bildirimi tetikle
  void _checkStreakCelebration() {
    final int streak = checkInStreak;
    if (streak == 3 || streak == 7 || streak == 14 || streak == 30) {
      NotificationService.instance.showStreakCelebration(streak);
    }
  }

  /// Sık tekrar eden tetikleyicilerde döngü uyarısı bildirimi tetikle
  void _checkPatternAlerts() {
    final Map<EmotionalTrigger, int> freq = triggerFrequency;
    for (final MapEntry<EmotionalTrigger, int> entry in freq.entries) {
      if (entry.value >= 4) {
        NotificationService.instance.showPatternAlert(
          patternName: entry.key.label,
          occurrenceCount: entry.value,
        );
        break; // Aynı anda tek uyarı yeter
      }
    }
  }

  // ══════════════════════════════════════════════
  //  Interaction Log
  // ══════════════════════════════════════════════

  List<InteractionLogEntry> get interactionLog =>
      List<InteractionLogEntry>.unmodifiable(_interactionLog);

  int get interactionCount => _interactionLog.length;

  int get uniquePersonCount {
    final Set<String> people = <String>{};
    for (final InteractionLogEntry entry in _interactionLog) {
      if (entry.personLabel.trim().isNotEmpty) {
        people.add(entry.personLabel.trim().toLowerCase());
      }
    }
    return people.length;
  }

  Map<InteractionType, int> get interactionTypeBreakdown {
    final Map<InteractionType, int> counts = <InteractionType, int>{};
    for (final InteractionLogEntry entry in _interactionLog) {
      counts.update(entry.interactionType, (int v) => v + 1,
          ifAbsent: () => 1);
    }
    return counts;
  }

  String generateInteractionInsight(InteractionLogEntry entry) {
    final OnboardingProfile? p = _profile;
    if (p == null) return '';

    final List<String> insights = <String>[];

    if (entry.energy == InteractionEnergy.draining && p.highAssurance) {
      insights.add(
          'Güvence ihtiyacın yüksek ve bu etkileşim seni yormuş. Yorgunluk, güvence açığından mı kaynaklanıyor?');
    }
    if (entry.energy == InteractionEnergy.exciting && p.highIdealization) {
      insights.add(
          'Heyecan güzel ama idealizasyon eğilimin yüksek. Heyecanın somut davranışlara mı yoksa hislere mi dayanıyor?');
    }
    if (entry.redFlagNoticed.trim().isEmpty && p.hasBlindSpot('Uyarı işaretlerini mantığa bürüme')) {
      insights.add(
          'Uyarı işareti görmemişsin — ama profilde uyarı işaretlerini mantığa bürüme eğilimin var. Gerçekten yok mu, yoksa görmek mi istemiyorsun?');
    }
    if (entry.interactionType == InteractionType.thinkingOf &&
        p.hasFastAttachment) {
      insights.add(
          'Sadece düşünmekten etkileşim kaydı açtın — erken bağlanma eğilimin bu tür obsesif düşünceyle beslenebilir.');
    }

    // Etkileşim metinlerini analiz et
    final String combinedText = '${entry.whatHappened} ${entry.whatYouFelt}';
    if (combinedText.trim().length > 15) {
      final TextAnalysisResult textResult =
          TextAnalysisEngine.analyzeDailyText(combinedText);

      if (textResult.idealizationSignals < -1 && !p.highIdealization) {
        insights.add(
            'Bu etkileşim anlatımında idealleştirme sinyalleri var — profilinde bu eğilim düşük çıkmıştı. Belki bu kişiye özgü bir tepki.');
      }
      if (textResult.boundarySignals < -1) {
        insights.add(
            'Anlattıklarında sınır ihlali işaretleri var. Bu durumu net bir şekilde ifade edebildin mi?');
      }
      if (textResult.regulationSignals < -2) {
        insights.add(
            'Bu etkileşimde yoğun duygusal tepkiler yaşamışsın. Bu yoğunluk etkileşimin gerçek doğasını mı yansıtıyor, yoksa senin iç durumunu mu?');
      }
      if (textResult.emotionalTone == EmotionalTone.conflicted) {
        insights.add(
            'Anlattıklarında çelişkili duygular var — bu belirsizlik bazen önemli bir sinyaldir. Çelişkinin kaynağını incelemeye değer.');
      }
    }

    return insights.isEmpty
        ? 'Bu etkileşimi profil metrikleriyle birlikte izlemeye devam ediyoruz.'
        : insights.join(' ');
  }

  Future<void> saveInteraction({
    required String personLabel,
    required InteractionType interactionType,
    required InteractionEnergy energy,
    required String whatHappened,
    required String whatYouFelt,
    required String redFlagNoticed,
    required String greenFlagNoticed,
  }) async {
    final InteractionLogEntry entry = InteractionLogEntry(
      date: DateTime.now(),
      personLabel: personLabel,
      interactionType: interactionType,
      energy: energy,
      whatHappened: whatHappened,
      whatYouFelt: whatYouFelt,
      redFlagNoticed: redFlagNoticed,
      greenFlagNoticed: greenFlagNoticed,
    );
    final String fallbackInsight = generateInteractionInsight(entry);
    _interactionLog.insert(0, entry.copyWith(profileInsight: fallbackInsight));
    notifyListeners();

    final String combined = '$whatHappened $whatYouFelt'.trim();
    if (combined.length >= 5) {
      try {
        await VectorProfileStore.instance.embedEntry(
          'interaction_${entry.date.microsecondsSinceEpoch}',
          combined,
        );
      } catch (e) {
        debugPrint('Etkileşim vektörleme hatası: $e');
      }
    }

    DeepAnalysisResult? deepResult;
    try {
      deepResult = await deepAnalyzeInteraction(
        whatHappened: whatHappened,
        whatYouFelt: whatYouFelt,
        redFlagNoticed: redFlagNoticed,
        greenFlagNoticed: greenFlagNoticed,
        personLabel: personLabel,
      );
    } catch (e) {
      debugPrint('Etkileşim derin analiz hatası: $e');
    }

    if (_interactionLog.isEmpty) return;
    _interactionLog[0] = _interactionLog.first.copyWith(
      profileInsight: _composeInteractionInsight(
        fallbackInsight: fallbackInsight,
        deepResult: deepResult,
      ),
      aiEnhanced: deepResult?.isAIEnhanced ?? false,
    );
    notifyListeners();
  }

  // ══════════════════════════════════════════════
  //  Profile Update
  // ══════════════════════════════════════════════

  void updateProfile(OnboardingProfile updatedProfile) {
    _profile = updatedProfile;
    _recordReadinessHistory();
    notifyListeners();
  }

  // ══════════════════════════════════════════════
  //  Readiness Evolution Tracking
  // ══════════════════════════════════════════════

  List<ReadinessHistoryPoint> get readinessHistory =>
      List<ReadinessHistoryPoint>.unmodifiable(_readinessHistory);

  void _recordReadinessHistory() {
    final OnboardingProfile? p = _profile;
    if (p == null) return;
    _readinessHistory.add(ReadinessHistoryPoint(
      date: DateTime.now(),
      readiness: p.relationshipReadiness,
      idealization: p.idealizationScore,
      boundary: p.boundaryHealthScore,
      selfAwareness: p.selfAwarenessScore,
      emotionalRegulation: p.emotionalRegulationScore,
    ));
  }

  // ══════════════════════════════════════════════
  //  Günlük Kayıt Geri Bildirimi — Somut Çıktı
  // ══════════════════════════════════════════════

  /// Kayıt sonrası kullanıcıya gösterilen kişiselleştirilmiş geri bildirim
  String generateCheckInFeedback() {
    if (_dailyCheckIns.isEmpty) return '';
    final DailyCheckIn latest = _dailyCheckIns.first;
    final OnboardingProfile? p = _profile;
    final List<String> feedback = <String>[];

    // Ruh hali trendi
    if (_dailyCheckIns.length >= 3) {
      final List<double> moods = _dailyCheckIns
          .take(3)
          .map((DailyCheckIn c) => _moodToDouble(c.mood))
          .toList();
      if (moods[0] > moods[1] && moods[1] > moods[2]) {
        feedback.add('Son 3 gündür ruh halin sürekli yükseliyor — bu olumlu bir ivme.');
      } else if (moods[0] < moods[1] && moods[1] < moods[2]) {
        feedback.add('Son 3 gündür ruh halin düşüşte. Kendine nazik ol, bu geçici.');
      }
    }

    // Tetikleyici uyarı
    if (latest.triggers.isNotEmpty && p != null) {
      final EmotionalTrigger first = latest.triggers.first;
      final int repeatCount = _dailyCheckIns
          .take(7)
          .where((DailyCheckIn c) => c.triggers.contains(first))
          .length;
      if (repeatCount >= 3) {
        feedback.add('"${first.label}" tetikleyicisi son 7 günde $repeatCount kez tekrarlandı. Bu kalıba dikkat et.');
      }
    }

    // Profil bazlı geri bildirim
    if (p != null) {
      if (latest.mood == MoodLevel.bad && p.highAssurance) {
        feedback.add('Kötü hissettiğin günlerde güvence arama eğilimin artabilir. Bugün birine mesaj atmadan önce bir nefes al.');
      }
      if (latest.mood == MoodLevel.great && p.highIdealization) {
        feedback.add('Harika hissettiğin günlerde idealleştirme eğilimin güçlenir. İyi hissetmek iyi — ama birini abartmak riskli.');
      }
      if (latest.energyLevel == EnergyLevel.low && p.selfProtectionScore > 0.5) {
        feedback.add('Enerjin düşükken geri çekilme eğilimin güçlenir. Bu koruma refleksi mi, yoksa gerçekten dinlenme ihtiyacı mı?');
      }
    }

    // Kısa yansıtma metnini analiz et
    if (latest.miniReflection.trim().length > 10) {
      final TextAnalysisResult textResult =
          TextAnalysisEngine.analyzeDailyText(latest.miniReflection);

      if (textResult.attachmentSignals < -1) {
        feedback.add('Bugünkü yansıtmanda bağlanma sinyalleri var. Hızlı bağlanma eğilimine dikkat — bir adım geri çekil ve gözlemle.');
      }
      if (textResult.dependencySignals < -1) {
        feedback.add('Yazdıklarında duygusal bağımlılık işaretleri var. Ruh halin birinin davranışına ne kadar bağlı?');
      }
      if (textResult.emotionalTone == EmotionalTone.anxious) {
        feedback.add('Bugünkü yansıtmanda kaygı tonu belirgin. Bu kaygının kaynağını netleştir: gerçek bir tehdit mi, yoksa içsel bir kalıp mı?');
      }
      if (textResult.selfAwarenessSignals > 1) {
        feedback.add('Bugünkü yansıtmanda güçlü bir öz farkındalık var. Bu tür dürüst anlar profil doğruluğunu artırır.');
      }
      if (textResult.emotionalTone == EmotionalTone.reflective) {
        feedback.add('Yansıtıcı bir yazı yazmışsın — bu tür içsel gözlemler zamanla kalıplarını daha net görmeni sağlar.');
      }
    }

    // Romantik düşünce metnini analiz et
    if (latest.romanticThought.trim().length > 10) {
      final TextAnalysisResult thoughtResult =
          TextAnalysisEngine.analyzeDailyText(latest.romanticThought);

      if (thoughtResult.idealizationSignals < -1) {
        feedback.add('Bugünkü romantik düşüncende idealleştirme eğilimi var. Bu kişiyi gerçek haliyle mi yoksa hayal ettiğin haliyle mi görüyorsun?');
      }
      if (thoughtResult.protectionSignals < -1) {
        feedback.add('Romantik düşüncende kaçınma veya kendini koruma sinyalleri var. Korkuyla mı yoksa tercihle mi uzak duruyorsun?');
      }
    }

    if (feedback.isEmpty) {
      feedback.add('Bugünkü kaydın alındı. Verini biriktirdikçe sana daha derin geri bildirimler gelecek.');
    }

    return feedback.join('\n\n');
  }

  /// Haftalık ruh hali özeti
  String get weeklyMoodSummary {
    if (_dailyCheckIns.isEmpty) return 'Henüz yeterli veri yok.';
    final List<DailyCheckIn> week = _dailyCheckIns.take(7).toList();
    int great = 0, good = 0, neutral = 0, low = 0, bad = 0;
    for (final DailyCheckIn c in week) {
      switch (c.mood) {
        case MoodLevel.great: great++;
        case MoodLevel.good: good++;
        case MoodLevel.neutral: neutral++;
        case MoodLevel.low: low++;
        case MoodLevel.bad: bad++;
      }
    }
    final StringBuffer sb = StringBuffer();
    sb.write('Son ${week.length} günde: ');
    final List<String> parts = <String>[];
    if (great > 0) parts.add('$great harika');
    if (good > 0) parts.add('$good iyi');
    if (neutral > 0) parts.add('$neutral nötr');
    if (low > 0) parts.add('$low düşük');
    if (bad > 0) parts.add('$bad kötü');
    sb.write(parts.join(', '));
    sb.write(' gün yaşadın.');
    if (low + bad > great + good) {
      sb.write(' Zor bir hafta geçiriyorsun — kendine alan tanı.');
    } else if (great + good >= 5) {
      sb.write(' Güçlü bir hafta — bu enerjiyi koru.');
    }
    return sb.toString();
  }

  /// Günlük olumlaması — profil bazlı
  String get dailyAffirmation {
    final OnboardingProfile? p = _profile;
    if (p == null) return 'Bugün kendine bir iyilik yap.';
    final int day = DateTime.now().day + DateTime.now().month * 31;
    final List<String> affirmations = <String>[
      'Sınırlarını bilmek güç değil, olgunluk. Bugün sınırlarına sahip çık.',
      'Doğru kişiyi bulmak acele gerektirmez. Bugün kendini tanımaya devam et.',
      'Duygularını bastırmak yerine onları dinle. Ne söylüyorlar?',
      'Her "hayır" bir "evet"e yer açar. Bugün neye "hayır" demen gerekiyor?',
      'Mükemmel ilişki yoktur, uyumlu ilişki vardır. Uyumu nasıl tanımlıyorsun?',
      'Geçmiş kalıpların gelecek kararlarını belirlemek zorunda değil.',
      'Kendini tanımak, doğru kişiyi tanımanın ilk adımı.',
      'Bugün acele etme. Doğru tempo senin tempondur.',
    ];
    if (p.highIdealization) {
      affirmations.add('Bugün birini olduğu gibi gör — potansiyeliyle değil, bugünkü haliyle.');
    }
    if (p.highAssurance) {
      affirmations.add('Güvenlik önce içeriden gelir. Bugün kendi kendine güvence ver.');
    }
    return affirmations[day % affirmations.length];
  }

  String _composeDailyCoachInsight({
    required String fallback,
    DeepAnalysisResult? deepResult,
  }) {
    final List<String> parts = <String>[];
    if (deepResult != null) {
      if (deepResult.profileInsight.trim().isNotEmpty) {
        parts.add(deepResult.profileInsight.trim());
      }
      if (deepResult.blindSpotWarning.trim().isNotEmpty) {
        parts.add('Dikkat noktası: ${deepResult.blindSpotWarning.trim()}');
      }
    }
    if (parts.isEmpty && fallback.trim().isNotEmpty) {
      return fallback.trim();
    }
    return parts.take(2).join('\n\n');
  }

  String _composeDailyMicroAction({
    required MoodLevel mood,
    required List<EmotionalTrigger> triggers,
    DeepAnalysisResult? deepResult,
  }) {
    if (deepResult != null && deepResult.personalizedAdvice.trim().isNotEmpty) {
      return deepResult.personalizedAdvice.trim();
    }
    if (triggers.contains(EmotionalTrigger.anxiety)) {
      return 'Bugün belirsizliği büyütmek yerine tek bir somut veri not et ve hikayeyi durdur.';
    }
    if (triggers.contains(EmotionalTrigger.loneliness)) {
      return 'Bugün yakınlık arzusunu bir kişiye yüklemek yerine kendine iyi gelen tek bir temas seç.';
    }
    if (mood == MoodLevel.bad || mood == MoodLevel.low) {
      return 'Bugün karar verme değil, sinyal toplama günü olsun. Yavaşla ve kendini regüle et.';
    }
    return generateDailyInsight().prompt;
  }

  String _composeDailyPatternNote({
    required List<EmotionalTrigger> triggers,
    DeepAnalysisResult? deepResult,
  }) {
    if (deepResult != null && deepResult.blindSpotWarning.trim().isNotEmpty) {
      return deepResult.blindSpotWarning.trim();
    }
    final EmotionalTrigger? repeated = mostFrequentTrigger;
    if (repeated != null) {
      final int count = triggerFrequency[repeated] ?? 0;
      if (count >= 3) {
        return '"${repeated.label}" son günlerde $count kez tekrar etti.';
      }
    }
    if (triggers.isNotEmpty) {
      return 'Bugünkü kayıt "${triggers.first.label}" hattına eklendi.';
    }
    return 'Bugünkü kayıt örüntü motoruna eklendi.';
  }

  String _composeInteractionInsight({
    required String fallbackInsight,
    DeepAnalysisResult? deepResult,
  }) {
    final List<String> parts = <String>[];
    if (deepResult != null) {
      if (deepResult.profileInsight.trim().isNotEmpty) {
        parts.add(deepResult.profileInsight.trim());
      }
      if (deepResult.blindSpotWarning.trim().isNotEmpty) {
        parts.add('Kör nokta: ${deepResult.blindSpotWarning.trim()}');
      }
      if (deepResult.personalizedAdvice.trim().isNotEmpty) {
        parts.add('Öneri: ${deepResult.personalizedAdvice.trim()}');
      }
    }
    if (parts.isEmpty) return fallbackInsight;
    return parts.take(3).join('\n\n');
  }

  static double _moodToDouble(MoodLevel mood) => switch (mood) {
        MoodLevel.great => 1.0,
        MoodLevel.good => 0.75,
        MoodLevel.neutral => 0.5,
        MoodLevel.low => 0.25,
        MoodLevel.bad => 0.0,
      };

  // ══════════════════════════════════════════════
  //  Günlük İçgörü Üretici (Profil Kişiselleştirilmiş)
  // ══════════════════════════════════════════════

  DailyInsight generateDailyInsight() {
    final OnboardingProfile? p = _profile;
    final DateTime now = DateTime.now();
    if (p == null) {
      return DailyInsight(
        date: now,
        prompt: 'Profilini tamamla — günlük içgörüler sana özel olsun.',
        category: 'genel',
        relatedProfileArea: 'profil',
      );
    }

    final int dayHash =
        now.day + now.month * 31 + _dailyCheckIns.length;
    final List<DailyInsight> pool = <DailyInsight>[
      if (p.highIdealization)
        DailyInsight(
          date: now,
          prompt:
              'Bugün birine "mükemmel" dediğini fark edersen dur. Bu kişinin 3 kusurunu say — sayamıyorsan, idealizasyon devrede.',
          category: 'İnanç',
          relatedProfileArea: 'İdealizasyon: ${(p.idealizationScore * 100).toStringAsFixed(0)}%',
        ),
      if (p.highAssurance)
        DailyInsight(
          date: now,
          prompt:
              'Güvence ihtiyacın bugün ne kadar yüksek? 1-10 arası puanla. 7\'den yüksekse, bu ihtiyaç kimin sorumluluğu?',
          category: 'Güvence',
          relatedProfileArea: 'Güvence: ${p.assuranceNeed.label}',
        ),
      if (p.hasFastAttachment)
        DailyInsight(
          date: now,
          prompt:
              'Bugün birini fazla mı düşündün? Düşünme sıklığın ilgi seviyeni yansıtmıyor — bağlanma hızını yansıtıyor.',
          category: 'Bağlanma',
          relatedProfileArea: 'Kör nokta: erken bağlanma',
        ),
      if (p.boundaryHealthScore < 0.5)
        DailyInsight(
          date: now,
          prompt:
              'Bugün "hayır" demek isteyip "evet" dediğin bir an oldu mu? Küçük sınır ihlalleri büyüklerin provası.',
          category: 'Sınır',
          relatedProfileArea: 'Sınır sağlığı: ${(p.boundaryHealthScore * 100).toStringAsFixed(0)}%',
        ),
      if (p.selfProtectionScore > 0.5)
        DailyInsight(
          date: now,
          prompt:
              'Bugün birinden kaçındığını fark ettin mi? Kaçınma güvenlik değil — yakınlıktan korkmanın bir formu.',
          category: 'Kendini Koruma',
          relatedProfileArea: 'Koruma refleksi: ${(p.selfProtectionScore * 100).toStringAsFixed(0)}%',
        ),
      if (p.emotionalDependencyRisk > 0.4)
        DailyInsight(
          date: now,
          prompt:
              'Bugün ruh halin birinin davranışına bağlı mıydı? Bağlıysa, duygusal bağımsızlığın sınırlarını test ediyorsun.',
          category: 'Bağımsızlık',
          relatedProfileArea: 'Bağımlılık riski: ${(p.emotionalDependencyRisk * 100).toStringAsFixed(0)}%',
        ),
      if (p.conflictStyle == ConflictStyle.shutDown ||
          p.conflictStyle == ConflictStyle.distance)
        DailyInsight(
          date: now,
          prompt:
              'Bugün rahatsız eden bir konuyu atlattığını fark ettin mi? Geçiştirmek çözüm değil, erteleme.',
          category: 'İletişim',
          relatedProfileArea: 'Çatışma stili: ${p.conflictStyle.label}',
        ),
      DailyInsight(
        date: now,
        prompt:
            'Bugün kendine sor: "İlişkide en çok neyi arıyorum?" Cevabın geçen haftakinden farklı mı?',
        category: 'Öz Farkındalık',
        relatedProfileArea: 'Hedef: ${p.goal.label}',
      ),
      DailyInsight(
        date: now,
        prompt:
            'Son etkileşiminde hangi duyguyu en çok hissettin? Bu duygu sana bir şey söylüyor — dinle.',
        category: 'Duygu Düzenleme',
        relatedProfileArea: 'Düzenleme: ${(p.emotionalRegulationScore * 100).toStringAsFixed(0)}%',
      ),
      DailyInsight(
        date: now,
        prompt:
            'Bugün birine mesaj atıp atmamayı düşündün mü? Düşündüysen, motivasyonun ne: gerçek ilgi mi, kontrol ihtiyacı mı?',
        category: 'İletişim',
        relatedProfileArea: 'İletişim: ${p.communicationPreference.label}',
      ),
    ];

    return pool[dayHash % pool.length];
  }
}
