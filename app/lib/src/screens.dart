import 'package:flutter/material.dart';

import 'controller.dart';
import 'models.dart';

class MatchProfileHome extends StatefulWidget {
  const MatchProfileHome({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  State<MatchProfileHome> createState() => _MatchProfileHomeState();
}

class _MatchProfileHomeState extends State<MatchProfileHome> {
  bool _showOnboarding = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? _) {
        if (!widget.controller.hasCompletedOnboarding) {
          if (_showOnboarding) {
            return OnboardingPage(
              controller: widget.controller,
              onComplete: () => setState(() {}),
            );
          }
          return WelcomePage(
            onStart: () => setState(() => _showOnboarding = true),
          );
        }

        return AppShell(controller: widget.controller);
      },
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFF8F1E8), Color(0xFFE7F0EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('Build-ready beta'),
                  ),
                ),
                const Spacer(),
                Text(
                  'Date sonrası\n daha net düşün.',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'MatchProfile bir dating app değil. Buluşma sonrasındaki duygusal gürültüyü azaltıp kararını daha açıklanabilir hale getiren kişisel reflection app’i.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const <Widget>[
                    _InfoChip(label: 'Dating app değil'),
                    _InfoChip(label: 'Nihai karar vermez'),
                    _InfoChip(label: '18+'),
                    _InfoChip(label: 'Skorsuz değerlendirme'),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Text(
                          'Bu ilk build ne içeriyor?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Onboarding, reflection flow, insight report, validation ve journal.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('welcome_start_button'),
                  onPressed: onStart,
                  child: const Text('Başla'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.controller,
    required this.onComplete,
  });

  final MatchProfileController controller;
  final VoidCallback onComplete;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valuesController = TextEditingController(
    text: 'dürüstlük, duygusal olgunluk, net iletişim',
  );
  final TextEditingController _dealbreakersController = TextEditingController(
    text: 'tutarsızlık, manipülasyon',
  );
  final Set<String> _biasFlags = <String>{'red flag rasyonalize etme'};
  RelationshipGoal? _goal = RelationshipGoal.serious;
  bool _highSafetySensitivity = true;
  bool _ageConfirmed = false;
  bool _policyAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _valuesController.dispose();
    _dealbreakersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit =
        _nameController.text.trim().isNotEmpty &&
        _goal != null &&
        _ageConfirmed &&
        _policyAccepted;

    return Scaffold(
      appBar: AppBar(title: const Text('Kalibrasyon')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: <Widget>[
            Text(
              'İlk reflection’ları daha kişisel hale getirelim.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Bu bilgiler daha sonra evidence model, confidence labels ve next-step önerilerini tonlamaya yardım eder.',
            ),
            const SizedBox(height: 24),
            TextField(
              key: const Key('onboarding_name_field'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Sana nasıl hitap edelim?',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text(
              'İlişki hedefi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RelationshipGoal.values
                  .map((RelationshipGoal goal) {
                    return ChoiceChip(
                      key: Key('onboarding_goal_${goal.name}'),
                      label: Text(goal.label),
                      selected: _goal == goal,
                      onSelected: (_) => setState(() => _goal = goal),
                    );
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valuesController,
              decoration: const InputDecoration(
                labelText: 'Vazgeçilmez 3 değer',
                helperText: 'Virgülle ayırabilirsin',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dealbreakersController,
              decoration: const InputDecoration(
                labelText: 'Dealbreaker alanları',
                helperText: 'Virgülle ayırabilirsin',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kendine dair bias flag’leri',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  const <String>[
                        'yüksek çekimi uyum sanma',
                        'erken bağlanma',
                        'red flag rasyonalize etme',
                        'çok hızlı eleme',
                      ]
                      .map((String flag) {
                        return FilterChip(
                          label: Text(flag),
                          selected: _biasFlags.contains(flag),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _biasFlags.add(flag);
                              } else {
                                _biasFlags.remove(flag);
                              }
                            });
                          },
                        );
                      })
                      .toList(growable: false),
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              value: _highSafetySensitivity,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Sınır ve güvenlik konularında yüksek hassasiyet',
              ),
              subtitle: const Text(
                'Güvenlik sinyalleri daha erken öne çıkarılsın',
              ),
              onChanged: (bool value) =>
                  setState(() => _highSafetySensitivity = value),
            ),
            CheckboxListTile(
              key: const Key('onboarding_age_checkbox'),
              value: _ageConfirmed,
              contentPadding: EdgeInsets.zero,
              title: const Text('18 yaşından büyüğüm'),
              onChanged: (bool? value) =>
                  setState(() => _ageConfirmed = value ?? false),
            ),
            CheckboxListTile(
              key: const Key('onboarding_policy_checkbox'),
              value: _policyAccepted,
              contentPadding: EdgeInsets.zero,
              title: const Text('KVKK ve beta koşullarını kabul ediyorum'),
              onChanged: (bool? value) =>
                  setState(() => _policyAccepted = value ?? false),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('onboarding_complete_button'),
              onPressed: canSubmit ? _submit : null,
              child: const Text('Kalibrasyonu tamamla'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    widget.controller.completeOnboarding(
      OnboardingProfile(
        displayName: _nameController.text.trim(),
        goal: _goal!,
        values: _splitCsv(_valuesController.text),
        dealbreakers: _splitCsv(_dealbreakersController.text),
        biasFlags: _biasFlags.toList(growable: false),
        highSafetySensitivity: _highSafetySensitivity,
        ageConfirmed: _ageConfirmed,
        policyAccepted: _policyAccepted,
      ),
    );
    widget.onComplete();
  }

  List<String> _splitCsv(String value) {
    return value
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      DashboardPage(controller: controller),
      JournalPage(controller: controller),
      SettingsPage(controller: controller),
    ];

    return Scaffold(
      body: SafeArea(child: pages[controller.selectedTab]),
      floatingActionButton: controller.selectedTab == 0
          ? FloatingActionButton.extended(
              key: const Key('new_reflection_button'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        ReflectionComposerPage(controller: controller),
                  ),
                );
              },
              label: const Text('Yeni değerlendirme'),
              icon: const Icon(Icons.mic_none_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: controller.selectedTab,
        onDestinationSelected: controller.switchTab,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('dashboard_screen'),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      children: <Widget>[
        Text('Netlik Özeti', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Merhaba ${controller.profile?.displayName ?? ''}. Skor yerine açıklanabilir sinyaller görüyoruz.',
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Son oturum özeti',
          child: Text(
            controller.journalEntries.isEmpty
                ? 'Henüz kayıtlı bir reflection yok. İlk session bu alanı dolduracak.'
                : controller.journalEntries.first.report.summary,
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Bekleyen check-in’ler',
          trailing: Text('${controller.pendingCheckInCount} açık'),
          child: Text(
            controller.pendingCheckInCount == 0
                ? 'İlk kayıttan sonra 7 ve 14. gün check-in’leri burada listelenecek.'
                : 'Bu build’de check-in’ler journal kayıtları üzerinden takip ediliyor.',
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Tekrar eden sinyal',
          child: Text(controller.repeatedSignalSnapshot),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'En sık eksik kalan veri',
          child: Text(controller.missingDataSnapshot),
        ),
      ],
    );
  }
}

class JournalPage extends StatelessWidget {
  const JournalPage({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      children: <Widget>[
        Text('Journal', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text(
          'Buluşma geçmişi ikili başarı/başarısız etiketleriyle değil, açıklanabilir outcome diliyle saklanır.',
        ),
        const SizedBox(height: 24),
        if (controller.journalEntries.isEmpty)
          const _SectionCard(
            title: 'Henüz kayıt yok',
            child: Text('İlk reflection sonrasında history burada oluşacak.'),
          )
        else
          ...controller.journalEntries.map(
            (JournalEntry entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              entry.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          _Tag(text: entry.outcomeLabel),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(entry.report.summary),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.pendingCheckIns
                            .map((int day) => _Tag(text: '$day. gün check-in'))
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      children: const <Widget>[
        Text(
          'Privacy & Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 20),
        _SectionCard(
          title: 'Retention policy',
          child: Text(
            'Ses kayıtları varsayılan olarak 30 gün tutulur. Ham transcript ve temiz özet kullanıcı silene kadar saklanabilir. Deletion request ve audit flow backlog’da hazır.',
          ),
        ),
        SizedBox(height: 16),
        _SectionCard(
          title: 'Beta policy',
          child: Text(
            'Bu build, 18+ gate, KVKK öncelikli politika seti ve App Store / Google Play release hazırlığı düşünülerek kuruluyor.',
          ),
        ),
      ],
    );
  }
}

class ReflectionComposerPage extends StatefulWidget {
  const ReflectionComposerPage({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  State<ReflectionComposerPage> createState() => _ReflectionComposerPageState();
}

class _ReflectionComposerPageState extends State<ReflectionComposerPage> {
  final TextEditingController _contextController = TextEditingController();
  final TextEditingController _debriefController = TextEditingController();
  final TextEditingController _clarificationOneController =
      TextEditingController();
  final TextEditingController _clarificationTwoController =
      TextEditingController();
  final TextEditingController _clarificationThreeController =
      TextEditingController();

  String _followUpOffer = 'Belirsiz';
  String _futurePlanSignal = 'Belirsiz';
  String _comfortLevel = 'Orta';
  String _clarityLevel = 'Belirsiz';
  bool _physicalBoundaryIssue = false;

  @override
  void dispose() {
    _contextController.dispose();
    _debriefController.dispose();
    _clarificationOneController.dispose();
    _clarificationTwoController.dispose();
    _clarificationThreeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canAnalyze =
        _contextController.text.trim().isNotEmpty &&
        _debriefController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('New Reflection Session')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: <Widget>[
          Text(
            'Anlat + netleştir',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Bu build’de ses kaydı yerine text fallback kullanıyoruz. Aynı flow ileride gerçek audio capture ile değiştirilecek.',
          ),
          const SizedBox(height: 20),
          TextField(
            key: const Key('reflection_context_field'),
            controller: _contextController,
            decoration: const InputDecoration(
              labelText: 'Date bağlamı',
              hintText: 'Örn: Akşam yemeği, 2 saat, ilk buluşma',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('reflection_debrief_field'),
            controller: _debriefController,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Debrief',
              hintText:
                  'Buluşmada ne hissettin, ne gözlemledin, hangi anlar dikkat çekti?',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _DropdownField(
            label: 'Follow-up offer',
            value: _followUpOffer,
            items: const <String>['Evet', 'Belirsiz', 'Hayır'],
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _followUpOffer = value);
              }
            },
          ),
          const SizedBox(height: 16),
          _DropdownField(
            label: 'Future plan signal',
            value: _futurePlanSignal,
            items: const <String>['Var', 'Belirsiz', 'Yok'],
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _futurePlanSignal = value);
              }
            },
          ),
          const SizedBox(height: 16),
          _DropdownField(
            label: 'Comfort level',
            value: _comfortLevel,
            items: const <String>['Yüksek', 'Orta', 'Düşük'],
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _comfortLevel = value);
              }
            },
          ),
          const SizedBox(height: 16),
          _DropdownField(
            label: 'Clarity level',
            value: _clarityLevel,
            items: const <String>['Net', 'Belirsiz', 'Düşük'],
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _clarityLevel = value);
              }
            },
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _physicalBoundaryIssue,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Sınır / baskı / fiziksel rahatsızlık işareti vardı',
            ),
            onChanged: (bool? value) {
              setState(() => _physicalBoundaryIssue = value ?? false);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _clarificationOneController,
            decoration: const InputDecoration(
              labelText: 'Clarification 1',
              hintText: 'İlgiyi hangi somut davranışla hissettin?',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _clarificationTwoController,
            decoration: const InputDecoration(
              labelText: 'Clarification 2',
              hintText: 'Rahatsızlık tekil miydi tekrar eden mi?',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _clarificationThreeController,
            decoration: const InputDecoration(
              labelText: 'Clarification 3',
              hintText: 'Geleceğe dönük işaret somut muydu yorumsal mı?',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('reflection_analyze_button'),
            onPressed: canAnalyze ? _analyze : null,
            child: const Text('Analizi üret'),
          ),
        ],
      ),
    );
  }

  void _analyze() {
    final ReflectionDraft draft = ReflectionDraft(
      dateContext: _contextController.text.trim(),
      debrief: _debriefController.text.trim(),
      followUpOffer: _followUpOffer,
      futurePlanSignal: _futurePlanSignal,
      comfortLevel: _comfortLevel,
      clarityLevel: _clarityLevel,
      physicalBoundaryIssue: _physicalBoundaryIssue,
      clarificationAnswers: <String>[
        _clarificationOneController.text.trim(),
        _clarificationTwoController.text.trim(),
        _clarificationThreeController.text.trim(),
      ].where((String item) => item.isNotEmpty).toList(growable: false),
    );

    final InsightReport report = widget.controller.generateReport(draft);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => InsightReportPage(
          controller: widget.controller,
          title: _contextController.text.trim(),
          report: report,
        ),
      ),
    );
  }
}

class InsightReportPage extends StatelessWidget {
  const InsightReportPage({
    super.key,
    required this.controller,
    required this.title,
    required this.report,
  });

  final MatchProfileController controller;
  final String title;
  final InsightReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buluşma Değerlendirmesi')),
      body: ListView(
        key: const Key('insight_screen'),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: <Widget>[
          if (report.safetyAssessment.escalated) ...<Widget>[
            _SafetyCard(assessment: report.safetyAssessment),
            const SizedBox(height: 16),
          ],
          _SectionCard(title: 'Summary', child: Text(report.summary)),
          const SizedBox(height: 16),
          _SignalSection(
            title: 'Olumlu Sinyaller',
            signals: report.positiveSignals,
          ),
          const SizedBox(height: 16),
          _SignalSection(
            title: 'Dikkat Gerektirenler',
            signals: report.cautionSignals,
          ),
          const SizedBox(height: 16),
          _BulletedCard(
            title: 'Belirsiz Alanlar',
            items: report.uncertaintyFlags,
          ),
          const SizedBox(height: 16),
          _BulletedCard(
            title: 'Eksik Veri Alanları',
            items: report.missingDataPoints,
          ),
          const SizedBox(height: 16),
          _BulletedCard(
            title: 'Önerilen Sorular',
            items: report.recommendedQuestions,
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Önerilen Sonraki Adım',
            child: Text(report.nextStep),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('go_to_validation_button'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => ValidationPage(
                    controller: controller,
                    title: title,
                    report: report,
                  ),
                ),
              );
            },
            child: const Text('Kalibre et'),
          ),
        ],
      ),
    );
  }
}

class ValidationPage extends StatefulWidget {
  const ValidationPage({
    super.key,
    required this.controller,
    required this.title,
    required this.report,
  });

  final MatchProfileController controller;
  final String title;
  final InsightReport report;

  @override
  State<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends State<ValidationPage> {
  final Map<String, ValidationChoice> _choices = <String, ValidationChoice>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validation Step')),
      body: ListView(
        key: const Key('validation_screen'),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: <Widget>[
          const Text(
            'Bunu doğru anladım mı? Her signal için kısa bir doğrulama bırakabilirsin.',
          ),
          const SizedBox(height: 20),
          ...widget.report.allSignals.map((InsightSignal signal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        signal.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(signal.explanation),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ValidationChoice.values
                            .map((ValidationChoice choice) {
                              return ChoiceChip(
                                key: Key(
                                  'validation_${choice.name}_${signal.id}',
                                ),
                                label: Text(choice.label),
                                selected: _choices[signal.id] == choice,
                                onSelected: (_) {
                                  setState(() => _choices[signal.id] = choice);
                                },
                              );
                            })
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          FilledButton(
            key: const Key('save_to_journal_button'),
            onPressed: _save,
            child: const Text('Journal’a kaydet'),
          ),
        ],
      ),
    );
  }

  void _save() {
    widget.controller.saveValidatedReport(
      title: widget.title,
      report: widget.report,
      validations: _choices,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SaveConfirmationPage(
          controller: widget.controller,
          report: widget.report,
        ),
      ),
    );
  }
}

class SaveConfirmationPage extends StatelessWidget {
  const SaveConfirmationPage({
    super.key,
    required this.controller,
    required this.report,
  });

  final MatchProfileController controller;
  final InsightReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Final Reflection Save')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Reflection kaydedildi',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(report.summary),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const <Widget>[
                _Tag(text: '7. gün check-in planlandı'),
                _Tag(text: '14. gün check-in planlandı'),
              ],
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                controller.openJournal();
                Navigator.of(
                  context,
                ).popUntil((Route<dynamic> route) => route.isFirst);
              },
              child: const Text('Journal’a git'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                controller.switchTab(0);
                Navigator.of(
                  context,
                ).popUntil((Route<dynamic> route) => route.isFirst);
              },
              child: const Text('Dashboard’a dön'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (trailing case final Widget trailingWidget) trailingWidget,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _BulletedCard extends StatelessWidget {
  const _BulletedCard({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: items.isEmpty
          ? const Text('Bu bölümde şu an ek içerik yok.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map(
                    (String item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(Icons.circle, size: 8),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _SignalSection extends StatelessWidget {
  const _SignalSection({required this.title, required this.signals});

  final String title;
  final List<InsightSignal> signals;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: signals.isEmpty
          ? const Text('Bu bölümde henüz güçlü sinyal yok.')
          : Column(
              children: signals
                  .map(
                    (InsightSignal signal) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    signal.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                _Tag(text: signal.confidenceLabel.label),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(signal.explanation),
                            const SizedBox(height: 10),
                            Text(
                              'Evidence: ${signal.evidenceItems.first.source}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(signal.evidenceItems.first.text),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard({required this.assessment});

  final SafetyAssessment assessment;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF0ED),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              assessment.headline,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(assessment.summary),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: assessment.actions
                  .map((String action) => _Tag(text: action))
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (String item) =>
                DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
