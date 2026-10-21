import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_dimens.dart';
import 'package:expense_tracker/core/constants/app_typography.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/add_expense_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteInputField extends ConsumerWidget {
  final TextEditingController noteController;

  const NoteInputField({super.key, required this.noteController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final notifier = ref.read(addExpenseNotifierProvider.notifier);
    final addState = ref.watch(addExpenseNotifierProvider);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Note',
              style: typography.labelSm.copyWith(color: colors.textMuted),
            ),
            Text(
              '${addState.note.length}/60',
              style: typography.labelSm.copyWith(color: colors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: noteController,
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
            hintStyle: typography.bodyMd.copyWith(color: colors.textMuted),
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
    );
  }
}
