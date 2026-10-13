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
    // Only keep categories that have positive percentages
    final activeBreakdowns =
        breakdowns.where((b) => b.percentage > 0).toList();

    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                topCategoryName != null ? 'Top: $topCategoryName' : 'All categories',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textMuted,
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
              color: AppColors.surfaceContainer,
              child: activeBreakdowns.isEmpty
                  ? Container(color: AppColors.surfaceContainer)
                  : Row(
                      children: activeBreakdowns.map((b) {
                        return Expanded(
                          flex: (b.percentage * 10).round().clamp(1, 1000),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            color: b.category.color,
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
                      color: b.category.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    b.category.label,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMuted,
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
