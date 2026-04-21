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
    final DailyCheckIn? latestCheckIn = controller.latestDailyCheckIn;

    return PremiumScrollScaffold(
      key: const Key('daily_hub_screen'),
      children: <Widget>[
        const SectionHeader(kicker: 'GÜNLÜK', title: 'Bugün'),
        const SizedBox(height: 14),

        // ── Daily insight — warm coral gradient ──
        FeatureGradientCard(
          kicker: hasCheckedIn
              ? 'BUGÜNÜN ODAĞI · ${latestCheckIn?.aiEnhanced == true ? 'AI DESTEKLİ' : 'KİŞİSEL'}'
              : 'GÜNÜN İÇGÖRÜSÜ · ${insight.category.toUpperCase()}',
          title: hasCheckedIn ? 'Bugünün mikro odağı' : insight.relatedProfileArea,
          description:
              hasCheckedIn ? controller.latestDailyMicroAction : insight.prompt,
          icon: Icons.auto_awesome,
          gradientColors: const <Color>[
            Color(0xFFC8553D), Color(0xFFD4854A), Color(0xFFE8A85C),
          ],
          swipeHint: hasCheckedIn
              ? 'Geri dönmek isteyeceğin tek hamle'
              : 'Profil bazlı kişisel içgörü',
          onOpen: () {},
        ),

        // ── Streak / Mood / Interactions stat row ──
        Row(
          children: <Widget>[
            Expanded(
              child: _DailyStatCard(
                value: '${controller.checkInStreak}',
                label: 'gün seri',
                icon: Icons.local_fire_department_rounded,
                color: t.roseGold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DailyStatCard(
                value: _moodValue(controller.averageMoodLast7Days),
                label: '7 gün ruh hali',
                icon: Icons.mood_rounded,
                color: controller.averageMoodLast7Days > 0.6
                    ? t.softGreen
                    : t.amber,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DailyStatCard(
                value: '${controller.interactionCount}',
                label: 'etkileşim',
                icon: Icons.people_outline_rounded,
                color: t.warmGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Check-in card — teal gradient ──
        if (!hasCheckedIn)
          FeatureGradientCard(
            kicker: 'GÜNLÜK KAYIT',
            title: 'Bugün Nasılsın?',
            description:
                'Ruh halini, tetikleyicilerini ve romantik düşünceni kaydet. Sadece 2 dakika.',
            icon: Icons.edit_calendar_rounded,
            gradientColors: const <Color>[
              Color(0xFF1B6B6D), Color(0xFF2A8F8E), Color(0xFF3DB5A6),
            ],
            swipeHint: 'Kayıt yapmak için sağa kaydır',
            onOpen: () {
              Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (BuildContext context) =>
                    DailyCheckInPage(controller: controller),
              ));
            },
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
                      Text('Bugünkü kayıt tamam',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        'Ruh hali: ${controller.dailyCheckIns.first.mood.label}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('Günlük ilerleme',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  TagPill(text: controller.dailyProgressStage),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                controller.dailyProgressSummary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  value: controller.dailyProgressValue,
                  backgroundColor: t.smoky,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(t.roseGold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Günlük Olumlama — profil bazlı ──
        SurfaceCard(
          tint: t.deepCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: t.roseGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.self_improvement_rounded,
                        color: t.roseGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('Günün mesajı',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                controller.dailyAffirmation,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Haftalık Ruh Hali Özeti ──
        if (controller.dailyCheckIns.length >= 2)
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t.warmGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.analytics_outlined,
                          color: t.warmGold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Haftalık özet',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  controller.weeklyMoodSummary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        if (controller.dailyCheckIns.length >= 2) const SizedBox(height: 14),

        // ── Kayıt sonrası geri bildirim ──
        if (hasCheckedIn && controller.latestDailyCoachInsight.isNotEmpty)
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t.blushRose.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.psychology_outlined,
                          color: t.blushRose, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                        latestCheckIn?.aiEnhanced == true
                            ? 'Bugünün yorumlanmış sonucu'
                            : 'Bugünün geri bildirimi',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  controller.latestDailyCoachInsight,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                ),
              ],
            ),
          ),
        if (hasCheckedIn && controller.latestDailyCoachInsight.isNotEmpty)
          const SizedBox(height: 14),

        if (hasCheckedIn)
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t.softGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.track_changes_rounded,
                          color: t.softGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Bugünün hamlesi',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  controller.latestDailyMicroAction,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.55,
                      ),
                ),
                const SizedBox(height: 12),
                TagPill(
                  text: controller.latestDailyPatternNote,
                  background: t.roseGold.withValues(alpha: 0.1),
                  foreground: t.roseGold,
                ),
              ],
            ),
          ),
        if (hasCheckedIn) const SizedBox(height: 14),

        // ── Interaction log — blue gradient ──
        FeatureGradientCard(
          kicker: 'ETKİLEŞİM GÜNLÜĞÜ',
          title: 'Yeni Etkileşim Kaydet',
          description:
              'Sadece buluşmalar değil — mesajlaşma, aklına gelme, sosyal medya etkileşimi, her şeyi kaydet.',
          icon: Icons.add_circle_outline_rounded,
          gradientColors: const <Color>[
            Color(0xFF2C4A7C), Color(0xFF3A6EA5), Color(0xFF5A8FBF),
          ],
          swipeHint: 'Kaydetmek için sağa kaydır',
          onOpen: () {
            Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  InteractionLogFormPage(controller: controller),
            ));
          },
        ),

        // ── Interaction history — rose gradient ──
        if (controller.interactionLog.isNotEmpty)
          FeatureGradientCard(
            kicker: 'GEÇMİŞ',
            title: 'Etkileşim Geçmişi',
            description:
                '${controller.interactionCount} etkileşim, ${controller.uniquePersonCount} kişi kayıtlı.',
            icon: Icons.history_rounded,
            gradientColors: const <Color>[
              Color(0xFFA85A5A), Color(0xFFCF7F6F), Color(0xFFD4A08A),
            ],
            swipeHint: 'Geçmişi görmek için sağa kaydır',
            onOpen: () {
              Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (BuildContext context) =>
                    InteractionHistoryPage(controller: controller),
              ));
            },
          ),

        // ── Trigger frequency ──
        if (controller.triggerFrequency.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
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
            kicker: 'GEÇMİŞ KAYITLAR',
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            TagPill(text: ci.mood.label),
                            if (ci.aiEnhanced) ...<Widget>[
                              const SizedBox(height: 6),
                              TagPill(
                                text: 'AI',
                                background: t.softGreen.withValues(alpha: 0.1),
                                foreground: t.softGreen,
                              ),
                            ],
                          ],
                        ),
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

// ── Daily stat mini card ──
class _DailyStatCard extends StatelessWidget {
  const _DailyStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: t.charcoal,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: color.withValues(alpha: 0.7), size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color == t.roseGold ? t.primaryDark : color,
              fontSize: 20,
              fontWeight: FontWeight.w300,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: t.softText, fontSize: 11)),
        ],
      ),
    );
  }
}

String _moodValue(double v) {
  if (v >= 0.8) return 'Harika';
  if (v >= 0.6) return 'İyi';
  if (v >= 0.4) return 'Nötr';
  if (v >= 0.2) return 'Düşük';
  return '—';
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
      appBar: AppBar(
        title: const Text('Günlük Kayıt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () => Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst),
          ),
        ],
      ),
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
                            ? t.roseGold.withValues(alpha: 0.1)
                            : t.graphite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? t.roseGold.withValues(alpha: 0.4)
                              : t.smoky.withValues(alpha: 0.3),
                          width: isSelected ? 1 : 0.5,
                        ),
                        boxShadow: isSelected
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: t.roseGold.withValues(alpha: 0.05),
                                  blurRadius: 8,
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
              Text('Kısa yansıtma',
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
      appBar: AppBar(
        title: const Text('Yeni Etkileşim'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () => Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst),
          ),
        ],
      ),
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
              Text('İşaret tespiti',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('Boş bırakabilirsin — zorlama',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 14),
              PremiumTextField(
                controller: _redFlagCtrl,
                label: 'Uyarı işareti gördün mü?',
                hint: 'Varsa yaz, yoksa boş bırak',
              ),
              const SizedBox(height: 12),
              PremiumTextField(
                controller: _greenFlagCtrl,
                label: 'Olumlu işaret gördün mü?',
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
      appBar: AppBar(
        title: const Text('Etkileşim Geçmişi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () => Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst),
          ),
        ],
      ),
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
                      if (entry.aiEnhanced)
                        TagPill(
                          text: 'AI yorum',
                          background: t.softGreen.withValues(alpha: 0.1),
                          foreground: t.softGreen,
                        ),
                      if (entry.redFlagNoticed.isNotEmpty)
                        TagPill(
                          text: 'Uyarı: ${entry.redFlagNoticed}',
                          background: t.roseCaution.withValues(alpha: 0.1),
                          foreground: t.roseCaution,
                        ),
                      if (entry.greenFlagNoticed.isNotEmpty)
                        TagPill(
                          text: 'Olumlu: ${entry.greenFlagNoticed}',
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
                        color: t.roseGold.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: t.roseGold.withValues(alpha: 0.1),
                          width: 0.5,
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
                                  ?.copyWith(color: t.textPrimary),
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
