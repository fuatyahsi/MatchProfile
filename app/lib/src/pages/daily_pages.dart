import 'package:flutter/material.dart';

import '../controller.dart';
import '../models.dart';
import '../theme.dart' as t;
import '../widgets/app_widgets.dart';

// ═══════════════════════════════════════════════
//  Günlük (Daily Hub) — Tab that brings users back
// ═══════════════════════════════════════════════

class DailyHubPage extends StatelessWidget {
  const DailyHubPage({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  Widget build(BuildContext context) {
    final DailyInsight insight = controller.generateDailyInsight();
    final bool hasCheckedIn = controller.hasTodayCheckIn;

    return PremiumScrollScaffold(
      key: const Key('daily_hub_screen'),
      children: <Widget>[
        // ── Daily insight card ──
        GradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: t.roseGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: t.roseGold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Günün İçgörüsü',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: t.roseGold),
                        ),
                        Text(
                          insight.category,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: t.softText),
                        ),
                      ],
                    ),
                  ),
                  TagPill(text: insight.relatedProfileArea),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                insight.prompt,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: t.ivoryText,
                      height: 1.65,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── Streak + mood summary ──
        Row(
          children: <Widget>[
            Expanded(
              child: SurfaceCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${controller.checkInStreak}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: t.roseGold),
                    ),
                    const SizedBox(height: 4),
                    Text('gün seri',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SurfaceCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RadialScoreGauge(
                      label: '7 gün mood',
                      value: controller.averageMoodLast7Days,
                      size: 56,
                      color: controller.averageMoodLast7Days > 0.6
                          ? t.softGreen
                          : t.amber,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SurfaceCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${controller.interactionCount}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: t.warmGold),
                    ),
                    const SizedBox(height: 4),
                    Text('etkileşim',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ── Daily check-in CTA ──
        if (!hasCheckedIn)
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Günlük Check-in',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Bugün henüz check-in yapmadın. 2 dakikada ruh halini, tetikleyicilerini ve romantik düşünceni kaydet.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            DailyCheckInPage(controller: controller),
                      ));
                    },
                    child: const Text('Check-in yap'),
                  ),
                ),
              ],
            ),
          )
        else
          SurfaceCard(
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: t.softGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: t.softGreen, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Bugünkü check-in tamam',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        'Mood: ${controller.dailyCheckIns.first.mood.label}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 18),

        // ── Quick interaction log button ──
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Etkileşim Günlüğü',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Sadece buluşmalar değil — mesajlaşma, aklına gelme, sosyal medya etkileşimi, her şeyi kaydet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              InteractionLogFormPage(controller: controller),
                        ));
                      },
                      child: const Text('Yeni etkileşim'),
                    ),
                  ),
                  if (controller.interactionLog.isNotEmpty) ...<Widget>[
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              InteractionHistoryPage(controller: controller),
                        ));
                      },
                      child: const Text('Geçmiş'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── Trigger frequency ──
        if (controller.triggerFrequency.isNotEmpty) ...<Widget>[
          const SectionHeader(
            kicker: 'TETİKLEYİCİ ANALİZİ',
            title: 'Son 14 günün tetikleyicileri',
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.triggerFrequency.entries
                  .map((MapEntry<EmotionalTrigger, int> e) => TagPill(
                        text: '${e.key.label} (${e.value})',
                        background: e.value >= 3
                            ? t.roseCaution.withValues(alpha: 0.12)
                            : null,
                        foreground: e.value >= 3 ? t.roseCaution : null,
                      ))
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 18),
        ],

        // ── Recent check-ins list ──
        if (controller.dailyCheckIns.isNotEmpty) ...<Widget>[
          SectionHeader(
            kicker: 'GEÇMİŞ CHECK-IN\'LER',
            title: 'Son ${controller.dailyCheckIns.length > 7 ? 7 : controller.dailyCheckIns.length} gün',
          ),
          const SizedBox(height: 12),
          ...controller.dailyCheckIns.take(7).map(
                (DailyCheckIn ci) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: <Widget>[
                        _MoodIcon(mood: ci.mood),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _formatDateShort(ci.date),
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                              if (ci.miniReflection.isNotEmpty)
                                Text(
                                  ci.miniReflection,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium,
                                ),
                            ],
                          ),
                        ),
                        TagPill(text: ci.mood.label),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Daily Check-in Form
// ═══════════════════════════════════════════════

class DailyCheckInPage extends StatefulWidget {
  const DailyCheckInPage({super.key, required this.controller});
  final MatchProfileController controller;

  @override
  State<DailyCheckInPage> createState() => _DailyCheckInPageState();
}

class _DailyCheckInPageState extends State<DailyCheckInPage> {
  MoodLevel _mood = MoodLevel.neutral;
  final Set<EmotionalTrigger> _triggers = <EmotionalTrigger>{};
  EnergyLevel _energy = EnergyLevel.medium;
  final TextEditingController _thoughtCtrl = TextEditingController();
  final TextEditingController _reflectionCtrl = TextEditingController();

  @override
  void dispose() {
    _thoughtCtrl.dispose();
    _reflectionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScrollScaffold(
      appBar: AppBar(title: const Text('Günlük Check-in')),
      children: <Widget>[
        const SectionHeader(
          kicker: 'BUGÜN',
          title: 'Nasıl hissediyorsun?',
        ),
        const SizedBox(height: 16),

        // Mood selection
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Ruh halin',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: MoodLevel.values.map((MoodLevel mood) {
                  final bool isSelected = _mood == mood;
                  return GestureDetector(
                    onTap: () => setState(() => _mood = mood),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? t.roseGold.withValues(alpha: 0.15)
                            : t.graphite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? t.roseGold.withValues(alpha: 0.5)
                              : t.smoky.withValues(alpha: 0.3),
                          width: isSelected ? 1.5 : 0.8,
                        ),
                        boxShadow: isSelected
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: t.roseGold.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            _moodEmoji(mood),
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text(
                            mood.label,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontSize: 9,
                                  color: isSelected
                                      ? t.roseGold
                                      : t.mutedText,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Triggers
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Duygusal tetikleyiciler',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('Birden fazla seçebilirsin',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 14),
              PremiumChipGroup(
                options: EmotionalTrigger.values
                    .map((EmotionalTrigger t) => t.label)
                    .toList(growable: false),
                selected: _triggers.map((EmotionalTrigger t) => t.label).toSet(),
                multiSelect: true,
                onChanged: (String label) {
                  setState(() {
                    final EmotionalTrigger trigger = EmotionalTrigger.values
                        .firstWhere((EmotionalTrigger t) => t.label == label);
                    if (_triggers.contains(trigger)) {
                      _triggers.remove(trigger);
                    } else {
                      _triggers.add(trigger);
                    }
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Energy level
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Enerji seviyesi',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              PremiumChipGroup(
                options: EnergyLevel.values
                    .map((EnergyLevel e) => e.label)
                    .toList(growable: false),
                selected: <String>{_energy.label},
                onChanged: (String label) {
                  setState(() {
                    _energy = EnergyLevel.values
                        .firstWhere((EnergyLevel e) => e.label == label);
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Romantic thought
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Romantik düşünce',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('Bugün aklından geçen romantik düşünce ne?',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 14),
              PremiumTextField(
                controller: _thoughtCtrl,
                label: 'Aklındaki ne?',
                hint: 'Biri mi var, genel bir düşünce mi, yoksa hiç mi?',
                minLines: 2,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Mini reflection
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Mini refleksiyon',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('1-2 cümle ile bugünü özetle',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 14),
              PremiumTextField(
                controller: _reflectionCtrl,
                label: 'Bugünün özeti',
                hint: 'Kendine karşı dürüst ol',
                minLines: 2,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              widget.controller.saveDailyCheckIn(
                mood: _mood,
                triggers: _triggers.toList(growable: false),
                energyLevel: _energy,
                romanticThought: _thoughtCtrl.text.trim(),
                miniReflection: _reflectionCtrl.text.trim(),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Kaydet'),
          ),
        ),
      ],
    );
  }

  String _moodEmoji(MoodLevel mood) => switch (mood) {
        MoodLevel.great => '✨',
        MoodLevel.good => '😊',
        MoodLevel.neutral => '😐',
        MoodLevel.low => '😔',
        MoodLevel.bad => '😞',
      };
}

// ═══════════════════════════════════════════════
//  Interaction Log Form
// ═══════════════════════════════════════════════

class InteractionLogFormPage extends StatefulWidget {
  const InteractionLogFormPage({super.key, required this.controller});
  final MatchProfileController controller;

  @override
  State<InteractionLogFormPage> createState() => _InteractionLogFormPageState();
}

class _InteractionLogFormPageState extends State<InteractionLogFormPage> {
  InteractionType _type = InteractionType.texting;
  InteractionEnergy _energy = InteractionEnergy.neutral;
  final TextEditingController _personCtrl = TextEditingController();
  final TextEditingController _whatHappenedCtrl = TextEditingController();
  final TextEditingController _whatFeltCtrl = TextEditingController();
  final TextEditingController _redFlagCtrl = TextEditingController();
  final TextEditingController _greenFlagCtrl = TextEditingController();

  @override
  void dispose() {
    _personCtrl.dispose();
    _whatHappenedCtrl.dispose();
    _whatFeltCtrl.dispose();
    _redFlagCtrl.dispose();
    _greenFlagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave = _personCtrl.text.trim().isNotEmpty;

    return PremiumScrollScaffold(
      appBar: AppBar(title: const Text('Yeni Etkileşim')),
      children: <Widget>[
        const SectionHeader(
          kicker: 'ETKİLEŞİM GÜNLÜĞÜ',
          title: 'Ne oldu?',
        ),
        const SizedBox(height: 16),

        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Kim?',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              PremiumTextField(
                controller: _personCtrl,
                label: 'İsim veya takma ad',
                hint: 'Ör: A., Tinder kişi, iş arkadaşı',
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Etkileşim türü',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              PremiumChipGroup(
                options: InteractionType.values
                    .map((InteractionType t) => t.label)
                    .toList(growable: false),
                selected: <String>{_type.label},
                onChanged: (String label) {
                  setState(() {
                    _type = InteractionType.values
                        .firstWhere((InteractionType t) => t.label == label);
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Enerji',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              PremiumChipGroup(
                options: InteractionEnergy.values
                    .map((InteractionEnergy e) => e.label)
                    .toList(growable: false),
                selected: <String>{_energy.label},
                onChanged: (String label) {
                  setState(() {
                    _energy = InteractionEnergy.values
                        .firstWhere((InteractionEnergy e) => e.label == label);
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PremiumTextField(
                controller: _whatHappenedCtrl,
                label: 'Ne oldu?',
                hint: 'Kısaca anlat',
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 14),
              PremiumTextField(
                controller: _whatFeltCtrl,
                label: 'Ne hissettin?',
                hint: 'Dürüst ol — iyi veya kötü',
                minLines: 2,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Bayrak tespiti',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('Boş bırakabilirsin — zorlama',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 14),
              PremiumTextField(
                controller: _redFlagCtrl,
                label: 'Red flag gördün mü?',
                hint: 'Varsa yaz, yoksa boş bırak',
              ),
              const SizedBox(height: 12),
              PremiumTextField(
                controller: _greenFlagCtrl,
                label: 'Green flag gördün mü?',
                hint: 'Varsa yaz, yoksa boş bırak',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: canSave ? _save : null,
            child: const Text('Etkileşimi kaydet'),
          ),
        ),
      ],
    );
  }

  void _save() {
    widget.controller.saveInteraction(
      personLabel: _personCtrl.text.trim(),
      interactionType: _type,
      energy: _energy,
      whatHappened: _whatHappenedCtrl.text.trim(),
      whatYouFelt: _whatFeltCtrl.text.trim(),
      redFlagNoticed: _redFlagCtrl.text.trim(),
      greenFlagNoticed: _greenFlagCtrl.text.trim(),
    );
    Navigator.of(context).pop();
  }
}

// ═══════════════════════════════════════════════
//  Interaction History
// ═══════════════════════════════════════════════

class InteractionHistoryPage extends StatelessWidget {
  const InteractionHistoryPage({super.key, required this.controller});
  final MatchProfileController controller;

  @override
  Widget build(BuildContext context) {
    return PremiumScrollScaffold(
      appBar: AppBar(title: const Text('Etkileşim Geçmişi')),
      children: <Widget>[
        SectionHeader(
          kicker: 'ETKİLEŞİMLER',
          title: '${controller.interactionCount} kayıt · ${controller.uniquePersonCount} kişi',
        ),
        const SizedBox(height: 14),
        ...controller.interactionLog.map(
          (InteractionLogEntry entry) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          entry.personLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TagPill(text: entry.interactionType.label),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDateShort(entry.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  if (entry.whatHappened.isNotEmpty)
                    Text(entry.whatHappened),
                  if (entry.whatYouFelt.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      'Hissettiğin: ${entry.whatYouFelt}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: t.softText,
                          ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      TagPill(text: entry.energy.label),
                      if (entry.redFlagNoticed.isNotEmpty)
                        TagPill(
                          text: 'Red: ${entry.redFlagNoticed}',
                          background: t.roseCaution.withValues(alpha: 0.1),
                          foreground: t.roseCaution,
                        ),
                      if (entry.greenFlagNoticed.isNotEmpty)
                        TagPill(
                          text: 'Green: ${entry.greenFlagNoticed}',
                          background: t.softGreen.withValues(alpha: 0.1),
                          foreground: t.softGreen,
                        ),
                    ],
                  ),
                  if (entry.profileInsight != null &&
                      entry.profileInsight!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: t.roseGold.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: t.roseGold.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.auto_awesome,
                              size: 16, color: t.roseGold),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.profileInsight!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: t.ivoryText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Mood Icon Widget
// ═══════════════════════════════════════════════

class _MoodIcon extends StatelessWidget {
  const _MoodIcon({required this.mood});
  final MoodLevel mood;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (mood) {
      MoodLevel.great => t.softGreen,
      MoodLevel.good => t.warmGold,
      MoodLevel.neutral => t.softText,
      MoodLevel.low => t.amber,
      MoodLevel.bad => t.roseCaution,
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          switch (mood) {
            MoodLevel.great => '✨',
            MoodLevel.good => '😊',
            MoodLevel.neutral => '😐',
            MoodLevel.low => '😔',
            MoodLevel.bad => '😞',
          },
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

String _formatDateShort(DateTime value) {
  final String day = value.day.toString().padLeft(2, '0');
  final String month = value.month.toString().padLeft(2, '0');
  return '$day.$month';
}
