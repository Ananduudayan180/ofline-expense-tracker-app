import 'package:expense_tracker/features/expenses/presentation/providers/add_expense_notifier.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/save_and_update_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_providers.dart';
import '../widgets/bottom_sheet_hero_amount_card.dart';
import '../widgets/category_chip_grid.dart';
import '../widgets/date_time_selector.dart';
import '../widgets/note_input_field.dart';

class ExpenseBottomSheet extends ConsumerStatefulWidget {
  final Expense? expense;

  const ExpenseBottomSheet({super.key, this.expense});

  bool get isEditing => expense != null;

  static Future<void> show(BuildContext context, {Expense? expense}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseBottomSheet(expense: expense),
    );
  }

  @override
  ConsumerState<ExpenseBottomSheet> createState() => _ExpenseBottomSheetState();
}

class _ExpenseBottomSheetState extends ConsumerState<ExpenseBottomSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  bool _showEnterAmountHint = false;
  bool _showNoChangesHint = false;
  bool _isSaving = false;

  bool get _isEditing => widget.isEditing;

  @override
  void initState() {
    super.initState();
    final existing = widget.expense;

    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: existing?.note ?? '');

    Future.microtask(_initForm);
  }

  void _initForm() {
    if (!mounted) return;
    final notifier = ref.read(addExpenseNotifierProvider.notifier)..reset();
    final existing = widget.expense;

    if (existing == null) {
      notifier.selectDate(DateTime.now());
      return;
    }

    notifier
      ..setAmountFromInput(existing.amount.toStringAsFixed(2))
      ..selectCategory(existing.category)
      ..selectDate(existing.dateTime.toLocal());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  DateTime _atMinute(DateTime d) {
    final local = d.toLocal();
    return DateTime(
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
    );
  }

  bool _hasChanges(Expense original, Expense draft) {
    // 1. Amount changed?
    if ((draft.amount - original.amount).abs() > 0.001) return true;
    // 2. Category changed?
    if (draft.category.type != original.category.type) return true;
    // 3. Date/Time changed? (compared to the minute, like the picker)
    if (_atMinute(draft.dateTime) != _atMinute(original.dateTime)) return true;
    // 4. Note changed? (the controller is the source of truth for the note)
    final originalNote = original.note?.trim() ?? '';
    if (_noteController.text.trim() != originalNote) return true;
    return false;
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    final notifier = ref.read(addExpenseNotifierProvider.notifier);
    final original = widget.expense;
    final isEditing = original != null;

    if (ref.read(addExpenseNotifierProvider).amount <= 0) {
      HapticFeedback.mediumImpact();
      setState(() {
        _showEnterAmountHint = true;
        _showNoChangesHint = false;
      });
      return;
    }

    // Snapshot of the form as the notifier sees it right now.
    final draft = notifier.buildExpense();

    if (original != null && !_hasChanges(original, draft)) {
      HapticFeedback.mediumImpact();
      setState(() {
        _showNoChangesHint = true;
        _showEnterAmountHint = false;
      });
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colors = context.colors;
    final listNotifier = ref.read(expenseListProvider.notifier);

    final Expense expense;
    if (original == null) {
      // Add: exactly what the notifier builds, same as before.
      expense = draft;
    } else {
      // Edit: keep id and other fields from the original, apply the form.
      final note = _noteController.text.trim();
      expense = original.copyWith(
        title: note.isNotEmpty ? note : draft.category.fullName,
        amount: draft.amount,
        category: draft.category,
        dateTime: draft.dateTime,
        note: note.isNotEmpty ? note : null,
      );
    }

    setState(() => _isSaving = true);

    try {
      if (isEditing) {
        await listNotifier.updateExpense(expense);
      } else {
        await listNotifier.addExpense(expense);
      }

      // Only touch the sheet if it is still on screen;
      // the confirmation snackbar can still be shown either way.
      if (mounted) {
        notifier.reset();
        navigator.pop();
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          _successSnackBar(
            colors: colors,
            expense: expense,
            isEditing: isEditing,
          ),
        );
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          _snackBar(
            colors,
            Text(
              isEditing
                  ? "Couldn't update the expense. Try again."
                  : "Couldn't save the expense. Try again.",
              style: TextStyle(color: colors.error, fontSize: 13),
            ),
          ),
        );
    }
  }

  SnackBar _snackBar(AppColorPalette colors, Widget content) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      backgroundColor: colors.surfaceCard,
      content: content,
    );
  }

  SnackBar _successSnackBar({
    required AppColorPalette colors,
    required Expense expense,
    required bool isEditing,
  }) {
    final amountText = CurrencyFormatter.format(expense.amount);
    final message = isEditing
        ? 'Updated • ${expense.title} ($amountText)'
        : 'Expense Logged • ${expense.category.label} ($amountText)';

    return _snackBar(
      colors,
      Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary,
            ),
            child: Icon(
              isEditing ? Icons.edit : Icons.check,
              size: isEditing ? 15 : 16,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(width: AppDimens.spaceSm),
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.ink, fontSize: 13),
            ),
          ),
          if (!isEditing)
            Text(
              'Offline ready',
              style: TextStyle(color: colors.primaryDark, fontSize: 11),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only the category is needed here, so typing an amount doesn't rebuild
    // the whole sheet.
    final category = ref.watch(
      addExpenseNotifierProvider.select((s) => s.category),
    );
    final notifier = ref.read(addExpenseNotifierProvider.notifier);
    final colors = context.colors;
    final typography = context.typography;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    // Warnings go away as soon as the user changes something in the form.
    ref.listen(addExpenseNotifierProvider, (previous, next) {
      if (_showNoChangesHint || (_showEnterAmountHint && next.amount > 0)) {
        setState(() {
          _showNoChangesHint = false;
          if (next.amount > 0) _showEnterAmountHint = false;
        });
      }
    });

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
                  _isEditing ? 'Edit Expense' : 'Add Expense',
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
              selectedCategory: category,
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
                  // Date & Time Selector
                  DateTimeSelector(),
                  const SizedBox(height: AppDimens.spaceMd),
                  // Note Input Field
                  NoteInputField(noteController: _noteController),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.spaceLg),

            // Save / Update Button
            SaveAndUpdateButton(
              handleSave: _handleSave,
              isEditing: _isEditing,
              isSaving: _isSaving,
              showEnterAmountHint: _showEnterAmountHint,
              showNoChangesHint: _showNoChangesHint,
            ),
            const SizedBox(height: AppDimens.spaceSm),
          ],
        ),
      ),
    );
  }
}
