import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_dimens.dart';
import 'package:expense_tracker/core/constants/app_typography.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/add_expense_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaveAndUpdateButton extends ConsumerWidget {
  final VoidCallback handleSave;
  final bool showEnterAmountHint;

  const SaveAndUpdateButton({
    super.key,
    required this.handleSave,
    required this.showEnterAmountHint,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addState = ref.watch(addExpenseNotifierProvider);
    final colors = context.colors;
    final typography = context.typography;

    return Builder(
      builder: (context) {
        final hasAmount = addState.amount > 0 || !showEnterAmountHint;
        final btnBg = hasAmount ? colors.primary : colors.surfaceContainerHigh;
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
              onPressed: handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBg,
                foregroundColor: btnFg,
                elevation: 0,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
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
    );
  }
}
