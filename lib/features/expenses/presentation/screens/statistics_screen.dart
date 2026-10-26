import 'package:expense_tracker/features/expenses/presentation/widgets/category_details.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/donut_chart_card.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/hero_spend_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/period_stats.dart';
import '../providers/expense_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedStatsPeriodProvider);
    final now = DateTime.now();
    final colors = context.colors;
    final typography = context.typography;
    String periodSubtitle = '';
    switch (selectedPeriod) {
      case StatsPeriod.daily:
        periodSubtitle = DateFormatter.formatFullDate(now);
        break;
      case StatsPeriod.weekly:
        periodSubtitle = 'this week';
        break;
      case StatsPeriod.monthly:
        periodSubtitle = DateFormatter.formatMonthYear(now);
        break;
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: typography.headlineMd.copyWith(fontWeight: FontWeight.w700),
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
          const HeroSpendCard(),
          const SizedBox(height: AppDimens.spaceMd),

          // Donut Chart Card
          const DonutChartCard(),
          const SizedBox(height: AppDimens.spaceMd),

          // Category Details Breakdown List
          const CategoryDetails(),
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
