import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/period_stats.dart';
import '../providers/expense_providers.dart';
import '../widgets/donut_chart_widget.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedStatsPeriodProvider);
    final stats = ref.watch(periodStatsProvider);
    final now = DateTime.now();
    final colors = context.colors;
    final typography = context.typography;

    String periodTitle = '';
    String periodSubtitle = '';
    switch (selectedPeriod) {
      case StatsPeriod.daily:
        periodTitle = 'Today';
        periodSubtitle = DateFormatter.formatFullDate(now);
        break;
      case StatsPeriod.weekly:
        periodTitle = 'This Week';
        periodSubtitle = 'Last 7 Days';
        break;
      case StatsPeriod.monthly:
        periodTitle = DateFormatter.formatMonthYear(now);
        periodSubtitle = 'Monthly Period';
        break;
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: typography.headlineMd.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.ink,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.margin,
          vertical: AppDimens.spaceSm,
        ),
        children: [
          // Segmented Time Period Filter
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
            child: Row(
              children: [
                _PeriodTab(
                  label: 'Daily',
                  isSelected: selectedPeriod == StatsPeriod.daily,
                  onTap: () {
                    ref
                        .read(selectedStatsPeriodProvider.notifier)
                        .setPeriod(StatsPeriod.daily);
                  },
                ),
                _PeriodTab(
                  label: 'Weekly',
                  isSelected: selectedPeriod == StatsPeriod.weekly,
                  onTap: () {
                    ref
                        .read(selectedStatsPeriodProvider.notifier)
                        .setPeriod(StatsPeriod.weekly);
                  },
                ),
                _PeriodTab(
                  label: 'Monthly',
                  isSelected: selectedPeriod == StatsPeriod.monthly,
                  onTap: () {
                    ref
                        .read(selectedStatsPeriodProvider.notifier)
                        .setPeriod(StatsPeriod.monthly);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceMd),

          // Hero Spend Card
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceLg),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: colors.onPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          periodTitle.toUpperCase(),
                          style: typography.labelMd.copyWith(
                            color: colors.onPrimary,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.isDark
                            ? Colors.black.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusFull,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            stats.percentageChangeFromPrevious <= 0
                                ? Icons.trending_down
                                : Icons.trending_up,
                            size: 14,
                            color: colors.onPrimary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${stats.percentageChangeFromPrevious.abs().toStringAsFixed(1)}%',
                            style: typography.labelSm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.spaceMd),
                Text(
                  'Total Period Outflow',
                  style: typography.labelSm.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(stats.totalAmount),
                  style: typography.numericHero.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimens.spaceSm),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.onPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${stats.count} tracked expenses',
                      style: typography.bodyMd.copyWith(
                        color: colors.onPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceMd),

          // Donut Chart Card
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceLg),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: colors.borderSubtle, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: colors.isDark ? 0.3 : 0.02,
                  ),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category Distribution',
                      style: typography.titleSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.ink,
                      ),
                    ),
                    Icon(
                      Icons.donut_large_rounded,
                      size: 20,
                      color: colors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.spaceMd),

                // Donut Chart Graphic
                DonutChartWidget(
                  breakdowns: stats.categoryBreakdowns,
                  totalAmount: stats.totalAmount,
                  periodLabel: periodTitle,
                ),
                const SizedBox(height: AppDimens.spaceMd),

                // Quick Insight Badge
                if (stats.topCategory != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary,
                          ),
                          child: Icon(
                            stats.topCategory!.category.icon,
                            size: 18,
                            color: colors.onPrimary,
                          ),
                        ),
                        const SizedBox(width: AppDimens.spaceSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${stats.topCategory!.category.label} is highest category',
                                style: typography.labelMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.ink,
                                ),
                              ),
                              Text(
                                '${stats.topCategory!.percentage.toStringAsFixed(0)}% of total period outgoings',
                                style: typography.labelSm.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceMd),

          // Category Details Breakdown List
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceLg),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: colors.borderSubtle, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category Details',
                      style: typography.titleSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.ink,
                      ),
                    ),
                    Text(
                      '${stats.categoryBreakdowns.length} Categories',
                      style: typography.labelSm.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.spaceMd),
                for (final item in stats.categoryBreakdowns) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: AppDimens.spaceSm),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Dot
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: item.category.getEffectiveColor(context),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Icon tile
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colors.surfaceCard,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item.category.icon,
                            size: 18,
                            color: colors.ink,
                          ),
                        ),
                        const SizedBox(width: AppDimens.spaceSm),
                        // Label & Count
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.category.fullName,
                                style: typography.titleSm.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.ink,
                                ),
                              ),
                              Text(
                                '${item.count} transactions',
                                style: typography.labelSm.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Amount & %
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(item.amount),
                              style: typography.titleSm.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colors.ink,
                              ),
                            ),
                            Text(
                              '${item.percentage.toStringAsFixed(0)}%',
                              style: typography.labelSm.copyWith(
                                color: item.percentage > 0
                                    ? colors.primaryDark
                                    : colors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceMd),

          // Budget Pace on Target Anchor Card
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceMd),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary,
                  ),
                  child: Icon(
                    Icons.verified_outlined,
                    size: 20,
                    color: colors.onPrimary,
                  ),
                ),
                const SizedBox(width: AppDimens.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget Pace on Target',
                        style: typography.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      Text(
                        'You are on track with planned outgoings for $periodSubtitle.',
                        style: typography.bodyMd.copyWith(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: typography.labelMd.copyWith(
              color: isSelected ? colors.onPrimary : colors.textMuted,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
