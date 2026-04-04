import 'package:flutter/foundation.dart';

import 'mock_analysis_engine.dart';
import 'models.dart';

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
      return 'İlk reflection sonrasında eksik veri alanları burada görünür.';
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
      return '${task.title} için ${task.day}. gün outcome check seni bekliyor.';
    }
    final JournalEntry? entry = latestEntry;
    if (entry == null) {
      return 'Romantik karar profilin hazır. Şimdi ilk reflection ile kişiselleştirilmiş insight akışını başlat.';
    }
    return entry.report.nextStep;
  }

  String get latestOutcomeSnapshot {
    final JournalEntry? entry = latestEntry;
    if (entry == null) return 'Henüz outcome verisi yok.';
    if (entry.completedCheckIns.isEmpty) {
      return 'İlk outcome check henüz tamamlanmadı.';
    }
    final CheckInRecord latest = entry.completedCheckIns.last;
    return '${latest.day}. gün: ${latest.outcome.label}';
  }

  String get evidenceMixSnapshot {
    final JournalEntry? entry = latestEntry;
    if (entry == null) return 'İlk raporla evidence dağılımı görünecek.';
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
      return 'Validation loop ilk reporttan sonra güçlenir.';
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

  void completeOnboarding(OnboardingProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void switchTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();
  }

  InsightReport generateReport(ReflectionDraft draft) {
    final OnboardingProfile activeProfile = _profile!;
    return MockAnalysisEngine.build(
      draft: draft,
      profile: activeProfile,
      sessionId: DateTime.now().microsecondsSinceEpoch.toString(),
    );
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

  void saveDailyCheckIn({
    required MoodLevel mood,
    required List<EmotionalTrigger> triggers,
    required EnergyLevel energyLevel,
    required String romanticThought,
    required String miniReflection,
  }) {
    _dailyCheckIns.insert(
      0,
      DailyCheckIn(
        date: DateTime.now(),
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
    if (entry.redFlagNoticed.trim().isEmpty && p.hasBlindSpot('Red flag\'i rasyonalize etme')) {
      insights.add(
          'Red flag görmemişsin — ama profilde red flag rasyonalize etme eğilimin var. Gerçekten yok mu, yoksa görmek mi istemiyorsun?');
    }
    if (entry.interactionType == InteractionType.thinkingOf &&
        p.hasFastAttachment) {
      insights.add(
          'Sadece düşünmekten etkileşim kaydı açtın — erken bağlanma eğilimin bu tür obsesif düşünceyle beslenebilir.');
    }

    return insights.isEmpty
        ? 'Bu etkileşimi profil metrikleriyle birlikte izlemeye devam ediyoruz.'
        : insights.join(' ');
  }

  void saveInteraction({
    required String personLabel,
    required InteractionType interactionType,
    required InteractionEnergy energy,
    required String whatHappened,
    required String whatYouFelt,
    required String redFlagNoticed,
    required String greenFlagNoticed,
  }) {
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
    // Generate insight and re-create with it
    final String insight = generateInteractionInsight(entry);
    _interactionLog.insert(
      0,
      InteractionLogEntry(
        date: entry.date,
        personLabel: entry.personLabel,
        interactionType: entry.interactionType,
        energy: entry.energy,
        whatHappened: entry.whatHappened,
        whatYouFelt: entry.whatYouFelt,
        redFlagNoticed: entry.redFlagNoticed,
        greenFlagNoticed: entry.greenFlagNoticed,
        profileInsight: insight,
      ),
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
  //  Daily Insight Generator (Profile-Personalized)
  // ══════════════════════════════════════════════

  DailyInsight generateDailyInsight() {
    final OnboardingProfile? p = _profile;
    if (p == null) {
      return const DailyInsight(
        date: null ?? Duration.zero != Duration.zero
            ? DateTime(2024)
            : DateTime(2024),
        prompt: 'Profilini tamamla — günlük içgörüler sana özel olsun.',
        category: 'genel',
        relatedProfileArea: 'profil',
      );
    }

    final int dayHash =
        DateTime.now().day + DateTime.now().month * 31 + _dailyCheckIns.length;
    final List<DailyInsight> pool = <DailyInsight>[
      if (p.highIdealization)
        DailyInsight(
          date: DateTime.now(),
          prompt:
              'Bugün birine "mükemmel" dediğini fark edersen dur. Bu kişinin 3 kusurunu say — sayamıyorsan, idealizasyon devrede.',
          category: 'İnanç',
          relatedProfileArea: 'İdealizasyon: ${(p.idealizationScore * 100).toStringAsFixed(0)}%',
        ),
      if (p.highAssurance)
        DailyInsight(
          date: DateTime.now(),
          prompt:
              'Güvence ihtiyacın bugün ne kadar yüksek? 1-10 arası puanla. 7\'den yüksekse, bu ihtiyaç kimin sorumluluğu?',
          category: 'Güvence',
          relatedProfileArea: 'Güvence: ${p.assuranceNeed.label}',
        ),
      if (p.hasFastAttachment)
        DailyInsight(
          date: DateTime.now(),
          prompt:
              'Bugün birini fazla mı düşündün? Düşünme sıklığın ilgi seviyeni yansıtmıyor — bağlanma hızını yansıtıyor.',
          category: 'Bağlanma',
          relatedProfileArea: 'Kör nokta: erken bağlanma',
        ),
      if (p.boundaryHealthScore < 0.5)
        DailyInsight(
          date: DateTime.now(),
          prompt:
              'Bugün "hayır" demek isteyip "evet" dediğin bir an oldu mu? Küçük sınır ihlalleri büyüklerin provası.',
          category: 'Sınır',
          relatedProfileArea: 'Sınır sağlığı: ${(p.boundaryHealthScore * 100).toStringAsFixed(0)}%',
        ),
      if (p.selfProtectionScore > 0.5)
        DailyInsight(
          date: DateTime.now(),
          prompt:
              'Bugün birinden kaçındığını fark ettin mi? Kaçınma güvenlik değil — yakınlıktan korkmanın bir formu.',
          category: 'Kendini Koruma',
          relatedProfileArea: 'Koruma refleksi: ${(p.selfProtectionScore * 100).toStringAsFixed(0)}%',
        ),
      if (p.emotionalDependencyRisk > 0.4)
        DailyInsight(
          date: DateTime.now(),
          prompt:
              'Bugün ruh halin birinin davranışına bağlı mıydı? Bağlıysa, duygusal bağımsızlığın sınırlarını test ediyorsun.',
          category: 'Bağımsızlık',
          relatedProfileArea: 'Bağımlılık riski: ${(p.emotionalDependencyRisk * 100).toStringAsFixed(0)}%',
        ),
      if (p.conflictStyle == ConflictStyle.shutDown ||
          p.conflictStyle == ConflictStyle.distance)
        DailyInsight(
          date: DateTime.now(),
          prompt:
              'Bugün rahatsız eden bir konuyu atlattığını fark ettin mi? Geçiştirmek çözüm değil, erteleme.',
          category: 'İletişim',
          relatedProfileArea: 'Çatışma stili: ${p.conflictStyle.label}',
        ),
      DailyInsight(
        date: DateTime.now(),
        prompt:
            'Bugün kendine sor: "İlişkide en çok neyi arıyorum?" Cevabın geçen haftakinden farklı mı?',
        category: 'Öz Farkındalık',
        relatedProfileArea: 'Hedef: ${p.goal.label}',
      ),
      DailyInsight(
        date: DateTime.now(),
        prompt:
            'Son etkileşiminde hangi duyguyu en çok hissettin? Bu duygu sana bir şey söylüyor — dinle.',
        category: 'Duygu Düzenleme',
        relatedProfileArea: 'Düzenleme: ${(p.emotionalRegulationScore * 100).toStringAsFixed(0)}%',
      ),
      DailyInsight(
        date: DateTime.now(),
        prompt:
            'Bugün birine mesaj atıp atmamayı düşündün mü? Düşündüysen, motivasyonun ne: gerçek ilgi mi, kontrol ihtiyacı mı?',
        category: 'İletişim',
        relatedProfileArea: 'İletişim: ${p.communicationPreference.label}',
      ),
    ];

    return pool[dayHash % pool.length];
  }
}
