import 'package:flutter/foundation.dart';

import 'mock_analysis_engine.dart';
import 'models.dart';

class MatchProfileController extends ChangeNotifier {
  MatchProfileController();

  OnboardingProfile? _profile;
  int _selectedTab = 0;
  final List<JournalEntry> _journalEntries = <JournalEntry>[];

  OnboardingProfile? get profile => _profile;
  int get selectedTab => _selectedTab;
  bool get hasCompletedOnboarding => _profile != null;
  List<JournalEntry> get journalEntries =>
      List<JournalEntry>.unmodifiable(_journalEntries);

  int get pendingCheckInCount => _journalEntries.fold<int>(
    0,
    (sum, entry) => sum + entry.pendingCheckIns.length,
  );

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
    if (counts.isEmpty) {
      return 'Henüz örüntü oluşmadı';
    }
    final MapEntry<String, int> top = counts.entries.reduce(
      (MapEntry<String, int> a, MapEntry<String, int> b) =>
          a.value >= b.value ? a : b,
    );
    return '${top.key} • ${top.value} oturum';
  }

  String get missingDataSnapshot {
    if (_journalEntries.isEmpty) {
      return 'İlk reflection sonrasında eksik veri alanları burada görünür.';
    }
    final JournalEntry latest = _journalEntries.first;
    if (latest.report.missingDataPoints.isEmpty) {
      return 'Son oturumda kritik eksik veri yok.';
    }
    return latest.report.missingDataPoints.first;
  }

  void completeOnboarding(OnboardingProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void switchTab(int index) {
    if (_selectedTab == index) {
      return;
    }
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
      ),
    );
    _selectedTab = 0;
    notifyListeners();
  }

  void openJournal() {
    _selectedTab = 1;
    notifyListeners();
  }

  String _deriveOutcomeLabel(InsightReport report) {
    if (report.safetyAssessment.escalated) {
      return 'yeniden gözlenmeli';
    }
    if (report.cautionSignals.isEmpty) {
      return 'olumlu ilerledi';
    }
    if (report.missingDataPoints.isNotEmpty) {
      return 'umut verici ama belirsiz';
    }
    return 'düşük tutarlılık';
  }
}
