import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_dimens.dart';
import 'package:expense_tracker/core/constants/app_typography.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/expenses/presentation/helpers/pick_date_time.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/add_expense_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DateTimeSelector extends ConsumerWidget {
  const DateTimeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void selectDateTime() => pickDateTime(context, ref);
    final addState = ref.watch(addExpenseNotifierProvider);
    final colors = context.colors;
    final typography = context.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: typography.labelSm.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: selectDateTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.surfaceContainer,
                      ),
                      child: Icon(
                        Icons.edit_calendar_outlined,
                        size: 16,
                        color: colors.ink,
                      ),
                    ),
                    const SizedBox(width: AppDimens.spaceSm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormatter.formatFullDate(addState.date),
                          style: typography.titleSm.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.ink,
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(addState.date),
                          style: typography.labelSm.copyWith(
                            color: colors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.expand_more_rounded,
                  size: 20,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
