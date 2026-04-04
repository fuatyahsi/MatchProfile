import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart' as t;

// ═══════════════════════════════════════════════
//  Dark Luxe Backdrop — Animated glow orbs
// ═══════════════════════════════════════════════

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: t.noir,
      child: Stack(
        children: <Widget>[
          // Subtle warm glow top-right
          Positioned(
            top: -100,
            right: -60,
            child: _GlowOrb(
              size: 280,
              colors: const <Color>[Color(0x1AD4A08A), Color(0x00D4A08A)],
            ),
          ),
          // Deep rose glow mid-left
          Positioned(
            top: 280,
            left: -100,
            child: _GlowOrb(
              size: 320,
              colors: const <Color>[Color(0x10CF8E8E), Color(0x00CF8E8E)],
            ),
          ),
          // Gold glow bottom
          Positioned(
            bottom: -60,
            right: 40,
            child: _GlowOrb(
              size: 200,
              colors: const <Color>[Color(0x12D4B896), Color(0x00D4B896)],
            ),
          ),
          child,
        ],
      ),
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
    this.padding = const EdgeInsets.fromLTRB(18, 12, 18, 120),
  });

  final PreferredSizeWidget? appBar;
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: t.noir,
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
//  Glassmorphic Surface Card — Dark Premium
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
    final Color baseColor = tint ?? t.charcoal.withValues(alpha: 0.75);
    final bool isAccented = tint != null && tint != t.charcoal;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isAccented
                  ? t.roseGold.withValues(alpha: 0.15)
                  : t.smoky.withValues(alpha: 0.4),
              width: 0.8,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
              if (isAccented)
                BoxShadow(
                  color: t.roseGold.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Premium Gradient Card — Hero / CTA cards
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors ?? const <Color>[
                Color(0xFF2A1F24), // dark rose base
                Color(0xFF1F1A1C), // noir edge
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: t.roseGold.withValues(alpha: 0.12),
              width: 0.8,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 48,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: t.roseGold.withValues(alpha: 0.04),
                blurRadius: 20,
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Section Header — Dark theme
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
                        color: t.roseGold,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 10.5,
                      ),
                ),
                const SizedBox(height: 5),
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
//  Tag Pill — Premium dark chip
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
    final Color bg = background ?? t.roseGold.withValues(alpha: 0.1);
    final Color fg = foreground ?? t.roseGold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: fg.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Dimension Tile — Dark Premium
// ═══════════════════════════════════════════════

class DimensionTile extends StatelessWidget {
  const DimensionTile({super.key, required this.dimension});

  final ClarityDimension dimension;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (dimension.state) {
      DimensionState.supported => t.softGreen,
      DimensionState.mixed => t.amber,
      DimensionState.unclear => t.mutedText,
      DimensionState.caution => t.roseCaution,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.charcoal.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TagPill(
            text: dimension.state.label,
            background: color.withValues(alpha: 0.12),
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
              ?.copyWith(color: t.roseGold, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.softText,
              ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Signal Badge — Dark themed
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isCaution
            ? t.roseCaution.withValues(alpha: 0.08)
            : t.charcoal.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCaution
              ? t.roseCaution.withValues(alpha: 0.2)
              : t.smoky.withValues(alpha: 0.4),
        ),
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
                    color: isCaution ? t.roseCaution : t.ivoryText,
                  ),
                ),
              ),
              TagPill(
                text: signal.confidenceLabel.label,
                background: isCaution
                    ? t.roseCaution.withValues(alpha: 0.12)
                    : null,
                foreground: isCaution ? t.roseCaution : null,
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
//  Inconsistency Warning Card — Dark Premium
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
      InconsistencySeverity.significant => t.roseCaution,
      InconsistencySeverity.moderate => t.amber,
      InconsistencySeverity.mild => t.softText,
      null => t.amber,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.warning_amber_rounded,
                size: 20, color: accentColor),
          ),
          const SizedBox(width: 14),
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
                        color: t.ivoryText.withValues(alpha: 0.75),
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
//  Animated Profile Score Bar — with glow
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
  final double value; // 0.0 – 1.0
  final Color? color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final Color barColor = color ?? t.roseGold;
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
                    color: t.ivoryText,
                  ),
                ),
              ),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: barColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 7,
            decoration: BoxDecoration(
              color: t.graphite,
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      barColor.withValues(alpha: 0.6),
                      barColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: barColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.mutedText,
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
//  Radial Score Widget — Circular gauge chart
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
    final Color ringColor = color ?? t.roseGold;
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
              trackColor: t.graphite,
            ),
            child: Center(
              child: Text(
                '${(value * 100).toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ringColor,
                  fontWeight: FontWeight.w800,
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
            color: t.ivoryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.mutedText,
              fontSize: 10.5,
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
    final double strokeWidth = 8;
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
    final Paint arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi * value,
        colors: <Color>[
          color.withValues(alpha: 0.4),
          color,
        ],
      ).createShader(deflated);

    canvas.drawArc(
      deflated,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      arcPaint,
    );

    // Glow dot at end
    final double angle = -math.pi / 2 + 2 * math.pi * value;
    final Offset dotCenter = Offset(
      deflated.center.dx + deflated.width / 2 * math.cos(angle),
      deflated.center.dy + deflated.height / 2 * math.sin(angle),
    );
    canvas.drawCircle(
      dotCenter,
      4,
      Paint()..color = color,
    );
    canvas.drawCircle(
      dotCenter,
      8,
      Paint()..color = color.withValues(alpha: 0.15),
    );
  }

  @override
  bool shouldRepaint(_RadialGaugePainter oldDelegate) =>
      value != oldDelegate.value || color != oldDelegate.color;
}

// ═══════════════════════════════════════════════
//  Mini Bar Chart — for belief scales
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
    final Color color = barColor ?? t.roseGold;
    return SizedBox(
      height: height + 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List<Widget>.generate(values.length, (int i) {
          final double ratio = (values[i] / maxValue).clamp(0.0, 1.0);
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
                    height: height * ratio,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          color.withValues(alpha: 0.3),
                          color.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 8.5,
                      color: t.mutedText,
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
//  Profile Radar Summary — Spider/radar visual
// ═══════════════════════════════════════════════

class ProfileRadarChart extends StatelessWidget {
  const ProfileRadarChart({
    super.key,
    required this.labels,
    required this.values,
    this.size = 200,
  });

  final List<String> labels;
  final List<double> values; // 0.0 – 1.0
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
          accentColor: t.roseGold,
          gridColor: t.smoky,
          labelColor: t.softText,
          textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 9,
            color: t.softText,
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
          ..color = gridColor.withValues(alpha: 0.3)
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
          ..color = gridColor.withValues(alpha: 0.2)
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
      canvas.drawCircle(dataPt, 3.5, Paint()..color = accentColor);
      canvas.drawCircle(
        dataPt, 6, Paint()..color = accentColor.withValues(alpha: 0.15));

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
//  Premium Selection Chip Group
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
      runSpacing: 10,
      children: options.map((String option) {
        final bool isSelected = selected.contains(option);
        return GestureDetector(
          onTap: () => onChanged(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? t.roseGold.withValues(alpha: 0.15)
                  : t.graphite.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? t.roseGold.withValues(alpha: 0.5)
                    : t.smoky.withValues(alpha: 0.5),
                width: isSelected ? 1.2 : 0.8,
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
            child: Text(
              option,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? t.roseGold : t.softText,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
    return TextField(
      key: keyName != null ? Key(keyName!) : null,
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(color: t.ivoryText),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: t.graphite.withValues(alpha: 0.6),
        labelStyle: TextStyle(
          color: t.roseGold.withValues(alpha: 0.8),
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: t.mutedText.withValues(alpha: 0.6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: t.smoky.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: t.roseGold, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Glow Orb (internal)
// ═══════════════════════════════════════════════

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
