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

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
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
    final picked = await showDatePicker(
      context: context,
      initialDate: addState.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.ink,
              onPrimary: Colors.white,
              surface: AppColors.surfaceCard,
              onSurface: AppColors.ink,
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
    if (state.amount <= 0) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount greater than 0.'),
          backgroundColor: AppColors.error,
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
          backgroundColor: AppColors.ink,
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: AppDimens.spaceSm),
              Expanded(
                child: Text(
                  'Expense Logged • ${expense.category.label} (${CurrencyFormatter.format(expense.amount)})',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const Text(
                'Offline ready',
                style: TextStyle(color: AppColors.primaryDim, fontSize: 11),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add Expense',
          style: AppTypography.headlineMd.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Amount Card
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.spaceLg,
                  horizontal: AppDimens.spaceMd,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(color: AppColors.borderSubtle, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'EXPENSE TOTAL',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.textMuted,
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
                          style: AppTypography.numericHero.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: AppTypography.numericHero.copyWith(
                              color: AppColors.ink,
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
                    // Quick Increment Presets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PresetButton(
                          label: '+₹5',
                          onTap: () {
                            notifier.adjustAmount(5);
                            _syncAmountText(
                              ref.read(addExpenseNotifierProvider).rawAmountInput,
                            );
                          },
                        ),
                        const SizedBox(width: AppDimens.spaceSm),
                        _PresetButton(
                          label: '+₹10',
                          onTap: () {
                            notifier.adjustAmount(10);
                            _syncAmountText(
                              ref.read(addExpenseNotifierProvider).rawAmountInput,
                            );
                          },
                        ),
                        const SizedBox(width: AppDimens.spaceSm),
                        _PresetButton(
                          label: '+₹20',
                          onTap: () {
                            notifier.adjustAmount(20);
                            _syncAmountText(
                              ref.read(addExpenseNotifierProvider).rawAmountInput,
                            );
                          },
                        ),
                        const SizedBox(width: AppDimens.spaceSm),
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
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(color: AppColors.borderSubtle, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Date',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.textMuted,
                      ),
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
                          color: AppColors.surfaceContainerLow,
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
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.surfaceContainer,
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(width: AppDimens.spaceSm),
                                Text(
                                  DateFormatter.formatFullDate(addState.date),
                                  style: AppTypography.titleSm.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.expand_more_rounded,
                              size: 20,
                              color: AppColors.textMuted,
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
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '${addState.note.length}/60',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _noteController,
                      onChanged: (val) => notifier.setNote(val),
                      maxLength: 60,
                      buildCounter: (context,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null,
                      decoration: InputDecoration(
                        hintText: 'Add a note (optional)',
                        hintStyle: AppTypography.bodyMd.copyWith(
                          color: AppColors.textMuted,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.ink,
                  elevation: 2,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check, size: 22, color: AppColors.ink),
                    const SizedBox(width: AppDimens.spaceSm),
                    Text(
                      'Save Expense',
                      style: AppTypography.titleSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.spaceMd),
            ],
          ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isClear) ...[
              const Icon(
                Icons.backspace_outlined,
                size: 13,
                color: AppColors.error,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: isClear ? AppColors.error : AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
