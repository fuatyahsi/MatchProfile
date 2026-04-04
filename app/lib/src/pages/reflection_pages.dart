import 'package:flutter/material.dart';

import '../controller.dart';
import '../models.dart';
import '../theme.dart' as t;
import '../widgets/app_widgets.dart';

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

    return PremiumScrollScaffold(
      appBar: AppBar(title: const Text('New Reflection Session')),
      children: <Widget>[
        const SectionHeader(
          kicker: 'Phase 2 / Debrief-first',
          title: 'Anlat + netleştir',
        ),
        const SizedBox(height: 8),
        Text(
          'Bu buildde ses kaydi yerine text fallback kullaniyoruz. Akis yine ayni: serbest anlatim, structured form ve en fazla 3 clarification sorusu.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        SurfaceCard(
          tint: t.graphite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Voice Debrief Studio',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: t.ivoryText),
              ),
              const SizedBox(height: 10),
              Text(
                'Canli audio capture henuz bagli degil; ama bu akista debrief mantigi, evidence toplama sekli ve analiz katmani gercekteki sesli deneyime gore tasarlandi.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: t.ivoryText.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: List<Widget>.generate(
                  20,
                  (int index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 12 + (index % 5) * 10,
                      decoration: BoxDecoration(
                        color: t.ivoryText.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SurfaceCard(
          child: Column(
            children: <Widget>[
              TextField(
                key: const Key('reflection_context_field'),
                controller: _contextController,
                decoration: const InputDecoration(
                  labelText: 'Date baglami',
                  hintText: 'Orn: aksam yemegi, ilk bulusma, 2 saat',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('reflection_debrief_field'),
                controller: _debriefController,
                minLines: 7,
                maxLines: 11,
                decoration: const InputDecoration(
                  labelText: 'Debrief',
                  hintText:
                      'Ne oldu, ne hissettin, hangi davranislar sana guven verdi veya belirsizlik yaratti?',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Structured signal pack',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _DropdownField(
                label: 'Follow-up offer',
                value: _followUpOffer,
                items: const <String>['Evet', 'Belirsiz', 'Hayir'],
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _followUpOffer = value);
                  }
                },
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _DropdownField(
                      label: 'Comfort level',
                      value: _comfortLevel,
                      items: const <String>['Yuksek', 'Orta', 'Dusuk'],
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() => _comfortLevel = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DropdownField(
                      label: 'Clarity level',
                      value: _clarityLevel,
                      items: const <String>['Net', 'Belirsiz', 'Dusuk'],
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() => _clarityLevel = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _physicalBoundaryIssue,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Sinir / baski / fiziksel rahatsizlik isareti vardi',
                ),
                onChanged: (bool? value) {
                  setState(() => _physicalBoundaryIssue = value ?? false);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SurfaceCard(
          tint: t.charcoal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Clarification',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _clarificationOneController,
                decoration: const InputDecoration(
                  labelText: 'Clarification 1',
                  hintText: 'Ilgiyi hangi somut davranisla hissettin?',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _clarificationTwoController,
                decoration: const InputDecoration(
                  labelText: 'Clarification 2',
                  hintText:
                      'Rahatsizlik tekil miydi, tekrar eden bir his miydi?',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _clarificationThreeController,
                decoration: const InputDecoration(
                  labelText: 'Clarification 3',
                  hintText:
                      'Gelecege donuk sinyal somut muydu, yorumsal miydi?',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          key: const Key('reflection_analyze_button'),
          onPressed: canAnalyze ? _analyze : null,
          child: const Text('Signal mapi uret'),
        ),
      ],
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
    final OnboardingProfile? profile = controller.profile;

    return PremiumScrollScaffold(
      key: const Key('insight_screen'),
      appBar: AppBar(title: const Text('Bulusma Degerlendirmesi')),
      children: <Widget>[
        SurfaceCard(
          tint: report.safetyAssessment.escalated
              ? t.roseCaution.withValues(alpha: 0.1)
              : t.graphite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: report.safetyAssessment.escalated
                      ? Theme.of(context).colorScheme.onSurface
                      : t.ivoryText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                report.summary,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: report.safetyAssessment.escalated
                      ? Theme.of(context).colorScheme.onSurface
                      : t.ivoryText.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: 18),
              TagPill(
                text: report.safetyAssessment.escalated
                    ? report.safetyAssessment.headline
                    : 'Next step: ${report.nextStep}',
                background: report.safetyAssessment.escalated
                    ? t.roseCaution.withValues(alpha: 0.1)
                    : t.roseGold.withValues(alpha: 0.1),
                foreground: report.safetyAssessment.escalated
                    ? t.roseCaution
                    : t.ivoryText,
              ),
            ],
          ),
        ),
        if (report.safetyAssessment.escalated) ...<Widget>[
          const SizedBox(height: 18),
          SurfaceCard(
            tint: t.roseCaution.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SectionHeader(
                  kicker: 'Safety mode',
                  title: 'Oncelik guvenlik ve sinir netligi',
                ),
                const SizedBox(height: 10),
                Text(
                  report.safetyAssessment.summary,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ...report.safetyAssessment.actions.map(
                  (String action) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TagPill(
                      text: action,
                      background: t.roseCaution.withValues(alpha: 0.1),
                      foreground: t.roseCaution,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Release buildde yerel destek kaynaklari ulkeye gore gosterilecek. Bu mock buildde safety karti normal uyum yorumunun onune gecer.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        const SectionHeader(kicker: 'Clarity map', title: 'Cok boyutlu okuma'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: report.dimensions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 164,
          ),
          itemBuilder: (BuildContext context, int index) {
            return DimensionTile(dimension: report.dimensions[index]);
          },
        ),
        const SizedBox(height: 18),
        const SectionHeader(
          kicker: 'Signal layers',
          title: 'Olumlu ve dikkat gerektirenler',
        ),
        const SizedBox(height: 12),
        ...report.positiveSignals.map(
          (InsightSignal signal) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SignalBadge(signal: signal),
          ),
        ),
        ...report.cautionSignals.map(
          (InsightSignal signal) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SignalBadge(signal: signal),
          ),
        ),
        const SizedBox(height: 8),
        _BulletSection(
          title: 'Belirsiz alanlar',
          items: report.uncertaintyFlags,
        ),
        const SizedBox(height: 14),
        _BulletSection(
          title: 'Eksik veri alanlari',
          items: report.missingDataPoints,
        ),
        const SizedBox(height: 14),
        _BulletSection(
          title: 'Onerilen sorular',
          items: report.recommendedQuestions,
        ),
        if (profile != null) ...<Widget>[
          const SizedBox(height: 14),
          SurfaceCard(
            tint: t.charcoal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Anchor lens',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    ...profile.values.take(3).map(
                      (String item) => TagPill(text: item),
                    ),
                    ...profile.dealbreakers.take(2).map(
                      (String item) => TagPill(
                        text: item,
                        background: const Color(0x14C89A5A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Bu rapor senin tempo ve netlik beklentine göre yorumlandı: ${profile.pacingPreference.label} · ${profile.clarityExpectation}',
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Evidence taxonomy',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: report.evidenceMix.entries
                    .map(
                      (MapEntry<String, int> entry) =>
                          TagPill(text: '${entry.key}: ${entry.value}'),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
          child: const Text('Validation stepine gec'),
        ),
      ],
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
  final TextEditingController _missingContextController =
      TextEditingController();
  final TextEditingController _leastAccurateController =
      TextEditingController();

  @override
  void dispose() {
    _missingContextController.dispose();
    _leastAccurateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScrollScaffold(
      key: const Key('validation_screen'),
      appBar: AppBar(title: const Text('Validation Step')),
      children: <Widget>[
        const SectionHeader(
          kicker: 'Phase 3 / Recalibration',
          title: 'Bunu dogru anladim mi?',
        ),
        const SizedBox(height: 8),
        Text(
          'Her signal icin kisa bir dogrulama birak. Sistem burada self-training degil, self-calibration yapiyor.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        ...widget.report.allSignals.map((InsightSignal signal) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          signal.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TagPill(text: signal.confidenceLabel.label),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(signal.explanation),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ValidationChoice.values
                        .map((ValidationChoice choice) {
                          return ChoiceChip(
                            key: Key('validation_${choice.name}_${signal.id}'),
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
          );
        }),
        SurfaceCard(
          tint: t.charcoal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Kalibrasyon notu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              TextField(
                key: const Key('validation_missing_context_field'),
                controller: _missingContextController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Burada eksik olan baglam neydi?',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('validation_least_accurate_field'),
                controller: _leastAccurateController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Sana en az dogru gelen bolum hangisiydi?',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('save_to_journal_button'),
          onPressed: _save,
          child: const Text('Journala kaydet'),
        ),
      ],
    );
  }

  void _save() {
    widget.controller.saveValidatedReport(
      title: widget.title,
      report: widget.report,
      validations: _choices,
      feedback: ValidationFeedback(
        missingContext: _missingContextController.text.trim(),
        leastAccuratePart: _leastAccurateController.text.trim(),
      ),
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
    return PremiumScrollScaffold(
      appBar: AppBar(title: const Text('Final Reflection Save')),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        SurfaceCard(
          tint: t.graphite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Reflection kaydedildi',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: t.ivoryText),
              ),
              const SizedBox(height: 10),
              Text(
                report.summary,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: t.ivoryText.withValues(alpha: 0.84),
                ),
              ),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  TagPill(
                    text: '7. gun check-in planlandi',
                    background: Color(0x1AF4EEE4),
                    foreground: t.ivoryText,
                  ),
                  TagPill(
                    text: '14. gun check-in planlandi',
                    background: Color(0x1AF4EEE4),
                    foreground: t.ivoryText,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Memory update',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...report.memoryUpdates.map(
                (String item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('- $item'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          key: const Key('go_to_journal_button'),
          onPressed: () {
            controller.openJournal();
            Navigator.of(
              context,
            ).popUntil((Route<dynamic> route) => route.isFirst);
          },
          child: const Text('Journala git'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('back_to_dashboard_button'),
          onPressed: () {
            controller.switchTab(0);
            Navigator.of(
              context,
            ).popUntil((Route<dynamic> route) => route.isFirst);
          },
          child: const Text('Dashboarda don'),
        ),
      ],
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
      value: value,
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

class _BulletSection extends StatelessWidget {
  const _BulletSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text('Bu katmanda su an ek icerik yok.')
          else
            ...items.map(
              (String item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('- $item'),
              ),
            ),
        ],
      ),
    );
  }
}
