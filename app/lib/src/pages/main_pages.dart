import 'package:flutter/material.dart';

import '../controller.dart';
import '../models.dart';
import '../theme.dart' as t;
import '../widgets/app_widgets.dart';
import 'daily_pages.dart';
import 'profile_edit_page.dart';

// ═══════════════════════════════════════════════
//  Dashboard
// ═══════════════════════════════════════════════

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  Widget build(BuildContext context) {
    final JournalEntry? latest = controller.latestEntry;
    final List<PendingCheckInTask> tasks =
        controller.pendingCheckInTasks.take(3).toList(growable: false);
    final OnboardingProfile? profile = controller.profile;

    return PremiumScrollScaffold(
      key: const Key('dashboard_screen'),
      children: <Widget>[
        // ── Hero card ──
        // ── Hero card — premium gradient ──
        GradientCard(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Merhaba ${profile?.displayName ?? ''}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: t.ivoryText),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: t.roseGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: t.roseGold.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      'Premium',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: t.roseGold,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                latest == null
                    ? 'Romantik karar profilin hazır. İlk reflection ile kişiselleştirilmiş insight akışını başlat.'
                    : latest.report.summary,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: t.ivoryText.withValues(alpha: 0.84),
                    ),
              ),
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  HeroStat(
                    label: 'Reflection',
                    value: controller.sessionCount.toString(),
                  ),
                  const SizedBox(width: 22),
                  HeroStat(
                    label: 'Açık check-in',
                    value: controller.pendingCheckInCount.toString(),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: HeroStat(
                      label: 'Pattern',
                      value: controller.patternStageLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // ── Daily Engagement Strip ──
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.local_fire_department_rounded,
                      color: controller.checkInStreak > 0
                          ? t.roseGold
                          : t.mutedText,
                      size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.hasTodayCheckIn
                          ? 'Bugünkü check-in tamam'
                          : 'Bugün henüz check-in yapmadın',
                      style: TextStyle(
                        color: controller.hasTodayCheckIn
                            ? t.softGreen
                            : t.warmGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!controller.hasTodayCheckIn)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                DailyCheckInPage(controller: controller),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              t.roseGold.withValues(alpha: 0.2),
                              t.dustyRose.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: t.roseGold.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Check-in yap',
                          style: TextStyle(
                            color: t.roseGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  HeroStat(
                    label: 'Streak',
                    value: '${controller.checkInStreak} gün',
                  ),
                  HeroStat(
                    label: 'Mood ort.',
                    value: _moodEmoji(controller.averageMoodLast7Days),
                  ),
                  HeroStat(
                    label: 'Etkileşim',
                    value: controller.interactionCount.toString(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // ── Karakter Profili ──
        if (profile != null) ...<Widget>[
          const SectionHeader(
            kicker: 'KARAKTER ANALİZİ',
            title: 'Senin profil özetin',
          ),
          const SizedBox(height: 14),

          // Radar chart — visual profile overview
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Profil Radarı',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Romantik karar profilinin çok boyutlu görünümü',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Center(
                  child: ProfileRadarChart(
                    size: 220,
                    labels: const <String>[
                      'Gerçekçilik',
                      'Sınır',
                      'Öz farkındalık',
                      'Duygu düzenl.',
                      'İletişim',
                      'Hazırlık',
                    ],
                    values: <double>[
                      profile.romanticRealismScore,
                      profile.boundaryHealthScore,
                      profile.selfAwarenessScore,
                      profile.emotionalRegulationScore,
                      profile.communicationAlignmentScore,
                      profile.relationshipReadiness,
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Circular gauges row
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Temel Metrikler',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RadialScoreGauge(
                      label: 'İdealizasyon',
                      value: profile.idealizationScore,
                      size: 80,
                      color: profile.highIdealization
                          ? t.roseCaution
                          : t.roseGold,
                      subtitle: profile.highIdealization ? 'Yüksek risk' : null,
                    ),
                    RadialScoreGauge(
                      label: 'Sınır Sağlığı',
                      value: profile.boundaryHealthScore,
                      size: 80,
                      color: profile.boundaryHealthScore < 0.4
                          ? t.roseCaution
                          : t.softGreen,
                    ),
                    RadialScoreGauge(
                      label: 'Bağımlılık',
                      value: profile.emotionalDependencyRisk,
                      size: 80,
                      color: profile.emotionalDependencyRisk > 0.5
                          ? t.roseCaution
                          : t.amber,
                      subtitle: profile.emotionalDependencyRisk > 0.5
                          ? 'Dikkat'
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Profile summary + tags
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  controller.profileSummary,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.anchorHighlights
                      .map((String tag) => TagPill(text: tag))
                      .toList(growable: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Detailed score bars
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Detaylı Skorlar',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ProfileScoreBar(
                  label: 'Romantik gerçekçilik',
                  value: profile.romanticRealismScore,
                  color: t.softGreen,
                  subtitle: 'İdealizasyonun tersi',
                ),
                ProfileScoreBar(
                  label: 'Öz farkındalık',
                  value: profile.selfAwarenessScore,
                  color: t.warmGold,
                  subtitle: 'Kör nokta ve pattern farkındalığı',
                ),
                ProfileScoreBar(
                  label: 'Duygu düzenleme',
                  value: profile.emotionalRegulationScore,
                  color: t.blushRose,
                  subtitle: 'Stres altında duygu yönetimi',
                ),
                ProfileScoreBar(
                  label: 'İletişim tutarlılığı',
                  value: profile.communicationAlignmentScore,
                  color: t.peach,
                  subtitle: 'Söylem ile davranış uyumu',
                ),
                ProfileScoreBar(
                  label: 'Kendini koruma',
                  value: profile.selfProtectionScore,
                  color: t.dustyRose,
                  subtitle: 'Kaçınma ve mesafe refleksi',
                ),
                ProfileScoreBar(
                  label: 'İlişki hazırlığı',
                  value: profile.relationshipReadiness,
                  color: t.roseGold,
                  subtitle: 'Tüm metriklerin ortalaması',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Belief scale bar chart
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Romantik İnanç Haritası',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '1-7 skalasında aşka dair inançların',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                MiniBarChart(
                  values: <double>[
                    profile.beliefRightPersonFindsWay.toDouble(),
                    profile.beliefChemistryFeltFast.toDouble(),
                    profile.beliefStrongAttractionIsSign.toDouble(),
                    profile.beliefFeelsRightOrNot.toDouble(),
                    profile.beliefFirstFeelingsAreTruth.toDouble(),
                    profile.beliefPotentialEqualsValue.toDouble(),
                    profile.beliefAmbiguityIsNormal.toDouble(),
                    profile.beliefLoveOvercomesIssues.toDouble(),
                  ],
                  labels: const <String>[
                    'Doğru kişi\nyolunu\nbulur',
                    'Kimya\nhızlı\nhissedilir',
                    'Güçlü\nçekim\nişarettir',
                    'Ya hisseder\nya\nhissetmez',
                    'İlk hisler\ngerçektir',
                    'Potansiyel\n= değer',
                    'Belirsizlik\nnormal',
                    'Aşk\nsorunları\naşar',
                  ],
                  barColor: t.roseGold,
                ),
              ],
            ),
          ),

          // Inconsistencies — show ALL, not just 2
          if (profile.detectInconsistencies().isNotEmpty) ...<Widget>[
            const SizedBox(height: 18),
            SectionHeader(
              kicker: 'TUTARSIZLIK TESPİTİ',
              title: '${profile.detectInconsistencies().length} çelişki bulundu',
            ),
            const SizedBox(height: 12),
            ...profile
                .detectInconsistencies()
                .map(
                  (ProfileInconsistency issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InconsistencyCard(
                      title: issue.title,
                      explanation: issue.explanation,
                      severity: issue.severity,
                    ),
                  ),
                ),
          ],
          const SizedBox(height: 22),
        ],

        // ── Decision Board ──
        SectionHeader(
          kicker: 'DECISION BOARD',
          title: 'Bugünün odağı',
          trailing: TagPill(text: controller.patternStageLabel),
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          child: Text(
            controller.todayFocus,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 20),

        // ── Check-ins ──
        const SectionHeader(
          kicker: 'OUTCOME LOOP',
          title: 'Bekleyen check-inler',
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          SurfaceCard(
            child: Text(
              'İlk reflection sonrasında 7. ve 14. gün check-in görevleri burada sıralanacak.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        else
          ...tasks.map(
            (PendingCheckInTask task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PendingCheckInCard(
                task: task,
                onOpen: () {
                  final JournalEntry entry =
                      controller.journalEntries[task.entryIndex];
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => CheckInPage(
                        controller: controller,
                        entryIndex: task.entryIndex,
                        entry: entry,
                        day: task.day,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: 20),

        // ── Clarity Map ──
        const SectionHeader(
          kicker: 'CLARITY MAP',
          title: 'Son rapor görünümü',
        ),
        const SizedBox(height: 12),
        if (latest == null)
          SurfaceCard(
            child: Text(
              'İlk reflection sonrasında burada saygı, karşılıklık, duygusal güvenlik, tempo ve niyet uyumu birlikte görünecek.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: latest.report.dimensions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 164,
            ),
            itemBuilder: (BuildContext context, int index) {
              return DimensionTile(dimension: latest.report.dimensions[index]);
            },
          ),
        const SizedBox(height: 20),

        // ── Memory ──
        const SectionHeader(
          kicker: 'MEMORY LAYER',
          title: 'Hafıza ve kalibrasyon',
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _MetricCard(
                title: 'Tekrar eden sinyal',
                value: controller.repeatedSignalSnapshot,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Kalibrasyon',
                value: controller.calibrationSnapshot,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Journal
// ═══════════════════════════════════════════════

class JournalPage extends StatelessWidget {
  const JournalPage({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  Widget build(BuildContext context) {
    return PremiumScrollScaffold(
      key: const Key('journal_screen'),
      children: <Widget>[
        SectionHeader(
          kicker: 'RELATIONSHIP MEMORY',
          title: 'Journal',
          trailing:
              TagPill(text: '${controller.journalEntries.length} session'),
        ),
        const SizedBox(height: 8),
        Text(
          'Buluşma geçmişi ikili başarılı/başarısız etiketiyle değil; outcome dili, check-in timeline ve validation notlarıyla saklanır.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        if (controller.journalEntries.isEmpty) ...<Widget>[
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Henüz kayıt yok',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'İlk reflection\'dan sonra burada session summary, confidence posture ve pending check-in\'ler oluşacak.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            tint: t.charcoal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Bu hafızada ne tutulur?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    TagPill(text: 'Outcome label'),
                    TagPill(text: 'Validation notes'),
                    TagPill(text: 'Evidence mix'),
                    TagPill(text: '7/14 gün check-ins'),
                  ],
                ),
              ],
            ),
          ),
        ] else
          ...List<Widget>.generate(controller.journalEntries.length,
              (int index) {
            final JournalEntry entry = controller.journalEntries[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _JournalEntryCard(
                entry: entry,
                onOpen: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          JournalEntryDetailPage(
                        controller: controller,
                        entryIndex: index,
                        entry: entry,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Pattern Lab
// ═══════════════════════════════════════════════

class PatternLabPage extends StatelessWidget {
  const PatternLabPage({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  Widget build(BuildContext context) {
    final List<String> candidates = controller.strongestPatternCandidates;
    final OnboardingProfile? profile = controller.profile;

    return PremiumScrollScaffold(
      children: <Widget>[
        const SectionHeader(
          kicker: 'CROSS-SESSION INTELLIGENCE',
          title: 'Pattern Lab',
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          tint: t.charcoal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                controller.patternStageLabel,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                controller.sessionsUntilPatternUnlock == 0
                    ? 'Pattern motoru artık zayıf tekrar eden sinyalleri yüzeye çıkarabilir.'
                    : '${controller.sessionsUntilPatternUnlock} reflection daha geldiğinde weak signal katmanı açılacak.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (controller.sessionCount / 3).clamp(0, 1).toDouble(),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Activation ladder',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              _ActivationStep(
                title: '3 session',
                subtitle: 'Zayıf sinyal',
                active: controller.sessionCount >= 3,
              ),
              const SizedBox(height: 12),
              _ActivationStep(
                title: '5 session',
                subtitle: 'Beliren örüntü',
                active: controller.sessionCount >= 5,
              ),
              const SizedBox(height: 12),
              _ActivationStep(
                title: '8+ session',
                subtitle: 'Güçlü tekrar eden örüntü',
                active: controller.sessionCount >= 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Erken pattern adayları',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (candidates.isEmpty)
                Text(
                  'İlk birkaç oturumdan sonra tekrar eden caution sinyalleri burada toplanacak.',
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: candidates
                      .map((String item) => TagPill(text: item))
                      .toList(growable: false),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Kör nokta izleme',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (profile?.blindSpots ?? const <String>[])
                    .map((String item) => TagPill(text: item))
                    .toList(growable: false),
              ),
              const SizedBox(height: 14),
              Text(controller.calibrationSnapshot),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Outcome memory',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (controller.journalEntries.isEmpty)
                Text(
                  'Outcome loop tamamlandıkça bu alan hangi ilk sinyallerin gerçekte neye dönüştüğünü gösterecek.',
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.journalEntries
                      .take(4)
                      .map((JournalEntry entry) =>
                          TagPill(text: entry.outcomeLabel))
                      .toList(growable: false),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Settings
// ═══════════════════════════════════════════════

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  Widget build(BuildContext context) {
    final OnboardingProfile? profile = controller.profile;

    return PremiumScrollScaffold(
      children: <Widget>[
        const SectionHeader(kicker: 'TRUST LAYER', title: 'Gizlilik & Ayarlar'),
        const SizedBox(height: 18),
        if (profile != null) ...<Widget>[
          GradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  profile.displayName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: t.roseGold),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.profileSummary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: t.ivoryText.withValues(alpha: 0.82),
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RadialScoreGauge(
                      label: 'Hazırlık',
                      value: profile.relationshipReadiness,
                      size: 70,
                      color: t.roseGold,
                    ),
                    RadialScoreGauge(
                      label: 'Farkındalık',
                      value: profile.selfAwarenessScore,
                      size: 70,
                      color: t.warmGold,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    TagPill(text: profile.goal.label),
                    TagPill(text: profile.pacingPreference.label),
                    TagPill(text: 'Güvence: ${profile.assuranceNeed.label}'),
                    TagPill(
                      text:
                          'İdealizasyon: ${(profile.idealizationScore * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        ProfileEditPage(controller: controller),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Profili Düzenle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: t.roseGold,
                side: BorderSide(color: t.roseGold.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Retention policy',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(
                'Ses kayıtları varsayılan olarak 30 gün tutulur. Yapılandırılmış hafıza öğeleri hesap silinince temizlenir.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Data & deletion controls',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  TagPill(text: 'Delete session'),
                  TagPill(text: 'Delete account'),
                  TagPill(text: 'Policy acceptance'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          tint: t.charcoal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Build diagnostics',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  const TagPill(text: 'schema=v2'),
                  TagPill(text: '${controller.sessionCount} reflection'),
                  TagPill(
                      text: '${controller.pendingCheckInCount} pending'),
                  TagPill(text: controller.patternStageLabel),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Helpers
// ═══════════════════════════════════════════════

String _moodEmoji(double value) {
  if (value >= 0.8) return '😊';
  if (value >= 0.6) return '🙂';
  if (value >= 0.4) return '😐';
  if (value >= 0.2) return '😔';
  return '😞';
}

// ═══════════════════════════════════════════════
//  Shared Widgets
// ═══════════════════════════════════════════════

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(value, maxLines: 4, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ActivationStep extends StatelessWidget {
  const _ActivationStep({
    required this.title,
    required this.subtitle,
    required this.active,
  });
  final String title;
  final String subtitle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? t.roseGold : t.mutedText.withValues(alpha: 0.3);
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(subtitle),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime value) {
  final String day = value.day.toString().padLeft(2, '0');
  final String month = value.month.toString().padLeft(2, '0');
  return '$day.$month.${value.year}';
}

String _validationBreakdown(Map<String, ValidationChoice> validations) {
  if (validations.isEmpty) return 'Henüz validation seçimi yok.';
  int dogru = 0, eksik = 0, yanlis = 0, veriYetersiz = 0;
  for (final ValidationChoice choice in validations.values) {
    switch (choice) {
      case ValidationChoice.dogru:
        dogru += 1;
      case ValidationChoice.eksik:
        eksik += 1;
      case ValidationChoice.yanlis:
        yanlis += 1;
      case ValidationChoice.veriYetersiz:
        veriYetersiz += 1;
    }
  }
  return 'Doğru: $dogru · Eksik: $eksik · Yanlış: $yanlis · Veri yetersiz: $veriYetersiz';
}

// ═══════════════════════════════════════════════
//  Journal Entry Detail
// ═══════════════════════════════════════════════

class JournalEntryDetailPage extends StatelessWidget {
  const JournalEntryDetailPage({
    super.key,
    required this.controller,
    required this.entryIndex,
    required this.entry,
  });
  final MatchProfileController controller;
  final int entryIndex;
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final List<PendingCheckInTask> pendingTasks = controller.pendingCheckInTasks
        .where((PendingCheckInTask t) => t.entryIndex == entryIndex)
        .toList(growable: false);

    return PremiumScrollScaffold(
      appBar: AppBar(title: const Text('Journal Detail')),
      children: <Widget>[
        GradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(entry.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: t.roseGold)),
                  ),
                  TagPill(text: entry.outcomeLabel),
                ],
              ),
              const SizedBox(height: 10),
              Text(_formatDate(entry.createdAt),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: t.softText)),
              const SizedBox(height: 12),
              Text(entry.report.summary,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: t.ivoryText.withValues(alpha: 0.84))),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Signal mix',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  TagPill(
                      text: '${entry.report.positiveSignals.length} positive'),
                  TagPill(
                      text: '${entry.report.cautionSignals.length} caution'),
                  TagPill(
                      text: '${entry.report.missingDataPoints.length} gaps'),
                  TagPill(text: '${entry.pendingCheckIns.length} pending'),
                ],
              ),
              const SizedBox(height: 14),
              Text(entry.report.nextStep),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entry.report.dimensions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 164,
          ),
          itemBuilder: (BuildContext context, int index) =>
              DimensionTile(dimension: entry.report.dimensions[index]),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Validation feedback',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(_validationBreakdown(entry.validations)),
              if (entry.validationFeedback.hasAny) ...<Widget>[
                const SizedBox(height: 12),
                ...entry.validationFeedback.notes
                    .map((String note) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('- $note'),
                        )),
              ],
            ],
          ),
        ),
        if (pendingTasks.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          SurfaceCard(
            tint: t.charcoal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Pending check-ins',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...pendingTasks.map(
                  (PendingCheckInTask task) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FilledButton.tonal(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (BuildContext context) => CheckInPage(
                            controller: controller,
                            entryIndex: entryIndex,
                            entry: entry,
                            day: task.day,
                          ),
                        ));
                      },
                      child: Text('${task.day}. gün check-in aç'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (entry.completedCheckIns.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Completed check-ins',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...entry.completedCheckIns.map(
                  (CheckInRecord record) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            TagPill(text: '${record.day}. gün'),
                            TagPill(text: record.outcome.label),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(record.interactionState),
                        const SizedBox(height: 4),
                        Text(record.consistencyState),
                        if (record.note.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: 6),
                          Text(record.note),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Check-in Page
// ═══════════════════════════════════════════════

class CheckInPage extends StatefulWidget {
  const CheckInPage({
    super.key,
    required this.controller,
    required this.entryIndex,
    required this.entry,
    required this.day,
  });
  final MatchProfileController controller;
  final int entryIndex;
  final JournalEntry entry;
  final int day;

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  CheckInOutcome _outcome = CheckInOutcome.stillTalking;
  String _interactionState = 'Mesajlaşma sürüyor';
  String _consistencyState = 'Hâlâ belirsiz';
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScrollScaffold(
      appBar: AppBar(title: const Text('Check-in')),
      children: <Widget>[
        SurfaceCard(
          tint: t.charcoal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.entry.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('${widget.day}. gün outcome check',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Text(
                'Outcome loop burada ilk belirsizliklerin gerçekte neye dönüştüğünü toplar.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Bu hikaye nereye gitti?',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CheckInOutcome.values
                    .map((CheckInOutcome outcome) => ChoiceChip(
                          label: Text(outcome.label),
                          selected: _outcome == outcome,
                          onSelected: (_) =>
                              setState(() => _outcome = outcome),
                        ))
                    .toList(growable: false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _DropdownField(
                label: 'Interaction state',
                value: _interactionState,
                items: const <String>[
                  'Tekrar görüştük',
                  'Mesajlaşma sürüyor',
                  'İletişim zayıfladı',
                  'İletişim koptu',
                ],
                onChanged: (String? v) {
                  if (v != null) setState(() => _interactionState = v);
                },
              ),
              const SizedBox(height: 14),
              _DropdownField(
                label: 'Consistency state',
                value: _consistencyState,
                items: const <String>[
                  'Daha tutarlı göründü',
                  'Hâlâ belirsiz',
                  'Daha tutarsız hissettirdi',
                ],
                onChanged: (String? v) {
                  if (v != null) setState(() => _consistencyState = v);
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Kısa not',
                  hintText: 'Hangi belirsizlik doğrulandı ya da boşta kaldı?',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          key: const Key('checkin_save_button'),
          onPressed: _save,
          child: const Text('Check-in\'i kaydet'),
        ),
      ],
    );
  }

  void _save() {
    widget.controller.completeCheckIn(
      entryIndex: widget.entryIndex,
      day: widget.day,
      outcome: _outcome,
      interactionState: _interactionState,
      consistencyState: _consistencyState,
      note: _noteController.text.trim(),
    );
    Navigator.of(context).pop();
  }
}

// ═══════════════════════════════════════════════
//  Card Widgets
// ═══════════════════════════════════════════════

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry, required this.onOpen});
  final JournalEntry entry;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(entry.title,
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              TagPill(text: entry.outcomeLabel),
            ],
          ),
          const SizedBox(height: 8),
          Text(_formatDate(entry.createdAt)),
          const SizedBox(height: 12),
          Text(entry.report.summary,
              maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              TagPill(text: '${entry.pendingCheckIns.length} pending'),
              TagPill(text: '${entry.completedCheckIns.length} completed'),
              TagPill(text: '${entry.report.cautionSignals.length} caution'),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.tonal(
              onPressed: onOpen, child: const Text('Session detail')),
        ],
      ),
    );
  }
}

class _PendingCheckInCard extends StatelessWidget {
  const _PendingCheckInCard({required this.task, required this.onOpen});
  final PendingCheckInTask task;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: t.roseGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text('${task.day}',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: t.roseGold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(task.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${task.day}. gün outcome check'),
                const SizedBox(height: 4),
                Text(_formatDate(task.scheduledFor),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(onPressed: onOpen, child: const Text('Aç')),
        ],
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
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((String item) =>
              DropdownMenuItem<String>(value: item, child: Text(item)))
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}
