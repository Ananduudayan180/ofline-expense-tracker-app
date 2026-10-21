import 'package:expense_tracker/features/expenses/presentation/widgets/bottom_sheet_hero_amount_card.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/date_time_selector.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/note_input_field.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/save_and_update_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
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
            BottomSheetHeroAmountCard(
              amountController: _amountController,
              setAmountFromInput: notifier.setAmountFromInput,
              clearAmount: notifier.clearAmount,
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
                  //Date & Time Selector
                  DateTimeSelector(),
                  const SizedBox(height: AppDimens.spaceMd),

                  // Note Input Field
                  NoteInputField(noteController: _noteController),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.spaceLg),

            // Save Button – dynamic label + polished shadow
            SaveAndUpdateButton(
              handleSave: _handleSave,
              showEnterAmountHint: _showEnterAmountHint,
            ),
            const SizedBox(height: AppDimens.spaceSm),
          ],
        ),
      ),
    );
  }
}
