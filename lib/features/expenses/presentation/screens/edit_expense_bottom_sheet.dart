import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import '../providers/expense_providers.dart';
import '../widgets/category_chip_grid.dart';

class EditExpenseBottomSheet extends ConsumerStatefulWidget {
  final Expense expense;

  const EditExpenseBottomSheet({super.key, required this.expense});

  static Future<void> show(BuildContext context, Expense expense) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditExpenseBottomSheet(expense: expense),
    );
  }

  @override
  ConsumerState<EditExpenseBottomSheet> createState() =>
      _EditExpenseBottomSheetState();
}

class _EditExpenseBottomSheetState
    extends ConsumerState<EditExpenseBottomSheet> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late double _amount;
  late String _rawAmount;
  late ExpenseCategory _category;
  late DateTime _date;
  late String _note;

  bool _showEnterAmountHint = false;
  bool _showNoChangesHint = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amount = e.amount;
    _rawAmount = e.amount.toStringAsFixed(2);
    _category = e.category;
    _date = e.dateTime.toLocal();
    _note = e.note ?? '';

    _amountController = TextEditingController(text: _rawAmount);
    _noteController = TextEditingController(text: _note);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    // 1. Amount changed?
    if ((_amount - widget.expense.amount).abs() > 0.001) return true;
    // 2. Category changed?
    if (_category.type != widget.expense.category.type) return true;
    // 3. Date/Time changed?
    if (_date.difference(widget.expense.dateTime).inSeconds.abs() > 0) return true;
    // 4. Note changed?
    final originalNote = widget.expense.note?.trim() ?? '';
    if (_note.trim() != originalNote) return true;
    return false;
  }

  void _syncAmountText(String text) {
    _amountController.text = text;
    _amountController.selection =
        TextSelection.fromPosition(TextPosition(offset: text.length));
  }

  Future<void> _pickDateTime() async {
    final colors = context.colors;
    final typography = context.typography;

    DateTime tempDate = _date;
    TimeOfDay tempTime = TimeOfDay.fromDateTime(_date);

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
                      setState(() {
                        _date = tempDate;
                        _showNoChangesHint = false;
                      });
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

  Future<void> _handleUpdate() async {
    if (_amount <= 0) {
      HapticFeedback.mediumImpact();
      setState(() {
        _showEnterAmountHint = true;
        _showNoChangesHint = false;
      });
      return;
    }

    if (!_hasChanges) {
      HapticFeedback.mediumImpact();
      setState(() {
        _showNoChangesHint = true;
        _showEnterAmountHint = false;
      });
      return;
    }

    setState(() => _isSaving = true);

    final effectiveTitle =
        _note.trim().isNotEmpty ? _note.trim() : _category.fullName;
    final effectiveNote =
        _note.trim().isNotEmpty ? _note.trim() : null;

    final updated = widget.expense.copyWith(
      title: effectiveTitle,
      amount: _amount,
      category: _category,
      dateTime: _date,
      note: effectiveNote,
    );

    await ref.read(expenseListProvider.notifier).updateExpense(updated);

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
                  child: Icon(Icons.edit, size: 15, color: colors.onPrimary),
                ),
                const SizedBox(width: AppDimens.spaceSm),
                Expanded(
                  child: Text(
                    'Updated • ${updated.title} (${CurrencyFormatter.format(updated.amount)})',
                    style: TextStyle(color: colors.ink, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            MediaQuery.paddingOf(context).bottom + bottomInset + AppDimens.spaceMd,
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

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Expense',
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

            // ── Amount Card ──────────────────────────────────────────────
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
                      final maxFieldWidth =
                          math.max(constraints.maxWidth - 46, 80.0);
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
                                  final parsed = double.tryParse(val) ?? 0.0;
                                  setState(() {
                                    _amount = parsed;
                                    _rawAmount = val;
                                    if (_showEnterAmountHint && parsed > 0) {
                                      _showEnterAmountHint = false;
                                    }
                                    _showNoChangesHint = false;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppDimens.spaceMd),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _amount = 0.0;
                        _rawAmount = '';
                        _showNoChangesHint = false;
                      });
                      _syncAmountText('');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.backspace_outlined,
                            size: 13,
                            color: colors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: typography.labelSm.copyWith(
                              color: colors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.spaceLg),

            // ── Category Picker ──────────────────────────────────────────
            CategoryChipGrid(
              selectedCategory: _category,
              onSelect: (cat) => setState(() {
                _category = cat;
                _showNoChangesHint = false;
              }),
            ),
            const SizedBox(height: AppDimens.spaceLg),

            // ── Date/Time + Note Card ────────────────────────────────────
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
                                    DateFormatter.formatFullDate(_date),
                                    style: typography.titleSm.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.ink,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('h:mm a').format(_date),
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
                        '${_note.length}/60',
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
                    onChanged: (val) => setState(() {
                      _note = val;
                      _showNoChangesHint = false;
                    }),
                    maxLength: 60,
                    buildCounter: (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) =>
                        null,
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

            // ── Update Button – dynamic label + polished shadow & warning support ──
            Builder(
              builder: (context) {
                final isAmountWarning = _showEnterAmountHint && _amount <= 0;
                final isNoChangesWarning = _showNoChangesHint && !_hasChanges;
                final isWarning = isAmountWarning || isNoChangesWarning;

                final btnBg =
                    !isWarning ? colors.primary : colors.surfaceContainerHigh;
                final btnFg = !isWarning ? colors.onPrimary : colors.error;
                final shadowColor = !isWarning
                    ? colors.primary.withValues(alpha: 0.35)
                    : Colors.transparent;

                final String buttonText;
                if (isAmountWarning) {
                  buttonText = 'Enter Amount';
                } else if (isNoChangesWarning) {
                  buttonText = 'No Changes Made';
                } else {
                  buttonText = 'Update';
                }

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
                        color: !isWarning
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
                      key: ValueKey('$isWarning-$buttonText'),
                      onPressed: _isSaving ? null : _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnBg,
                        foregroundColor: btnFg,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusLg,
                          ),
                          side: isWarning
                              ? BorderSide(
                                  color: colors.error.withValues(alpha: 0.35),
                                  width: 1.5,
                                )
                              : BorderSide.none,
                        ),
                      ),
                      child: _isSaving
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colors.onPrimary,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isWarning
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_rounded,
                                  size: 20,
                                  color: btnFg,
                                ),
                                const SizedBox(width: AppDimens.spaceSm),
                                Text(
                                  buttonText,
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

// ── Dialog row helper ─────────────────────────────────────────────────────────

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
