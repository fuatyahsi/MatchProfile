import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart' as t;

// ═══════════════════════════════════════════════
//  Açık Tema Backdrop — Subtil sıcak ışık
// ═══════════════════════════════════════════════

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: t.scaffoldBg,
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════
//  Premium Scroll Scaffold
// ═══════════════════════════════════════════════

class PremiumScrollScaffold extends StatelessWidget {
  const PremiumScrollScaffold({
    super.key,
    this.appBar,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 120),
  });

  final PreferredSizeWidget? appBar;
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      appBar: appBar,
      body: AppBackdrop(
        child: SafeArea(
          child: ListView(padding: padding, children: children),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Surface Card — Beyaz kart, hafif gölge
// ═══════════════════════════════════════════════

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.tint,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = tint ?? t.cardWhite;

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

// ═══════════════════════════════════════════════
//  Gradient Card — Hero / CTA kartlar (koyu)
// ═══════════════════════════════════════════════

class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.colors,
  });

  final Widget child;
  final EdgeInsets padding;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? const <Color>[
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

// ═══════════════════════════════════════════════
//  Section Header
// ═══════════════════════════════════════════════

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.kicker,
    this.trailing,
  });

  final String title;
  final String? kicker;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (kicker != null) ...<Widget>[
                Text(
                  kicker!.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.primaryDark,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 6),
              ],
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
        if (trailing case final Widget widget) widget,
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Tag Pill — Minimal etiket
// ═══════════════════════════════════════════════

class TagPill extends StatelessWidget {
  const TagPill({
    super.key,
    required this.text,
    this.background,
    this.foreground,
  });

  final String text;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final Color bg = background ?? t.primaryLight;
    final Color fg = foreground ?? t.primaryDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Dimension Tile
// ═══════════════════════════════════════════════

class SensitiveContextDeck extends StatelessWidget {
  const SensitiveContextDeck({
    super.key,
    required this.memories,
    this.title,
    this.subtitle,
    this.maxItems = 2,
  });

  final List<SensitiveContextMemory> memories;
  final String? title;
  final String? subtitle;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final List<SensitiveContextMemory> visible =
        memories.take(maxItems).toList(growable: false);

    if (visible.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title case final String titleText) ...<Widget>[
          Text(
            titleText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 12),
        ],
        ...visible.map(
          (SensitiveContextMemory memory) => _SensitiveContextMemoryCard(
            memory: memory,
          ),
        ),
        if (memories.length > visible.length) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            '+${memories.length - visible.length} baglam daha sonraki yorumlarda aktif kalacak.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.roseGold,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }
}

class _SensitiveContextMemoryCard extends StatelessWidget {
  const _SensitiveContextMemoryCard({required this.memory});

  final SensitiveContextMemory memory;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            t.primarySoft,
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.roseGold.withValues(alpha: 0.16)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: t.roseGold.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: t.roseGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: t.roseGold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      memory.summary,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: t.textPrimary,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                    ),
                    if (memory.tags.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: memory.tags
                            .take(3)
                            .map(
                              (String tag) => TagPill(
                                text: tag,
                                background:
                                    t.primaryYellow.withValues(alpha: 0.14),
                                foreground: t.roseGold,
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.borderLight.withValues(alpha: 0.8)),
            ),
            child: Text(
              memory.acknowledgementLine,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Bu baglam yorumu nasil degistiriyor?',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: t.roseGold,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            memory.impact,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textPrimary.withValues(alpha: 0.8),
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class DimensionTile extends StatelessWidget {
  const DimensionTile({super.key, required this.dimension});

  final ClarityDimension dimension;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (dimension.state) {
      DimensionState.supported => t.successGreen,
      DimensionState.mixed => t.warningAmber,
      DimensionState.unclear => t.textMuted,
      DimensionState.caution => t.cautionRed,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TagPill(
            text: dimension.state.label,
            background: color.withValues(alpha: 0.1),
            foreground: color,
          ),
          const SizedBox(height: 10),
          Text(
            dimension.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              dimension.note,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Hero Stat
// ═══════════════════════════════════════════════

class HeroStat extends StatelessWidget {
  const HeroStat({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: t.primaryYellow, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textOnDark.withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Signal Badge
// ═══════════════════════════════════════════════

class SignalBadge extends StatelessWidget {
  const SignalBadge({super.key, required this.signal});

  final InsightSignal signal;

  @override
  Widget build(BuildContext context) {
    final bool isCaution = signal.signalType == 'safety' ||
        signal.signalType == 'idealization' ||
        signal.signalType == 'attachment_speed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCaution
            ? t.cautionRed.withValues(alpha: 0.06)
            : t.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCaution
              ? t.cautionRed.withValues(alpha: 0.15)
              : t.borderLight,
        ),
        boxShadow: isCaution ? null : <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  signal.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isCaution ? t.cautionRed : t.textPrimary,
                  ),
                ),
              ),
              TagPill(
                text: signal.confidenceLabel.label,
                background: isCaution
                    ? t.cautionRed.withValues(alpha: 0.1)
                    : null,
                foreground: isCaution ? t.cautionRed : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(signal.explanation),
          const SizedBox(height: 12),
          Text(
            signal.evidenceItems.first.text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Inconsistency Warning Card
// ═══════════════════════════════════════════════

class InconsistencyCard extends StatelessWidget {
  const InconsistencyCard({
    super.key,
    required this.title,
    required this.explanation,
    this.severity,
  });

  final String title;
  final String explanation;
  final InconsistencySeverity? severity;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = switch (severity) {
      InconsistencySeverity.significant => t.cautionRed,
      InconsistencySeverity.moderate => t.warningAmber,
      InconsistencySeverity.mild => t.textMuted,
      null => t.warningAmber,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.warning_amber_rounded,
                size: 18, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: accentColor,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  explanation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                      ),
                ),
                if (severity != null) ...<Widget>[
                  const SizedBox(height: 8),
                  TagPill(
                    text: severity!.label,
                    background: accentColor.withValues(alpha: 0.1),
                    foreground: accentColor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Profile Score Bar
// ═══════════════════════════════════════════════

class ProfileScoreBar extends StatelessWidget {
  const ProfileScoreBar({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.subtitle,
  });

  final String label;
  final double value;
  final Color? color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final Color barColor = color ?? t.primaryYellow;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: t.textPrimary,
                      ),
                ),
              ),
              Text(
                (value * 100).toStringAsFixed(0),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: barColor == t.primaryYellow ? t.primaryTextAccent : barColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: t.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Radial Score Widget
// ═══════════════════════════════════════════════

class RadialScoreGauge extends StatelessWidget {
  const RadialScoreGauge({
    super.key,
    required this.label,
    required this.value,
    this.size = 100,
    this.color,
    this.subtitle,
  });

  final String label;
  final double value;
  final double size;
  final Color? color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final Color ringColor = color ?? t.primaryYellow;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RadialGaugePainter(
              value: value.clamp(0.0, 1.0),
              color: ringColor,
              trackColor: t.borderLight,
            ),
            child: Center(
              child: Text(
                (value * 100).toStringAsFixed(0),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ringColor == t.primaryYellow ? t.primaryTextAccent : ringColor,
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.22,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: t.textSecondary,
          ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}

class _RadialGaugePainter extends CustomPainter {
  const _RadialGaugePainter({
    required this.value,
    required this.color,
    required this.trackColor,
  });

  final double value;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 5;
    final Rect rect = Offset.zero & size;
    final Rect deflated = rect.deflate(strokeWidth / 2);

    // Track
    canvas.drawArc(
      deflated,
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Value arc
    canvas.drawArc(
      deflated,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RadialGaugePainter oldDelegate) =>
      value != oldDelegate.value || color != oldDelegate.color;
}

// ═══════════════════════════════════════════════
//  Mini Bar Chart
// ═══════════════════════════════════════════════

class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.maxValue = 7.0,
    this.barColor,
    this.height = 120,
  });

  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final Color? barColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Color color = barColor ?? t.primaryYellow;
    return SizedBox(
      height: height + 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List<Widget>.generate(values.length, (int i) {
          final double ratio = (values[i] / maxValue).clamp(0.0, 1.0);
          final double barHeight = math.max(height * ratio, 8);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    values[i].toStringAsFixed(0),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15 + ratio * 0.55),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 42,
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                            height: 1.2,
                            color: t.textMuted,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Profile Radar Chart
// ═══════════════════════════════════════════════

class ProfileRadarChart extends StatelessWidget {
  const ProfileRadarChart({
    super.key,
    required this.labels,
    required this.values,
    this.size = 200,
  });

  final List<String> labels;
  final List<double> values;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarPainter(
          labels: labels,
          values: values,
          accentColor: t.primaryYellow,
          gridColor: t.borderLight,
          labelColor: t.textSecondary,
          textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 9,
            color: t.textMuted,
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({
    required this.labels,
    required this.values,
    required this.accentColor,
    required this.gridColor,
    required this.labelColor,
    this.textStyle,
  });

  final List<String> labels;
  final List<double> values;
  final Color accentColor;
  final Color gridColor;
  final Color labelColor;
  final TextStyle? textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final int n = values.length;
    if (n < 3) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 28;
    final double step = 2 * math.pi / n;

    // Grid rings
    for (int ring = 1; ring <= 3; ring++) {
      final double r = radius * ring / 3;
      final Path gridPath = Path();
      for (int i = 0; i <= n; i++) {
        final double angle = -math.pi / 2 + step * (i % n);
        final Offset pt = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          gridPath.moveTo(pt.dx, pt.dy);
        } else {
          gridPath.lineTo(pt.dx, pt.dy);
        }
      }
      gridPath.close();
      canvas.drawPath(
        gridPath,
        Paint()
          ..color = gridColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    // Axes
    for (int i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + step * i;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        Paint()
          ..color = gridColor.withValues(alpha: 0.5)
          ..strokeWidth = 0.5,
      );
    }

    // Value polygon
    final Path valuePath = Path();
    for (int i = 0; i <= n; i++) {
      final double angle = -math.pi / 2 + step * (i % n);
      final double v = values[i % n].clamp(0.0, 1.0);
      final Offset pt = Offset(
        center.dx + radius * v * math.cos(angle),
        center.dy + radius * v * math.sin(angle),
      );
      if (i == 0) {
        valuePath.moveTo(pt.dx, pt.dy);
      } else {
        valuePath.lineTo(pt.dx, pt.dy);
      }
    }
    valuePath.close();

    // Fill
    canvas.drawPath(
      valuePath,
      Paint()
        ..color = accentColor.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );
    // Stroke
    canvas.drawPath(
      valuePath,
      Paint()
        ..color = accentColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Dots + labels
    for (int i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + step * i;
      final double v = values[i].clamp(0.0, 1.0);
      final Offset dataPt = Offset(
        center.dx + radius * v * math.cos(angle),
        center.dy + radius * v * math.sin(angle),
      );
      canvas.drawCircle(dataPt, 3, Paint()..color = accentColor);

      // Label
      final Offset labelPt = Offset(
        center.dx + (radius + 18) * math.cos(angle),
        center.dy + (radius + 18) * math.sin(angle),
      );
      final TextPainter tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 60);
      tp.paint(
        canvas,
        Offset(labelPt.dx - tp.width / 2, labelPt.dy - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════
//  Premium Chip Group
// ═══════════════════════════════════════════════

class PremiumChipGroup extends StatelessWidget {
  const PremiumChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.multiSelect = false,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onChanged;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((String option) {
        final bool isSelected = selected.contains(option);
        return GestureDetector(
          onTap: () => onChanged(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? t.primaryYellow.withValues(alpha: 0.15)
                  : t.cardWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? t.primaryYellow
                    : t.borderLight,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              option,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? t.primaryDark : t.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

// ═══════════════════════════════════════════════
//  Premium Text Field
// ═══════════════════════════════════════════════

class PremiumTextField extends StatelessWidget {
  const PremiumTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.minLines = 1,
    this.maxLines = 1,
    this.onChanged,
    this.keyName,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final String? keyName;

  @override
  Widget build(BuildContext context) {
    final bool isMultiline = minLines > 1 || maxLines > 1;
    final int effectiveMinLines = isMultiline ? math.max(minLines, 4) : 1;
    final int effectiveMaxLines =
        isMultiline ? math.max(maxLines, effectiveMinLines + 2) : 1;

    return TextField(
      key: keyName != null ? Key(keyName!) : null,
      controller: controller,
      minLines: effectiveMinLines,
      maxLines: effectiveMaxLines,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textAlignVertical: TextAlignVertical.top,
      textCapitalization: TextCapitalization.sentences,
      scrollPadding: const EdgeInsets.only(bottom: 220),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: t.textPrimary,
            fontSize: isMultiline ? 15 : 14.5,
            height: 1.5,
          ),
      cursorColor: t.primaryYellow,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: t.surfaceElevated,
        labelStyle: TextStyle(
          color: t.primaryDark.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: t.textMuted.withValues(alpha: 0.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: t.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: t.primaryYellow, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMultiline ? 16 : 14,
        ),
      ),
    );
  }
}

class NarrativePromptCard extends StatelessWidget {
  const NarrativePromptCard({
    super.key,
    required this.controller,
    required this.question,
    this.helper,
    this.hint,
    this.minLines = 3,
    this.maxLines = 6,
    this.keyName,
    this.kicker = 'AÇIK UÇLU',
    this.onChanged,
  });

  final TextEditingController controller;
  final String question;
  final String? helper;
  final String? hint;
  final int minLines;
  final int maxLines;
  final String? keyName;
  final String kicker;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            kicker,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.primaryDark,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (helper != null && helper!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              helper!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textMuted,
                    height: 1.4,
                  ),
            ),
          ],
          const SizedBox(height: 14),
          PremiumTextField(
            controller: controller,
            label: 'Cevab\u0131n',
            hint: hint,
            minLines: minLines,
            maxLines: maxLines,
            onChanged: onChanged,
            keyName: keyName,
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (
              BuildContext context,
              TextEditingValue value,
              Widget? child,
            ) {
              final int charCount = value.text.trim().length;
              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$charCount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textMuted.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Segmented Score Band
// ═══════════════════════════════════════════════

class SegmentedScoreBand extends StatelessWidget {
  const SegmentedScoreBand({
    super.key,
    required this.label,
    required this.value,
    required this.leadingCaption,
    required this.centerCaption,
    required this.trailingCaption,
    required this.color,
  });

  final String label;
  final double value;
  final String leadingCaption;
  final String centerCaption;
  final String trailingCaption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double clamped = value.clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '${(clamped * 100).round()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color == t.primaryYellow ? t.primaryTextAccent : color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final double left =
                (width * clamped).clamp(6.0, width - 6.0).toDouble();

            return SizedBox(
              height: 18,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: t.cautionRed.withValues(alpha: 0.15),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Container(
                          height: 4,
                          color: t.warningAmber.withValues(alpha: 0.15),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: t.successGreen.withValues(alpha: 0.15),
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: left - 6,
                    top: -4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                leadingCaption,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: t.textMuted,
                ),
              ),
            ),
            Expanded(
              child: Text(
                centerCaption,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: t.textMuted,
                ),
              ),
            ),
            Expanded(
              child: Text(
                trailingCaption,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: t.textMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ScoreHeatTile extends StatelessWidget {
  const ScoreHeatTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.lowCaption,
    required this.midCaption,
    required this.highCaption,
  });

  final String label;
  final double value;
  final Color color;
  final String lowCaption;
  final String midCaption;
  final String highCaption;

  @override
  Widget build(BuildContext context) {
    final double clamped = value.clamp(0.0, 1.0).toDouble();
    final String interpretation = clamped < 0.34
        ? lowCaption
        : clamped < 0.67
            ? midCaption
            : highCaption;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${(clamped * 100).round()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color == t.primaryYellow ? t.primaryTextAccent : color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: t.borderLight,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            interpretation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Feature Gradient Card — Kaydırılabilir kart
// ═══════════════════════════════════════════════

class FeatureGradientCard extends StatefulWidget {
  const FeatureGradientCard({
    super.key,
    required this.kicker,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.onOpen,
    this.swipeHint = 'Düzenlemek için sa\u011fa kayd\u0131r',
  });

  final String kicker;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onOpen;
  final String swipeHint;

  @override
  State<FeatureGradientCard> createState() => _FeatureGradientCardState();
}

class _FeatureGradientCardState extends State<FeatureGradientCard>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() => _dragOffset = (_dragOffset + d.delta.dx).clamp(0.0, 120.0));
  }

  void _onDragEnd(DragEndDetails d) {
    if (_dragOffset > 60 || d.velocity.pixelsPerSecond.dx > 300) {
      widget.onOpen();
    }
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: widget.onOpen,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: AnimatedContainer(
          duration: _dragOffset == 0
              ? const Duration(milliseconds: 350)
              : Duration.zero,
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(_dragOffset * 0.3, 0, 0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: widget.gradientColors.first.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          widget.kicker,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Icon(
                        widget.icon,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: _shimmerCtrl,
                        builder: (BuildContext context, Widget? _) {
                          return Transform.translate(
                            offset: Offset(
                              4 * math.sin(_shimmerCtrl.value * 2 * math.pi),
                              0,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white.withValues(
                                  alpha: 0.3 + 0.2 * math.sin(
                                      _shimmerCtrl.value * 2 * math.pi)),
                              size: 16,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.swipeHint,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Section Gradient Presets — Canlı açık tema
// ═══════════════════════════════════════════════

class SectionGradients {
  SectionGradients._();

  static const List<Color> selfIntro = <Color>[
    Color(0xFFF5C518), Color(0xFFFFD54F), Color(0xFFFFF176),
  ];
  static const List<Color> relationship = <Color>[
    Color(0xFF0891B2), Color(0xFF06B6D4), Color(0xFF22D3EE),
  ];
  static const List<Color> values = <Color>[
    Color(0xFF6366F1), Color(0xFF818CF8), Color(0xFFA5B4FC),
  ];
  static const List<Color> communication = <Color>[
    Color(0xFFEC4899), Color(0xFFF472B6), Color(0xFFFBAED2),
  ];
  static const List<Color> blindSpots = <Color>[
    Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFFFDE68A),
  ];
  static const List<Color> beliefs = <Color>[
    Color(0xFF8B5CF6), Color(0xFFA78BFA), Color(0xFFC4B5FD),
  ];
  static const List<Color> safety = <Color>[
    Color(0xFFEF4444), Color(0xFFF87171), Color(0xFFFCA5A5),
  ];
  static const List<Color> openField = <Color>[
    Color(0xFF22C55E), Color(0xFF4ADE80), Color(0xFF86EFAC),
  ];
}
