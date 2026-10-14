import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();
    final addState = ref.read(addExpenseNotifierProvider);
    _amountController = TextEditingController(text: addState.rawAmountInput);
    _noteController = TextEditingController(text: addState.note);
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

  Future<void> _pickDate() async {
    final addState = ref.read(addExpenseNotifierProvider);
    final colors = context.colors;
    final picked = await showDatePicker(
      context: context,
      initialDate: addState.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
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
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(addExpenseNotifierProvider.notifier).selectDate(picked);
    }
  }

  Future<void> _handleSave() async {
    final state = ref.read(addExpenseNotifierProvider);
    final colors = context.colors;
    if (state.amount <= 0) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an amount greater than 0.'),
          backgroundColor: colors.error,
        ),
      );
      return;
    }

    final expense = ref
        .read(addExpenseNotifierProvider.notifier)
        .buildExpense();
    await ref.read(expenseListProvider.notifier).addExpense(expense);
    ref.read(addExpenseNotifierProvider.notifier).reset();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          backgroundColor: colors.surfaceCard,
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
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
                  Row(
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
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: typography.numericHero.copyWith(
                            color: colors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (val) {
                            notifier.setAmountFromInput(val);
                          },
                        ),
                      ),
                    ],
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

            // Date & Note Group Card
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
                    'Transaction Date',
                    style: typography.labelSm.copyWith(color: colors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDate,
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
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: colors.ink,
                                ),
                              ),
                              const SizedBox(width: AppDimens.spaceSm),
                              Text(
                                DateFormatter.formatFullDate(addState.date),
                                style: typography.titleSm.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.ink,
                                ),
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

            // Save Button
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                elevation: 2,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 22, color: colors.onPrimary),
                  const SizedBox(width: AppDimens.spaceSm),
                  Text(
                    'Save Expense',
                    style: typography.titleSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.spaceSm),
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
