import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_dimens.dart';
import 'package:expense_tracker/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

class SaveAndUpdateButton extends StatelessWidget {
  final VoidCallback handleSave;
  final bool showEnterAmountHint;
  final bool showNoChangesHint;
  final bool isEditing;
  final bool isSaving;

  const SaveAndUpdateButton({
    super.key,
    required this.handleSave,
    this.showEnterAmountHint = false,
    this.showNoChangesHint = false,
    this.isEditing = false,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final isAmountWarning = showEnterAmountHint;
    final isNoChangesWarning = isEditing && showNoChangesHint;
    final isWarning = isAmountWarning || isNoChangesWarning;

    final btnBg = !isWarning ? colors.primary : colors.surfaceContainerHigh;
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
      buttonText = isEditing ? 'Update' : 'Save';
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
          key: ValueKey('$isWarning-$buttonText-$isSaving'),
          onPressed: isSaving ? null : handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: btnBg,
            foregroundColor: btnFg,
            disabledBackgroundColor: btnBg,
            disabledForegroundColor: btnFg,
            elevation: 0,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              side: isWarning
                  ? BorderSide(
                      color: colors.error.withValues(alpha: 0.35),
                      width: 1.5,
                    )
                  : BorderSide.none,
            ),
          ),
          child: isSaving
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
  }
}
