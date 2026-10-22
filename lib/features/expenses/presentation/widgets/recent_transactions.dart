import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_dimens.dart';
import 'package:expense_tracker/core/constants/app_typography.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/expense_bottom_sheet.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/transaction_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentTransactions extends ConsumerWidget {
  final List<Expense> expenses;
  final bool showAllTransactions;
  const RecentTransactions({
    super.key,
    required this.expenses,
    required this.showAllTransactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final displayedTransactions = showAllTransactions
        ? expenses
        : expenses.take(4).toList();

    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimens.spaceXl),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: colors.borderSubtle, width: 1),
        ),
        child: Column(
          children: [
            Icon(Icons.wallet_outlined, size: 48, color: colors.textMuted),
            const SizedBox(height: AppDimens.spaceSm),
            Text('No transactions yet', style: typography.titleSm),
            const SizedBox(height: 4),
            Text(
              'Tap + below to add your first expense.',
              style: typography.bodyMd,
            ),
          ],
        ),
      );
    } else {
      return Container(
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
          children: [
            for (int i = 0; i < displayedTransactions.length; i++) ...[
              TransactionListTile(
                expense: displayedTransactions[i],
                onTap: () {
                  ExpenseBottomSheet.show(
                    context,
                    expense: displayedTransactions[i],
                  );
                },
                onEdit: () {
                  ExpenseBottomSheet.show(
                    context,
                    expense: displayedTransactions[i],
                  );
                },
                onDelete: () {
                  ref
                      .read(expenseListProvider.notifier)
                      .deleteExpense(displayedTransactions[i].id);
                },
              ),
              if (i < displayedTransactions.length - 1)
                Divider(
                  height: 1,
                  indent: AppDimens.spaceMd,
                  endIndent: AppDimens.spaceMd,
                  color: colors.surfaceContainerLow,
                ),
            ],
          ],
        ),
      );
    }
  }
}
