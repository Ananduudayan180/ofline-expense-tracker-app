import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/period_stats.dart';

class DonutChartWidget extends StatefulWidget {
  final List<CategoryBreakdown> breakdowns;
  final double totalAmount;
  final String periodLabel;

  const DonutChartWidget({
    super.key,
    required this.breakdowns,
    required this.totalAmount,
    required this.periodLabel,
  });

  @override
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DonutChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalAmount != widget.totalAmount ||
        oldWidget.periodLabel != widget.periodLabel) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(210, 210),
                painter: _DonutChartPainter(
                  breakdowns: widget.breakdowns,
                  animationProgress: _animation.value,
                  trackColor: colors.surfaceContainer,
                  categoryColors: {
                    for (final b in widget.breakdowns)
                      b.category.type: b.category.getEffectiveColor(context),
                  },
                ),
              );
            },
          ),
          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SPENT',
                style: typography.labelSm.copyWith(
                  letterSpacing: 1.0,
                  color: colors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.formatCompact(widget.totalAmount),
                style: typography.headlineMd.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.ink,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.periodLabel,
                style: typography.labelSm.copyWith(
                  color: colors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<CategoryBreakdown> breakdowns;
  final double animationProgress;
  final Color trackColor;
  final Map<dynamic, Color> categoryColors;

  _DonutChartPainter({
    required this.breakdowns,
    required this.animationProgress,
    required this.trackColor,
    required this.categoryColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 18.0;
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Background circle track
    canvas.drawCircle(center, radius, bgPaint);

    final activeItems = breakdowns.where((b) => b.percentage > 0).toList();
    if (activeItems.isEmpty) return;

    double startAngle = -math.pi / 2; // Start from top 12 o'clock

    for (final item in activeItems) {
      final sweepAngle = (item.percentage / 100.0) * (2 * math.pi) * animationProgress;

      if (sweepAngle > 0.01) {
        final paint = Paint()
          ..color = categoryColors[item.category.type] ?? item.category.color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

        final rect = Rect.fromCircle(center: center, radius: radius);
        // Add tiny gap
        const gap = 0.05;
        final actualSweep = math.max(0.01, sweepAngle - gap);

        canvas.drawArc(rect, startAngle + gap / 2, actualSweep, false, paint);
      }
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.breakdowns != breakdowns ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.categoryColors != categoryColors;
  }
}
