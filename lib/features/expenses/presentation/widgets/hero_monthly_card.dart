import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/period_stats.dart';

class HeroMonthlyCard extends StatelessWidget {
  final double totalAmount;
  final double percentageChange;
  final double previousAmount;
  final SpendingTrend? spendingTrend;

  const HeroMonthlyCard({
    super.key,
    required this.totalAmount,
    this.percentageChange = 0.0,
    this.previousAmount = 0.0,
    this.spendingTrend,
  });

  SpendingTrend get resolvedTrend {
    if (spendingTrend != null) return spendingTrend!;
    if (previousAmount == 0.0 && totalAmount == 0.0) {
      return SpendingTrend.noChange;
    }
    if (previousAmount == 0.0 && totalAmount > 0.0) {
      return SpendingTrend.newSpending;
    }
    if (totalAmount == 0.0 && previousAmount > 0.0) {
      return SpendingTrend.decrease;
    }
    if (percentageChange > 0.0) {
      return SpendingTrend.increase;
    }
    if (percentageChange < 0.0) {
      return SpendingTrend.decrease;
    }
    return SpendingTrend.noChange;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(
              alpha: colors.isDark ? 0.25 : 0.35,
            ),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative tactile circular accents
            Positioned(
              right: -24,
              bottom: -24,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.onPrimary.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 48,
              top: -40,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.onPrimary.withValues(alpha: 0.04),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(AppDimens.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL THIS MONTH',
                        style: typography.labelMd.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.8),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.verified_user_outlined,
                        size: 20,
                        color: colors.onPrimary.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.spaceSm),
                  Text(
                    CurrencyFormatter.format(totalAmount),
                    style: typography.displayHeroMobile.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimens.spaceSm),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.onPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: _buildTrendContent(context),
                      ),
                      const SizedBox(width: AppDimens.spaceSm),
                      Text(
                        'vs. last month (${CurrencyFormatter.format(previousAmount)})',
                        style: typography.labelSm.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendContent(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    switch (resolvedTrend) {
      case SpendingTrend.newSpending:
        return Text(
          'New Spending',
          style: typography.labelSm.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        );
      case SpendingTrend.noChange:
        return Text(
          'No Change',
          style: typography.labelSm.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        );
      case SpendingTrend.decrease:
        final label = totalAmount == 0.0 && previousAmount > 0.0
            ? '-100%'
            : '${percentageChange.abs().toStringAsFixed(1)}%';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_downward_rounded,
              size: 14,
              color: colors.onPrimary,
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: typography.labelSm.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      case SpendingTrend.increase:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_upward_rounded, size: 14, color: colors.onPrimary),
            const SizedBox(width: 2),
            Text(
              '${percentageChange.abs().toStringAsFixed(1)}%',
              style: typography.labelSm.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
    }
  }
}
