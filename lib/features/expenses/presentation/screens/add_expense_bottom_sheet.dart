import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/add_expense_notifier.dart';
import '../providers/expense_providers.dart';
import '../widgets/category_chip_grid.dart';

class AddExpenseBottomSheet extends ConsumerStatefulWidget {
  const AddExpenseBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddExpenseBottomSheet(),
    );
  }

  @override
  ConsumerState<AddExpenseBottomSheet> createState() =>
      _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends ConsumerState<AddExpenseBottomSheet> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  bool _showEnterAmountHint = false;

  @override
  void initState() {
    super.initState();
    final addState = ref.read(addExpenseNotifierProvider);
    _amountController = TextEditingController(text: addState.rawAmountInput);
    _noteController = TextEditingController(text: addState.note);
    // Defer provider mutation to after the widget tree is done building.
    // Modifying a provider synchronously in initState causes a Riverpod error.
    Future.microtask(() {
      if (mounted) {
        ref
            .read(addExpenseNotifierProvider.notifier)
            .selectDate(DateTime.now().toLocal());
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _syncAmountText(String text) {
    _amountController.text = text;
    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  Future<void> _pickDateTime() async {
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
                    _DateTimeRow(
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
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
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
                    _DateTimeRow(
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

  Future<void> _handleSave() async {
    final state = ref.read(addExpenseNotifierProvider);
    if (state.amount <= 0) {
      HapticFeedback.mediumImpact();
      setState(() => _showEnterAmountHint = true);
      return;
    }

    final expense = ref
        .read(addExpenseNotifierProvider.notifier)
        .buildExpense();
    await ref.read(expenseListProvider.notifier).addExpense(expense);
    ref.read(addExpenseNotifierProvider.notifier).reset();

    if (mounted) {
      Navigator.of(context).pop();
      final colors = context.colors;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            backgroundColor: colors.surfaceCard,
            content: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary,
                  ),
                  child: Icon(Icons.check, size: 16, color: colors.onPrimary),
                ),
                const SizedBox(width: AppDimens.spaceSm),
                Expanded(
                  child: Text(
                    'Expense Logged • ${expense.category.label} (${CurrencyFormatter.format(expense.amount)})',
                    style: TextStyle(color: colors.ink, fontSize: 13),
                  ),
                ),
                Text(
                  'Offline ready',
                  style: TextStyle(color: colors.primaryDark, fontSize: 11),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addState = ref.watch(addExpenseNotifierProvider);
    final notifier = ref.read(addExpenseNotifierProvider.notifier);
    final colors = context.colors;
    final typography = context.typography;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      padding: EdgeInsets.only(
        left: AppDimens.margin,
        right: AppDimens.margin,
        top: AppDimens.spaceMd,
        bottom:
            MediaQuery.paddingOf(context).bottom +
            bottomInset +
            AppDimens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.isDark ? 0.4 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.spaceMd),

            // Sheet Header with Title & Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Expense',
                  style: typography.headlineMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceContainerLow,
                    ),
                    child: Icon(Icons.close, size: 18, color: colors.ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.spaceMd),

            // Hero Amount Card
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.spaceLg,
                horizontal: AppDimens.spaceMd,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: colors.borderSubtle, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: colors.isDark ? 0.3 : 0.02,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'EXPENSE TOTAL',
                    style: typography.labelMd.copyWith(
                      color: colors.textMuted,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimens.spaceSm),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Reserve space for the currency symbol + gap (≈ 30 px)
                      // and leave at least 8 px margin on each side.
                      final maxFieldWidth = math.max(
                        constraints.maxWidth - 46,
                        80.0,
                      );
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            CurrencyFormatter.defaultSymbol,
                            style: typography.numericHero.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxFieldWidth,
                              minWidth: 48,
                            ),
                            child: IntrinsicWidth(
                              child: TextField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                // Limit raw character input to prevent extreme lengths
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d{0,9}(\.\d{0,2})?'),
                                  ),
                                ],
                                style: typography.numericHero.copyWith(
                                  color: colors.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0.00',
                                  hintStyle: typography.numericHero.copyWith(
                                    color: colors.textMuted,
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (val) {
                                  notifier.setAmountFromInput(val);
                                  if (_showEnterAmountHint) {
                                    final parsed = double.tryParse(val) ?? 0.0;
                                    if (parsed > 0) {
                                      setState(
                                        () => _showEnterAmountHint = false,
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppDimens.spaceMd),

                  _PresetButton(
                    label: 'Clear',
                    isClear: true,
                    onTap: () {
                      notifier.clearAmount();
                      _syncAmountText('');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.spaceLg),

            // Category Picker Section
            CategoryChipGrid(
              selectedCategory: addState.category,
              onSelect: (cat) => notifier.selectCategory(cat),
            ),
            const SizedBox(height: AppDimens.spaceLg),

            // Date & Time + Note Group Card
            Container(
              padding: const EdgeInsets.all(AppDimens.spaceMd),
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: colors.borderSubtle, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date & Time',
                    style: typography.labelSm.copyWith(color: colors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDateTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
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
                  const SizedBox(height: AppDimens.spaceMd),

                  // Note Input Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Note',
                        style: typography.labelSm.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                      Text(
                        '${addState.note.length}/60',
                        style: typography.labelSm.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteController,
                    style: TextStyle(color: colors.ink),
                    minLines: 1,
                    maxLines: 2,
                    onChanged: (val) => notifier.setNote(val),
                    maxLength: 60,
                    buildCounter: (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null,
                    decoration: InputDecoration(
                      hintText: 'Add a note (optional)',
                      hintStyle: typography.bodyMd.copyWith(
                        color: colors.textMuted,
                      ),
                      filled: true,
                      fillColor: colors.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.spaceLg),

            // Save Button – dynamic label + polished shadow
            Builder(
              builder: (context) {
                final hasAmount = addState.amount > 0 || !_showEnterAmountHint;
                final btnBg = hasAmount
                    ? colors.primary
                    : colors.surfaceContainerHigh;
                final btnFg = hasAmount ? colors.onPrimary : colors.error;
                final shadowColor = hasAmount
                    ? colors.primary.withValues(alpha: 0.35)
                    : Colors.transparent;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 18,
                        spreadRadius: 0,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: hasAmount
                            ? colors.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        blurRadius: 32,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: ElevatedButton(
                      key: ValueKey(hasAmount),
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnBg,
                        foregroundColor: btnFg,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusLg,
                          ),
                          side: hasAmount
                              ? BorderSide.none
                              : BorderSide(
                                  color: colors.error.withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            hasAmount
                                ? Icons.check_rounded
                                : Icons.warning_amber_rounded,
                            size: 20,
                            color: btnFg,
                          ),
                          const SizedBox(width: AppDimens.spaceSm),
                          Text(
                            hasAmount ? 'Save Expense' : 'Enter Amount',
                            style: typography.titleSm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: btnFg,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimens.spaceSm),
          ],
        ),
      ),
    );
  }
}

// ─── Helper widget for the date/time dialog rows ──────────────────────────────

class _DateTimeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppColorPalette colors;
  final AppTypographyScale typography;
  final VoidCallback onTap;

  const _DateTimeRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    required this.typography,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.primaryDark),
            const SizedBox(width: AppDimens.spaceSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: typography.labelSm.copyWith(
                    color: colors.textMuted,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: typography.titleSm.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isClear;

  const _PresetButton({
    required this.label,
    required this.onTap,
    this.isClear = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isClear) ...[
              Icon(Icons.backspace_outlined, size: 13, color: colors.error),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: typography.labelSm.copyWith(
                color: isClear ? colors.error : colors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
