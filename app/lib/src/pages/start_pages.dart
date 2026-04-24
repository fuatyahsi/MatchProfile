import 'package:flutter/material.dart';

import '../theme.dart' as t;

// ═══════════════════════════════════════════════
//  Welcome Page — Koyu Editöryal Tasarım
// ═══════════════════════════════════════════════

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: <Widget>[
            // ── Üst bar: logo + beta etiketi ──
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: t.primaryYellow.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: t.primaryYellow,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'MatchProfile',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: t.primaryYellow.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: t.primaryYellow.withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'BETA',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.primaryYellow.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // ── Ana başlık bloğu ──
            Text(
              'Romantik karar\nzekası.',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w200,
                height: 1.1,
                letterSpacing: -1.0,
                color: t.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 40,
              height: 1,
              color: t.primaryYellow.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'MatchProfile seni ölçmez, tanır. Romantik karar profilini çıkarır, tutarsızlıklarını gösterir, her içgörüyü sana göre kişiselleştirir.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: t.textSecondary,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 32),

            // ── CTA butonu ──
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('welcome_start_button'),
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: t.primaryYellow,
                  foregroundColor: t.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Profilimi oluştur',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Sohbet · yaklaşık 5 dakika',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: t.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ── Ayırıcı çizgi ──
            Container(
              height: 0.5,
              color: t.borderLight.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 32),

            // ── Özellik listesi ──
            Text(
              'NASIL ÇALIŞIR',
              style: theme.textTheme.bodySmall?.copyWith(
                color: t.primaryYellow.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _WelcomeFeature(
              icon: Icons.chat_outlined,
              title: 'Sohbetle profil oluştur',
              description:
                  'Form doldurmak yok. Sırdaşınla sohbet ederek romantik karar profilini oluşturursun.',
            ),
            const SizedBox(height: 20),
            _WelcomeFeature(
              icon: Icons.psychology_outlined,
              title: 'Derin analiz',
              description:
                  'Sohbetten 8 boyutlu profil çıkarılır: değerler, kör noktalar, iletişim stili, sınırlar.',
            ),
            const SizedBox(height: 20),
            _WelcomeFeature(
              icon: Icons.tune_outlined,
              title: 'Kişiselleştirilmiş içgörü',
              description:
                  'Her yansıtma yorumu ve doğrulama sorusu sana özel tonlanır.',
            ),
            const SizedBox(height: 32),

            // ── Alt not ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.cardWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: t.borderLight.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.shield_outlined,
                    color: t.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Veriler yalnızca cihazında saklanır. Hiçbir şey dışarıya aktarılmaz.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: t.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeFeature extends StatelessWidget {
  const _WelcomeFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: t.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: t.borderLight.withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
          child: Icon(icon, size: 17, color: t.primaryYellow.withValues(alpha: 0.8)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
