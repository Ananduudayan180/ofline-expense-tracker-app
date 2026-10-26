import 'package:expense_tracker/core/constants/app_dimens.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_typography.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/domain/entities/period_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeroSpendCard extends ConsumerWidget {
  const HeroSpendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(periodStatsProvider);
    final periodTitle = switch (stats.period) {
      StatsPeriod.daily => 'Today',
      StatsPeriod.weekly => 'This Week',
      StatsPeriod.monthly => 'This Month',
    };
    final colors = context.colors;
    final typography = context.typography;
    return Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.isDark
                      ? Colors.black.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
                child: _buildTrendContent(context, stats),
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
    );
  }

  Widget _buildTrendContent(BuildContext context, PeriodStats stats) {
    final colors = context.colors;
    final typography = context.typography;

    switch (stats.spendingTrend) {
      case SpendingTrend.newSpending:
        return Text(
          'New Spending',
          style: typography.labelSm.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onPrimary,
          ),
        );
      case SpendingTrend.noChange:
        return Text(
          'No Change',
          style: typography.labelSm.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onPrimary,
          ),
        );
      case SpendingTrend.decrease:
        final label =
            stats.totalAmount == 0.0 && stats.previousPeriodAmount > 0.0
            ? '-100%'
            : '${stats.percentageChangeFromPrevious.abs().toStringAsFixed(1)}%';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.trending_down, size: 14, color: colors.onPrimary),
            const SizedBox(width: 3),
            Text(
              label,
              style: typography.labelSm.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onPrimary,
              ),
            ),
          ],
        );
      case SpendingTrend.increase:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.trending_up, size: 14, color: colors.onPrimary),
            const SizedBox(width: 3),
            Text(
              '${stats.percentageChangeFromPrevious.abs().toStringAsFixed(1)}%',
              style: typography.labelSm.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onPrimary,
              ),
            ),
          ],
        );
    }
  }
}
