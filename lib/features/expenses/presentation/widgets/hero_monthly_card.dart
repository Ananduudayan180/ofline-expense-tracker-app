import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

class HeroMonthlyCard extends StatelessWidget {
  final double totalAmount;
  final double percentageChange;
  final double previousAmount;

  const HeroMonthlyCard({
    super.key,
    required this.totalAmount,
    this.percentageChange = -4.2,
    this.previousAmount = 1482.00,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDecrease = percentageChange <= 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: colors.isDark ? 0.25 : 0.35),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDecrease
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              size: 14,
                              color: colors.onPrimary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${percentageChange.abs().toStringAsFixed(1)}%',
                              style: typography.labelSm.copyWith(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
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
}
