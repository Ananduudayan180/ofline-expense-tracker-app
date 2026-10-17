import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_dimens.dart';
import 'package:expense_tracker/core/constants/app_typography.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryDetails extends ConsumerWidget {
  const CategoryDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final stats = ref.watch(periodStatsProvider);
    return Container(
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
                style: typography.labelSm.copyWith(color: colors.textMuted),
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
    );
  }
}
