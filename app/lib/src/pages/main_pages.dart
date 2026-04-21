import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../ai/ai_config.dart';
import '../ai/ai_contracts.dart';
import '../controller.dart';
import '../models.dart';
import '../notification_service.dart';
import '../theme.dart' as t;
import '../widgets/app_widgets.dart';
import 'daily_pages.dart';
import 'profile_edit_page.dart';
import 'reflection_pages.dart';

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
    final UserPsycheAnchor? psycheAnchor = profile?.psycheAnchor;

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
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: t.roseGold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: t.roseGold.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      'ÖZEL',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: t.roseGold.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            letterSpacing: 1.0,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                latest == null
                    ? 'Romantik karar profilin hazır. İlk yansıtma ile kişiselleştirilmiş içgörü akışını başlat.'
                    : latest.report.summary,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: t.textOnDark.withValues(alpha: 0.84),
                    ),
              ),
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  HeroStat(
                    label: 'Yansıtma',
                    value: controller.sessionCount.toString(),
                  ),
                  const SizedBox(width: 22),
                  HeroStat(
                    label: 'Açık kayıt',
                    value: controller.pendingCheckInCount.toString(),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: HeroStat(
                      label: 'Döngü',
                      value: controller.patternStageLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // ── Daily Engagement — Gradient card ──
        if (!controller.hasTodayCheckIn)
          FeatureGradientCard(
            kicker: 'GÜNLÜK KAYIT',
            title: 'Bugün Nasılsın?',
            description:
                '${controller.checkInStreak} gün seri · ${controller.interactionCount} etkileşim kayıtlı',
            icon: Icons.edit_calendar_rounded,
            gradientColors: SectionGradients.relationship,
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
                        '${controller.checkInStreak} gün seri · ${controller.interactionCount} etkileşim',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 22),

        // ── Hızlı Aksiyonlar ──
        if (controller.sessionCount == 0) ...<Widget>[
          const SectionHeader(
            kicker: 'BAŞLA',
            title: 'Sıradaki adımın',
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.graphic_eq_rounded,
            title: 'İlk yansıtmanı yap',
            subtitle: 'Bir buluşma veya ilişki deneyimini değerlendir',
            color: t.primaryYellow,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (BuildContext context) =>
                    ReflectionComposerPage(controller: controller),
              ));
            },
          ),
          const SizedBox(height: 8),
          _ActionCard(
            icon: Icons.people_outline_rounded,
            title: 'Bir etkileşim kaydet',
            subtitle: 'Bugün biriyle konuştun mu? Not al',
            color: t.accentOrange,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (BuildContext context) =>
                    InteractionLogFormPage(controller: controller),
              ));
            },
          ),
          const SizedBox(height: 22),
        ],

        // ── Karakter Profili ──
        if (profile != null) ...<Widget>[
          const SectionHeader(
            kicker: 'KARAKTER ANALİZİ',
            title: 'Senin profil özetin',
          ),
          const SizedBox(height: 14),

          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: t.primaryYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.person_rounded, color: t.primaryDark, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Senin Profilin', style: Theme.of(context).textTheme.titleLarge),
                          Text(
                            _profileOneLiner(profile),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // 3 key insights in plain language
                _InsightRow(
                  emoji: '💪',
                  label: 'Güçlü tarafın',
                  text: _strongestAreaCopy(profile),
                  color: t.softGreen,
                ),
                const SizedBox(height: 10),
                _InsightRow(
                  emoji: '⚠️',
                  label: 'Dikkat alanın',
                  text: _watchoutCopy(profile),
                  color: t.roseCaution,
                ),
                const SizedBox(height: 10),
                _InsightRow(
                  emoji: '🎯',
                  label: 'Bugün odaklan',
                  text: _focusCopy(profile, controller),
                  color: t.roseGold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Radar chart — visual profile overview
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Genel Bakış',
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
                  'Skorların',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  runAlignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: <Widget>[
                    RadialScoreGauge(
                      label: 'Abartma riski',
                      value: profile.idealizationScore,
                      size: 80,
                      color: profile.highIdealization
                          ? t.roseCaution
                          : t.roseGold,
                      subtitle: profile.highIdealization ? 'Yüksek risk' : null,
                    ),
                    RadialScoreGauge(
                      label: 'Sınır gücü',
                      value: profile.boundaryHealthScore,
                      size: 80,
                      color: profile.boundaryHealthScore < 0.4
                          ? t.roseCaution
                          : t.softGreen,
                      subtitle:
                          profile.boundaryHealthScore < 0.4 ? 'Düşük' : 'Denge',
                    ),
                    RadialScoreGauge(
                      label: 'Duygusal yük',
                      value: profile.emotionalDependencyRisk,
                      size: 80,
                      color: profile.emotionalDependencyRisk > 0.5
                          ? t.roseCaution
                          : t.amber,
                      subtitle: profile.emotionalDependencyRisk > 0.5
                          ? 'Dikkat'
                          : 'Orta',
                    ),
                    RadialScoreGauge(
                      label: 'Öz farkındalık',
                      value: profile.selfAwarenessScore,
                      size: 80,
                      color: profile.selfAwarenessScore > 0.7
                          ? t.softGreen
                          : t.warmGold,
                      subtitle:
                          profile.selfAwarenessScore > 0.7 ? 'Güçlü' : 'Gelişiyor',
                    ),
                    RadialScoreGauge(
                      label: 'İletişim',
                      value: profile.communicationAlignmentScore,
                      size: 80,
                      color: profile.communicationAlignmentScore > 0.65
                          ? t.blushRose
                          : t.warmGold,
                      subtitle: 'Tutarlılık',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const <Widget>[
                    TagPill(text: '0-39: dikkat'),
                    TagPill(text: '40-69: gelişiyor'),
                    TagPill(text: '70+: güçlü'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Detaylı Görünüm',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Her çizgide solda dikkat, ortada denge, sağda güçlü alan var. Noktan hangi taraftaysa hızlı okuma oradan başlar.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                SegmentedScoreBand(
                  label: 'Gerçeği ayırma',
                  value: profile.romanticRealismScore,
                  leadingCaption: 'Çekim baskın',
                  centerCaption: 'Dengeleniyor',
                  trailingCaption: 'Gerçekçi',
                  color: t.softGreen,
                ),
                const SizedBox(height: 14),
                SegmentedScoreBand(
                  label: 'Sınır uygulama',
                  value: profile.boundaryHealthScore,
                  leadingCaption: 'Zorlanıyor',
                  centerCaption: 'Gelişiyor',
                  trailingCaption: 'Net',
                  color: t.roseGold,
                ),
                const SizedBox(height: 14),
                SegmentedScoreBand(
                  label: 'Duygusal yük',
                  value: 1 - profile.emotionalDependencyRisk,
                  leadingCaption: 'Kişiye bağlı',
                  centerCaption: 'Karışık',
                  trailingCaption: 'Daha bağımsız',
                  color: t.warmGold,
                ),
                const SizedBox(height: 14),
                SegmentedScoreBand(
                  label: 'Yakınlıkta denge',
                  value: 1 - profile.selfProtectionScore,
                  leadingCaption: 'Geri çekiliyor',
                  centerCaption: 'Kararsız',
                  trailingCaption: 'Açık',
                  color: t.blushRose,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (psycheAnchor != null &&
              (psycheAnchor.coreRealities.isNotEmpty ||
                  psycheAnchor.hiddenTriggers.isNotEmpty ||
                  psycheAnchor.sensitiveMemories.isNotEmpty)) ...<Widget>[
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Sana ozel baglam',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TagPill(
                        text: controller.lastMirrorRun?.mode == AiRunMode.llm
                            ? 'LLM okudu'
                            : 'Temel okuma',
                        background:
                            (controller.lastMirrorRun?.mode == AiRunMode.llm
                                    ? t.softGreen
                                    : t.roseGold)
                                .withValues(alpha: 0.12),
                        foreground: controller.lastMirrorRun?.mode == AiRunMode.llm
                            ? t.softGreen
                            : t.roseGold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paylastigin mahrem veya zor hayat baglami burada sadece not olarak durmaz. Sonraki yorumlarin tonunu, risk okumalarini ve onerileri degistirir.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (psycheAnchor.sensitiveMemories.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    SensitiveContextDeck(
                      memories: psycheAnchor.sensitiveMemories,
                      maxItems: 3,
                      title: 'Goz ardi etmeyecegimiz ozel baglam',
                      subtitle:
                          'Buradaki her satir sonraki yorumlarda generic degil, sana ozel bir ton kurmak icin kullanilir.',
                    ),
                  ],
                  if (psycheAnchor.coreRealities.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      'Merkezde tuttugumuz gercekler',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: psycheAnchor.coreRealities
                          .map((String item) => TagPill(text: item))
                          .toList(growable: false),
                    ),
                  ],
                  if (psycheAnchor.hiddenTriggers.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      'Tetiklenen alanlar',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: psycheAnchor.hiddenTriggers
                          .map(
                            (String item) => TagPill(
                              text: item,
                              background: t.roseCaution.withValues(alpha: 0.1),
                              foreground: t.roseCaution,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Hizli yorum matrisi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Her kutu tek bakista neyin guclu, neyin dikkat istedigini soyler. Renk yogunlugu arttikca o alan daha belirgin demektir.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.28,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: <Widget>[
                    ScoreHeatTile(
                      label: 'Gerceklik',
                      value: profile.romanticRealismScore,
                      color: t.softGreen,
                      lowCaption: 'Cekim onde',
                      midCaption: 'Dengeleniyor',
                      highCaption: 'Gerceklik agir',
                    ),
                    ScoreHeatTile(
                      label: 'Sinir',
                      value: profile.boundaryHealthScore,
                      color: t.roseGold,
                      lowCaption: 'Sinir esniyor',
                      midCaption: 'Gelisiyor',
                      highCaption: 'Sinir net',
                    ),
                    ScoreHeatTile(
                      label: 'Duygusal denge',
                      value: 1 - profile.emotionalDependencyRisk,
                      color: t.warmGold,
                      lowCaption: 'Kisiye bagli',
                      midCaption: 'Dalgalaniyor',
                      highCaption: 'Daha bagimsiz',
                    ),
                    ScoreHeatTile(
                      label: 'Oz farkindalik',
                      value: profile.selfAwarenessScore,
                      color: t.blushRose,
                      lowCaption: 'Kaciyor',
                      midCaption: 'Fark ediyor',
                      highCaption: 'Kendini goruyor',
                    ),
                    ScoreHeatTile(
                      label: 'Iletisim',
                      value: profile.communicationAlignmentScore,
                      color: t.peach,
                      lowCaption: 'Uyum dusuk',
                      midCaption: 'Yer yer acik',
                      highCaption: 'Tutarlilik guclu',
                    ),
                    ScoreHeatTile(
                      label: 'Hazirlik',
                      value: profile.relationshipReadiness,
                      color: t.roseGold,
                      lowCaption: 'Zemin daginik',
                      midCaption: 'Toparlaniyor',
                      highCaption: 'Daha hazir',
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
                  'Kısa okuma',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
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

          if (controller.aiAnalysisInProgress || controller.latestDeepAnalysis != null)
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          controller.latestDeepAnalysis?.isAIEnhanced == true
                              ? 'AI derin okuması'
                              : 'Kişiselleştirme motoru',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TagPill(
                        text: controller.personalizationEngineLabel,
                        background: (controller.latestDeepAnalysis?.isAIEnhanced == true
                                ? t.softGreen
                                : t.roseGold)
                            .withValues(alpha: 0.12),
                        foreground: controller.latestDeepAnalysis?.isAIEnhanced == true
                            ? t.softGreen
                            : t.roseGold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.aiAnalysisInProgress
                        ? 'Profil anlatını daha kişisel bir dile çeviriyoruz.'
                        : 'Bu alan profilini sıradan etiketler yerine sana özgü dil, kör nokta ve önerilerle yorumlar.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (controller.lastMirrorRun != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: t.graphite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: t.smoky.withValues(alpha: 0.4),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Son ayna raporu',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${controller.lastMirrorRun!.provider ?? 'local'} • ${controller.lastMirrorRun!.latencyMs} ms',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.lastMirrorRun!.mode.name == 'llm'
                                ? 'Canlı LLM ile üretildi'
                                : 'Bu turda temel mod kullanıldı',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: controller.lastMirrorRun!.isEnhanced
                                          ? t.softGreen
                                          : t.roseGold,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                          if (controller.lastMirrorRun!.note?.trim().isNotEmpty ??
                              false) ...<Widget>[
                            const SizedBox(height: 6),
                            Text(
                              controller.lastMirrorRun!.note!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          if (controller.lastMirrorRun!.error?.trim().isNotEmpty ??
                              false) ...<Widget>[
                            const SizedBox(height: 6),
                            Text(
                              controller.lastMirrorRun!.error!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: t.roseCaution,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (controller.aiAnalysisInProgress) ...<Widget>[
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(t.roseGold),
                        backgroundColor: t.smoky,
                      ),
                    ),
                  ],
                  if (!controller.aiAnalysisInProgress &&
                      controller.latestDeepAnalysis != null) ...<Widget>[
                    const SizedBox(height: 16),
                    _DashboardCallout(
                      title: 'Sana dair okuma',
                      body: controller.latestDeepAnalysis!.profileInsight.isNotEmpty
                          ? controller.latestDeepAnalysis!.profileInsight
                          : controller.profileSummary,
                      accent: t.roseGold,
                    ),
                    if (controller.latestDeepAnalysis!.blindSpotWarning.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _DashboardCallout(
                          title: 'Şu an dikkat et',
                          body: controller.latestDeepAnalysis!.blindSpotWarning,
                          accent: t.roseCaution,
                        ),
                      ),
                    if (controller.latestDeepAnalysis!.personalizedAdvice.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _DashboardCallout(
                          title: 'Bu hafta dene',
                          body: controller.latestDeepAnalysis!.personalizedAdvice,
                          accent: t.softGreen,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          if (controller.aiAnalysisInProgress || controller.latestDeepAnalysis != null)
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
                  label: 'Gerçeğe yakın bakış',
                  value: profile.romanticRealismScore,
                  color: t.softGreen,
                  subtitle: 'Çekim ile gerçeği ayırabilme',
                ),
                ProfileScoreBar(
                  label: 'Kendini görme',
                  value: profile.selfAwarenessScore,
                  color: t.warmGold,
                  subtitle: 'Döngünü ve kör noktanı fark etme',
                ),
                ProfileScoreBar(
                  label: 'Duygu yönetimi',
                  value: profile.emotionalRegulationScore,
                  color: t.blushRose,
                  subtitle: 'Zorlandığında dengede kalabilme',
                ),
                ProfileScoreBar(
                  label: 'Söz ve davranış uyumu',
                  value: profile.communicationAlignmentScore,
                  color: t.peach,
                  subtitle: 'Ne söylediğin ile ne yaptığın ne kadar yakın',
                ),
                ProfileScoreBar(
                  label: 'Kendini koruma',
                  value: profile.selfProtectionScore,
                  color: t.dustyRose,
                  subtitle: 'Yakınlıkta frene basma refleksi',
                ),
                ProfileScoreBar(
                  label: 'İlişkiye hazır hissetme',
                  value: profile.relationshipReadiness,
                  color: t.roseGold,
                  subtitle: 'Genel denge görünümü',
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 620,
                    child: MiniBarChart(
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
                        'Doğru kişi\nkendi yolunu\nbulur',
                        'Kimya\nçok hızlı\nanlaşılır',
                        'Güçlü çekim\nönemli bir\nişarettir',
                        'Ya olur\nya olmaz',
                        'İlk hislerim\ngenelde\ndoğrudur',
                        'Potansiyel de\nbugün kadar\nönemlidir',
                        'Başta biraz\nbelirsizlik\nnormaldir',
                        'Aşk varsa\nsorunlar\naşılır',
                      ],
                      barColor: t.roseGold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _beliefSummary(profile),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
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
          kicker: 'KARAR PANOSU',
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
          kicker: 'SONUÇ DÖNGÜSÜ',
          title: 'Bekleyen kayıtlar',
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          SurfaceCard(
            child: Text(
              'İlk yansıtma sonrasında 7. ve 14. gün kayıt görevleri burada sıralanacak.',
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
          kicker: 'NETLİK HARİTASI',
          title: 'Son rapor görünümü',
        ),
        const SizedBox(height: 12),
        if (latest == null)
          SurfaceCard(
            child: Text(
              'İlk yansıtma sonrasında burada saygı, karşılıklık, duygusal güvenlik, tempo ve niyet uyumu birlikte görünecek.',
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
          kicker: 'HAFIZA KATMANI',
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
          kicker: 'İLİŞKİ HAFIZASI',
          title: 'Günlük',
          trailing:
              TagPill(text: '${controller.journalEntries.length} oturum'),
        ),
        const SizedBox(height: 8),
        Text(
          'Buluşma geçmişi ikili başarılı/başarısız etiketiyle değil; sonuç dili, kayıt zaman çizelgesi ve doğrulama notlarıyla saklanır.',
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
                  'İlk yansıtmadan sonra burada oturum özeti, güven duruşu ve bekleyen kayıtlar oluşacak.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            tint: t.cardWhite,
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
                    TagPill(text: 'Sonuç etiketi'),
                    TagPill(text: 'Doğrulama notları'),
                    TagPill(text: 'Kanıt karışımı'),
                    TagPill(text: '7/14 gün kayıtlar'),
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
          kicker: 'OTURUMLAR ARASI ANALİZ',
          title: 'Döngü Analizi',
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          tint: t.cardWhite,
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
                    ? 'Döngü motoru artık zayıf tekrar eden sinyalleri yüzeye çıkarabilir.'
                    : '${controller.sessionsUntilPatternUnlock} yansıtma daha geldiğinde zayıf sinyal katmanı açılacak.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (controller.sessionCount / 3).clamp(0, 1).toDouble(),
                  minHeight: 3,
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
              Text('Etkinleştirme basamakları',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              _ActivationStep(
                title: '3 oturum',
                subtitle: 'Zayıf sinyal',
                active: controller.sessionCount >= 3,
              ),
              const SizedBox(height: 12),
              _ActivationStep(
                title: '5 oturum',
                subtitle: 'Beliren örüntü',
                active: controller.sessionCount >= 5,
              ),
              const SizedBox(height: 12),
              _ActivationStep(
                title: '8+ oturum',
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
              Text('Erken döngü adayları',
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
              Text('Sonuç hafızası',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (controller.journalEntries.isEmpty)
                Text(
                  'Sonuç döngüsü tamamlandıkça bu alan hangi ilk sinyallerin gerçekte neye dönüştüğünü gösterecek.',
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _dailyNotifications = true;
  bool _weeklyNotifications = true;
  bool _insightNotifications = true;

  final TextEditingController _geminiKeyCtrl = TextEditingController();
  final TextEditingController _groqKeyCtrl = TextEditingController();
  final TextEditingController _hfKeyCtrl = TextEditingController();
  final TextEditingController _supabaseUrlCtrl = TextEditingController();
  final TextEditingController _supabaseAnonKeyCtrl = TextEditingController();
  bool _showApiKeys = false;

  MatchProfileController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    // Kaydedilmiş AI anahtarlarını form alanlarına yansıt.
    // main.dart içinde AIConfig.loadFromStorage() tamamlanmış olduğu için
    // instance doğrudan güncel değerleri içeriyor.
    _hydrateFromConfig();
  }

  /// AIConfig'deki mevcut değerleri controller'lara yaz. Temizle/Kaydet
  /// sonrasında da UI'yi senkron tutmak için tekrar çağrılabilir.
  void _hydrateFromConfig() {
    final AIConfig cfg = AIConfig.instance;
    _geminiKeyCtrl.text = cfg.geminiApiKey;
    _groqKeyCtrl.text = cfg.groqApiKey;
    _hfKeyCtrl.text = cfg.hfApiKey;
    _supabaseUrlCtrl.text = cfg.supabaseUrl;
    _supabaseAnonKeyCtrl.text = cfg.supabaseAnonKey;
  }

  @override
  void dispose() {
    _geminiKeyCtrl.dispose();
    _groqKeyCtrl.dispose();
    _hfKeyCtrl.dispose();
    _supabaseUrlCtrl.dispose();
    _supabaseAnonKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingProfile? profile = controller.profile;

    return PremiumScrollScaffold(
      children: <Widget>[
        const SectionHeader(kicker: 'GÜVENLİK KATMANI', title: 'Gizlilik & Ayarlar'),
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
                        color: t.textOnDark.withValues(alpha: 0.82),
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
                          'İdealleştirme: ${(profile.idealizationScore * 100).toStringAsFixed(0)}%',
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
              Text('Saklama politikası',
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
              Text('Veri ve silme kontrolleri',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  TagPill(text: 'Oturumu sil'),
                  TagPill(text: 'Hesabı sil'),
                  TagPill(text: 'Politika kabul'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          tint: t.cardWhite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Yapı bilgisi',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  const TagPill(text: 'schema=v2'),
                  TagPill(text: '${controller.sessionCount} yansıtma'),
                  TagPill(
                      text: '${controller.pendingCheckInCount} bekleyen'),
                  TagPill(text: controller.patternStageLabel),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Bildirim Ayarları',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Günlük kayıt hatırlatması'),
                subtitle: const Text('Her akşam 20:00\'de hatırlatma'),
                value: _dailyNotifications,
                activeThumbColor: t.roseGold,
                contentPadding: EdgeInsets.zero,
                onChanged: (bool value) {
                  setState(() => _dailyNotifications = value);
                  if (value) {
                    NotificationService.instance.scheduleDailyCheckInReminder();
                  } else {
                    NotificationService.instance.cancelDailyReminder();
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Haftalık özet bildirimi'),
                subtitle: const Text('Her hafta özetin hazır olduğunda'),
                value: _weeklyNotifications,
                activeThumbColor: t.roseGold,
                contentPadding: EdgeInsets.zero,
                onChanged: (bool value) {
                  setState(() => _weeklyNotifications = value);
                  if (value) {
                    NotificationService.instance.scheduleWeeklySummaryReminder();
                  } else {
                    NotificationService.instance.cancelAllNotifications();
                    if (_dailyNotifications) {
                      NotificationService.instance.scheduleDailyCheckInReminder();
                    }
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Döngü ve içgörü uyarıları'),
                subtitle: const Text('Tekrar eden kalıplar tespit edildiğinde'),
                value: _insightNotifications,
                activeThumbColor: t.roseGold,
                contentPadding: EdgeInsets.zero,
                onChanged: (bool value) {
                  setState(() => _insightNotifications = value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onLongPress: () {
                  if (!kDebugMode) return;
                  setState(() => _showApiKeys = !_showApiKeys);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _showApiKeys
                            ? 'Geliştirici AI paneli açıldı'
                            : 'Geliştirici AI paneli gizlendi',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Kişiselleştirme motoru',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: controller.latestDeepAnalysis?.isAIEnhanced == true
                            ? t.softGreen.withValues(alpha: 0.15)
                            : t.smoky,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.personalizationEngineLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color:
                                  controller.latestDeepAnalysis?.isAIEnhanced ==
                                          true
                                      ? t.softGreen
                                      : t.mutedText,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu katman profilini, günlük kayıtlarını ve etkileşim notlarını sana daha özel hale getirir. Kullanıcı tarafında ayar gerektirmez; motor arka planda çalışır.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: t.softText),
              ),
              if (kDebugMode && _showApiKeys) const SizedBox(height: 12),
              if (kDebugMode && _showApiKeys)
                Text(
                  'Geliştirici paneli',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: t.roseGold,
                      ),
                ),
              if (kDebugMode && _showApiKeys) ...<Widget>[
                const SizedBox(height: 12),
                TextField(
                  controller: _geminiKeyCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Gemini API Anahtarı (Sohbet)',
                    hintText: 'AIza...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon:
                        const Icon(Icons.auto_awesome_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _groqKeyCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Groq API Anahtarı (Yapısal)',
                    hintText: 'gsk_...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.smart_toy_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _hfKeyCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'HuggingFace API Anahtarı',
                    hintText: 'hf_...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.hub_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _supabaseUrlCtrl,
                  decoration: InputDecoration(
                    labelText: 'Supabase URL',
                    hintText: 'https://xxx.supabase.co',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.cloud_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _supabaseAnonKeyCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Supabase Anon Key',
                    hintText: 'eyJ...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      controller.configureAI(
                        geminiApiKey: _geminiKeyCtrl.text.trim().isNotEmpty
                            ? _geminiKeyCtrl.text.trim()
                            : null,
                        groqApiKey: _groqKeyCtrl.text.trim().isNotEmpty
                            ? _groqKeyCtrl.text.trim()
                            : null,
                        huggingFaceApiKey: _hfKeyCtrl.text.trim().isNotEmpty
                            ? _hfKeyCtrl.text.trim()
                            : null,
                        supabaseUrl: _supabaseUrlCtrl.text.trim().isNotEmpty
                            ? _supabaseUrlCtrl.text.trim()
                            : null,
                        supabaseAnonKey:
                            _supabaseAnonKeyCtrl.text.trim().isNotEmpty
                                ? _supabaseAnonKeyCtrl.text.trim()
                                : null,
                      );
                      setState(() => _showApiKeys = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Yapay zeka motoru güncellendi'),
                          backgroundColor: t.softGreen.withValues(alpha: 0.9),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Kaydet ve Etkinleştir'),
                    style: FilledButton.styleFrom(
                      backgroundColor: t.roseGold,
                      foregroundColor: t.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final bool confirmed = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext ctx) => AlertDialog(
                              title: const Text('Anahtarları temizle?'),
                              content: const Text(
                                'Kayıtlı tüm AI anahtarları (Gemini, Groq, '
                                'HuggingFace, Supabase) bu cihazdan silinecek. '
                                'Kural tabanlı motor çalışmaya devam eder.',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(false),
                                  child: const Text('Vazgeç'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: t.roseGold,
                                    foregroundColor: t.textPrimary,
                                  ),
                                  child: const Text('Temizle'),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (!confirmed) return;
                      if (!context.mounted) return;

                      await controller.clearAIKeys();
                      if (!context.mounted) return;

                      setState(() {
                        _geminiKeyCtrl.clear();
                        _groqKeyCtrl.clear();
                        _hfKeyCtrl.clear();
                        _supabaseUrlCtrl.clear();
                        _supabaseAnonKeyCtrl.clear();
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('AI anahtarları temizlendi'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Anahtarları Temizle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.roseGold,
                      side: BorderSide(
                          color: t.roseGold.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
              if (controller.aiAnalysisInProgress) ...<Widget>[
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: t.roseGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Derin analiz devam ediyor...',
                        style: TextStyle(color: t.softText, fontSize: 13)),
                  ],
                ),
              ],
              if (controller.latestDeepAnalysis != null &&
                  (controller.isAIPipelineActive ||
                      controller.latestDeepAnalysis!.conceptMeanings.isNotEmpty)) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: t.softGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Son AI Analiz Sonucu',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: t.softGreen,
                            ),
                      ),
                      if (controller
                          .latestDeepAnalysis!.profileInsight.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            controller.latestDeepAnalysis!.profileInsight,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: t.textPrimary),
                          ),
                        ),
                      if (controller.latestDeepAnalysis!.profileInsight.isEmpty &&
                          controller.latestDeepAnalysis!.conceptMeanings.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            controller.latestDeepAnalysis!.conceptMeanings.values.first,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: t.textPrimary),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${controller.latestDeepAnalysis!.processingTimeMs} ms',
                          style: TextStyle(color: t.mutedText, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    final Color color = active ? t.roseGold : t.smoky;
    return Row(
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: active ? 0 : 1),
          ),
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
  if (validations.isEmpty) return 'Henüz doğrulama seçimi yok.';
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
      appBar: AppBar(
        title: const Text('Günlük Detayı'),
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
                      ?.copyWith(color: t.textOnDark.withValues(alpha: 0.84))),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Sinyal karışımı',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  TagPill(
                      text: '${entry.report.positiveSignals.length} olumlu'),
                  TagPill(
                      text: '${entry.report.cautionSignals.length} dikkat'),
                  TagPill(
                      text: '${entry.report.missingDataPoints.length} eksik'),
                  TagPill(text: '${entry.pendingCheckIns.length} bekleyen'),
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
              Text('Doğrulama geri bildirimi',
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
            tint: t.cardWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Bekleyen kayıtlar',
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
                      child: Text('${task.day}. gün kayıt aç'),
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
                Text('Tamamlanan kayıtlar',
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
      appBar: AppBar(
        title: const Text('Check-in'),
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
        SurfaceCard(
          tint: t.cardWhite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.entry.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('${widget.day}. gün sonuç kontrolü',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Text(
                'Sonuç döngüsü burada ilk belirsizliklerin gerçekte neye dönüştüğünü toplar.',
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
              PremiumTextField(
                controller: _noteController,
                label: 'Kısa not',
                hint: 'Hangi belirsizlik doğrulandı ya da boşta kaldı?',
                minLines: 3,
                maxLines: 5,
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

String _profileOneLiner(OnboardingProfile profile) {
  // Generate a friendly one-liner summary based on profile characteristics
  final List<String> traits = <String>[];

  if (profile.selfAwarenessScore > 0.65) {
    traits.add('kendini iyi tanıyan');
  } else {
    traits.add('kendini keşfetme yolunda');
  }

  if (profile.boundaryHealthScore > 0.6) {
    traits.add('sınırlarında net');
  } else if (profile.boundaryHealthScore < 0.4) {
    traits.add('sınırlarında çalışan');
  }

  if (profile.communicationAlignmentScore > 0.65) {
    traits.add('iletişiminde açık');
  }

  if (profile.highIdealization) {
    traits.add('çekime açık bir kalbi olan');
  }

  if (traits.isEmpty) {
    return 'Romantik karar yolculuğundaki senin anlık görünümü';
  }

  return '${traits.take(3).join(', ')} birisi';
}

String _strongestAreaCopy(OnboardingProfile profile) {
  final Map<String, double> areas = <String, double>{
    'Kendini dürüst okuyabiliyorsun.': profile.selfAwarenessScore,
    'Sınırlarını fark etme tarafın güçlü.': profile.boundaryHealthScore,
    'İletişimde ne istediğini görebiliyorsun.':
        profile.communicationAlignmentScore,
    'Duygusal dalgada tamamen kaybolmuyorsun.':
        profile.emotionalRegulationScore,
    'İlişkilere bakışında gerçek payı koruyabiliyorsun.':
        profile.romanticRealismScore,
  };
  return areas.entries.reduce(
    (MapEntry<String, double> a, MapEntry<String, double> b) =>
        a.value >= b.value ? a : b,
  ).key;
}

String _watchoutCopy(OnboardingProfile profile) {
  final Map<String, double> risks = <String, double>{
    'Çekimi olduğundan büyük okuyup erken umutlanabilirsin.':
        profile.idealizationScore,
    'Ruh halini karşı tarafın ilgisine fazla bağlayabilirsin.':
        profile.emotionalDependencyRisk,
    'Yakınlık arttığında frene basma eğilimin devreye girebilir.':
        profile.selfProtectionScore,
    'Sınır gördüğün şeyi uygulamaya dökmekte gecikebilirsin.':
        1 - profile.boundaryHealthScore,
  };
  return risks.entries.reduce(
    (MapEntry<String, double> a, MapEntry<String, double> b) =>
        a.value >= b.value ? a : b,
  ).key;
}

String _focusCopy(
  OnboardingProfile profile,
  MatchProfileController controller,
) {
  final dynamic deep = controller.latestDeepAnalysis;
  if (deep != null && deep.personalizedAdvice.isNotEmpty) {
    return deep.personalizedAdvice;
  }
  if (profile.highIdealization) {
    return 'Bu hafta his değil, davranış say. Bir kişide gördüğün 3 somut veri olmadan anlam büyütme.';
  }
  if (profile.emotionalDependencyRisk > 0.5) {
    return 'Duygunu tek bir kişiye değil, gününün geneline bağla. Ruh halini kimin sürüklediğini fark et.';
  }
  if (profile.selfProtectionScore > 0.5) {
    return 'Erken uzaklaşmadan önce gerçekten neyi koruduğunu kendine sor.';
  }
  return controller.todayFocus;
}

String _beliefSummary(OnboardingProfile profile) {
  final List<String> highBeliefs = <String>[];
  if (profile.beliefRightPersonFindsWay >= 6) {
    highBeliefs.add('doğru kişi bir şekilde yolunu bulur');
  }
  if (profile.beliefChemistryFeltFast >= 6) {
    highBeliefs.add('uyum hızlı hissedilir');
  }
  if (profile.beliefPotentialEqualsValue >= 6) {
    highBeliefs.add('potansiyel de bugünkü davranış kadar önemlidir');
  }
  if (highBeliefs.isEmpty) {
    return 'Bu bölüm özellikle ilk çekim, belirsizlik ve potansiyel okuma biçimini gösterir.';
  }
  return 'Burada en yüksek çıkan inançların: ${highBeliefs.take(2).join(' ve ')}. Yani zihnin ilk aşamada bazı sinyallere ekstra anlam yüklemeye yatkın olabilir.';
}

class _DashboardCallout extends StatelessWidget {
  const _DashboardCallout({
    required this.title,
    required this.body,
    required this.accent,
  });

  final String title;
  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.12), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.55,
                ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.emoji,
    required this.label,
    required this.text,
    required this.color,
  });

  final String emoji;
  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
              const SizedBox(height: 2),
              Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: t.textMuted),
          ],
        ),
      ),
    );
  }
}

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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: t.roseGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: t.roseGold.withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text('${task.day}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: t.primaryDark, fontWeight: FontWeight.w300)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(task.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${task.day}. gün sonuç kontrolü'),
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
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((String item) =>
              DropdownMenuItem<String>(value: item, child: Text(item)))
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}
