import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/period_stats.dart';

class CategoryDistributionBar extends StatelessWidget {
  final List<CategoryBreakdown> breakdowns;
  final String? topCategoryName;

  const CategoryDistributionBar({
    super.key,
    required this.breakdowns,
    this.topCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    // Only keep categories that have positive percentages
    final activeBreakdowns =
        breakdowns.where((b) => b.percentage > 0).toList();

    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceMd),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: colors.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.isDark ? 0.3 : 0.02),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Distribution',
                style: typography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.ink,
                ),
              ),
              Text(
                topCategoryName != null ? 'Top: $topCategoryName' : 'All categories',
                style: typography.labelSm.copyWith(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceSm + 2),

          // Linear multi-segment bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: Container(
              height: 10,
              color: colors.surfaceContainer,
              child: activeBreakdowns.isEmpty
                  ? Container(color: colors.surfaceContainer)
                  : Row(
                      children: activeBreakdowns.map((b) {
                        return Expanded(
                          flex: (b.percentage * 10).round().clamp(1, 1000),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            color: b.category.getEffectiveColor(context),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
          const SizedBox(height: AppDimens.spaceSm),

          // Category legend chips
          Wrap(
            spacing: AppDimens.spaceMd,
            runSpacing: AppDimens.spaceXs,
            children: breakdowns.take(4).map((b) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: b.category.getEffectiveColor(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    b.category.label,
                    style: typography.labelSm.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
