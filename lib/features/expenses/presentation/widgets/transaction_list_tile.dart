import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/expense.dart';

class TransactionListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TransactionListTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Dismissible(
      key: Key(expense.id),
      direction: (onDelete != null || onEdit != null)
          ? DismissDirection.horizontal
          : DismissDirection.none,
      // Left→right: Edit (blue)
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppDimens.spaceLg),
        color: Colors.blue.shade600,
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
      // Right→left: Delete (red)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimens.spaceLg),
        color: colors.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Trigger edit and cancel the dismiss so the tile stays in the list
          onEdit?.call();
          return false;
        }
        // endToStart = delete: confirm and let it proceed
        return onDelete != null;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: InkWell(
        onTap: onTap,
        splashColor: colors.primary.withValues(alpha: 0.1),
        highlightColor: colors.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceMd,
            vertical: AppDimens.spaceMd - 2,
          ),
          child: Row(
            children: [
              // Category Icon Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  expense.category.icon,
                  size: 22,
                  color: colors.ink,
                ),
              ),
              const SizedBox(width: AppDimens.spaceMd),

              // Title & Date Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: typography.titleSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormatter.formatDisplayDate(expense.dateTime)} • ${expense.category.label}',
                      style: typography.bodyMd.copyWith(
                        color: colors.textMuted,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.spaceSm),

              // Amount
              Text(
                '-${CurrencyFormatter.format(expense.amount)}',
                style: typography.titleSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
