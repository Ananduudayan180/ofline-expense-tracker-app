import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum ExpenseCategoryType {
  food,
  travel,
  shopping,
  bills,
  other,
}

class ExpenseCategory {
  final ExpenseCategoryType type;
  final String label;
  final String fullName;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.type,
    required this.label,
    required this.fullName,
    required this.icon,
    required this.color,
  });

  /// Adapts category accent color for dark mode when high contrast is needed
  Color getEffectiveColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return color;
    switch (type) {
      case ExpenseCategoryType.bills:
        return const Color(0xFF8BAE78);
      case ExpenseCategoryType.other:
        return const Color(0xFF7A8073);
      default:
        return color;
    }
  }

  static const List<ExpenseCategory> all = [
    ExpenseCategory(
      type: ExpenseCategoryType.food,
      label: 'Food',
      fullName: 'Food & Dining',
      icon: Icons.restaurant,
      color: AppColors.catFood,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.travel,
      label: 'Travel',
      fullName: 'Transit & Travel',
      icon: Icons.directions_subway_rounded,
      color: AppColors.catTravel,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.shopping,
      label: 'Shopping',
      fullName: 'Retail & Shopping',
      icon: Icons.shopping_bag_outlined,
      color: AppColors.catShopping,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.bills,
      label: 'Bills',
      fullName: 'Bills & Utilities',
      icon: Icons.receipt_long_outlined,
      color: AppColors.catBills,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.other,
      label: 'Other',
      fullName: 'General / Other',
      icon: Icons.more_horiz_rounded,
      color: AppColors.catOther,
    ),
  ];

  static ExpenseCategory fromType(ExpenseCategoryType type) {
    return all.firstWhere((c) => c.type == type, orElse: () => all.last);
  }

  static ExpenseCategory fromString(String name) {
    final lower = name.toLowerCase();
    return all.firstWhere(
      (c) =>
          c.type.name == lower ||
          c.label.toLowerCase() == lower ||
          c.fullName.toLowerCase().contains(lower),
      orElse: () => all.last,
    );
  }
}
