import 'dart:math' as math;

import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_dimens.dart';
import 'package:expense_tracker/core/constants/app_typography.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomSheetHeroAmountCard extends StatelessWidget {
  final TextEditingController amountController;
  final bool showEnterAmountHint;
  final void Function(String) setAmountFromInput;
  final VoidCallback clearAmount;
  final VoidCallback? onResetAmountHint;

  const BottomSheetHeroAmountCard({
    super.key,
    required this.amountController,
    this.showEnterAmountHint = false,
    required this.setAmountFromInput,
    required this.clearAmount,
    this.onResetAmountHint,
  });

  void _syncAmountText(String text) {
    amountController.text = text;
    amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.spaceLg,
        horizontal: AppDimens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: showEnterAmountHint ? colors.error : colors.borderSubtle,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.isDark ? 0.3 : 0.02),
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
              final maxFieldWidth = math.max(constraints.maxWidth - 46, 80.0);
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
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
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
                          setAmountFromInput(val);
                          if (showEnterAmountHint) {
                            final parsed = double.tryParse(val) ?? 0.0;
                            if (parsed > 0) {
                              onResetAmountHint?.call();
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
              clearAmount();
              _syncAmountText('');
            },
          ),
        ],
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
