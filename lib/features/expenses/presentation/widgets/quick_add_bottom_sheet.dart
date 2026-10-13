import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/expense_category.dart';
import '../providers/add_expense_notifier.dart';
import '../providers/expense_providers.dart';

class QuickAddBottomSheet extends ConsumerStatefulWidget {
  const QuickAddBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickAddBottomSheet(),
    );
  }

  @override
  ConsumerState<QuickAddBottomSheet> createState() =>
      _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends ConsumerState<QuickAddBottomSheet> {
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
          content: const Text('Please enter a valid expense amount.'),
          backgroundColor: colors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final expense = ref.read(addExpenseNotifierProvider.notifier).buildExpense();
    await ref.read(expenseListProvider.notifier).addExpense(expense);

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
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: colors.onPrimary,
                ),
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: EdgeInsets.only(
        left: AppDimens.spaceLg,
        right: AppDimens.spaceLg,
        top: AppDimens.spaceMd,
        bottom: MediaQuery.paddingOf(context).bottom + bottomInset + AppDimens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.spaceMd),

            // Sheet Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Expense',
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
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: colors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.spaceMd),

            // Large Hero Amount Display Card
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.spaceMd,
                horizontal: AppDimens.spaceLg,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              child: Column(
                children: [
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
                  const SizedBox(height: AppDimens.spaceSm),
                  // Quick increment presets (+₹5, +₹10, +₹20, Clear)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QuickIncrementChip(
                        label: '+₹5',
                        onTap: () {
                          notifier.adjustAmount(5);
                          _syncAmountText(
                              ref.read(addExpenseNotifierProvider).rawAmountInput);
                        },
                      ),
                      const SizedBox(width: AppDimens.spaceSm),
                      _QuickIncrementChip(
                        label: '+₹10',
                        onTap: () {
                          notifier.adjustAmount(10);
                          _syncAmountText(
                              ref.read(addExpenseNotifierProvider).rawAmountInput);
                        },
                      ),
                      const SizedBox(width: AppDimens.spaceSm),
                      _QuickIncrementChip(
                        label: '+₹20',
                        onTap: () {
                          notifier.adjustAmount(20);
                          _syncAmountText(
                              ref.read(addExpenseNotifierProvider).rawAmountInput);
                        },
                      ),
                      const SizedBox(width: AppDimens.spaceSm),
                      GestureDetector(
                        onTap: () {
                          notifier.clearAmount();
                          _syncAmountText('');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.backspace_outlined,
                                size: 12,
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
                ],
              ),
            ),
            const SizedBox(height: AppDimens.spaceMd),

            // Category Picker
            Text(
              'Category',
              style: typography.labelMd.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: AppDimens.spaceSm),
            Wrap(
              spacing: AppDimens.spaceSm,
              runSpacing: AppDimens.spaceSm,
              children: ExpenseCategory.all.map((cat) {
                final isSelected = cat.type == addState.category.type;
                return GestureDetector(
                  onTap: () => notifier.selectCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.spaceMd,
                      vertical: AppDimens.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary
                          : colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.icon,
                          size: 16,
                          color: isSelected ? colors.onPrimary : colors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: typography.labelMd.copyWith(
                            color: isSelected ? colors.onPrimary : colors.ink,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimens.spaceMd),

            // Date Selection Row
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.spaceMd,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: colors.ink,
                    ),
                    const SizedBox(width: AppDimens.spaceSm),
                    Expanded(
                      child: Text(
                        DateFormatter.formatFullDate(addState.date),
                        style: typography.titleSm.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
                        ),
                      ),
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
            const SizedBox(height: AppDimens.spaceSm),

            // Note Input
            TextField(
              controller: _noteController,
              style: TextStyle(color: colors.ink),
              onChanged: (val) => notifier.setNote(val),
              maxLength: 60,
              decoration: InputDecoration(
                hintText: 'What was this for? (optional note)',
                hintStyle: typography.bodyMd.copyWith(
                  color: colors.textMuted,
                ),
                filled: true,
                fillColor: colors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.spaceMd,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  borderSide: BorderSide.none,
                ),
                counterStyle: typography.labelSm.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.spaceSm),

            // Save Primary Button
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                elevation: 0,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 20, color: colors.onPrimary),
                  const SizedBox(width: AppDimens.spaceSm),
                  Text(
                    'Save Expense',
                    style: typography.titleSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickIncrementChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickIncrementChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        ),
        child: Text(
          label,
          style: typography.labelSm.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
