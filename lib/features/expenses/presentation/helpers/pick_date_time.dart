import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_dimens.dart';
import 'package:expense_tracker/core/constants/app_typography.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/add_expense_notifier.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/add_expense_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

Future<void> pickDateTime(BuildContext context, WidgetRef ref) async {
  final addState = ref.read(addExpenseNotifierProvider);
  final colors = context.colors;
  final typography = context.typography;

  DateTime tempDate = addState.date;
  TimeOfDay tempTime = TimeOfDay.fromDateTime(addState.date);

  final ThemeData dialogTheme = Theme.of(context).copyWith(
    colorScheme: ColorScheme(
      brightness: colors.isDark ? Brightness.dark : Brightness.light,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      surface: colors.surfaceCard,
      onSurface: colors.ink,
      error: colors.error,
      onError: Colors.white,
      secondary: colors.ink,
      onSecondary: colors.background,
    ),
  );

  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Theme(
            data: dialogTheme,
            child: AlertDialog(
              backgroundColor: colors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.withValues(alpha: 0.18),
                    ),
                    child: Icon(
                      Icons.edit_calendar_outlined,
                      size: 16,
                      color: colors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: AppDimens.spaceSm),
                  Text(
                    'Date & Time',
                    style: typography.titleSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DateTimeRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: DateFormat('EEE, MMM d, yyyy').format(tempDate),
                    colors: colors,
                    typography: typography,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: tempDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tempDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            tempTime.hour,
                            tempTime.minute,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppDimens.spaceSm),
                  DateTimeRow(
                    icon: Icons.access_time_rounded,
                    label: 'Time',
                    value: tempTime.format(ctx),
                    colors: colors,
                    typography: typography,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: tempTime,
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tempTime = picked;
                          tempDate = DateTime(
                            tempDate.year,
                            tempDate.month,
                            tempDate.day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colors.textMuted),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                  ),
                  onPressed: () {
                    ref
                        .read(addExpenseNotifierProvider.notifier)
                        .selectDateTime(tempDate);
                    Navigator.of(dialogCtx).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
