import 'package:expense_tracker/features/expenses/presentation/widgets/recent_transactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/expense_providers.dart';
import '../widgets/category_distribution_bar.dart';
import '../widgets/hero_monthly_card.dart';
import '../widgets/metric_tile.dart';
import 'expense_bottom_sheet.dart';
import '../widgets/theme_toggle_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showAllTransactions = false;

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expenseListProvider);
    final monthStats = ref.watch(currentMonthStatsProvider);
    final todayStats = ref.watch(todayStatsProvider);
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Expense Tracker',
          style: typography.headlineMd.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          const ThemeToggleButton(),
          const SizedBox(width: AppDimens.spaceSm),
        ],
      ),
      body: expensesAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (err, stack) => Center(
          child: Text(
            'Error loading data: $err',
            style: TextStyle(color: colors.error),
          ),
        ),
        data: (expenses) {
          return Stack(
            children: [
              RefreshIndicator(
                color: colors.onPrimary,
                backgroundColor: colors.primary,
                onRefresh: () async {
                  ref.invalidate(expenseListProvider);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(
                    left: AppDimens.margin,
                    right: AppDimens.margin,
                    top: AppDimens.spaceSm,
                    bottom: 100, // clearance for FAB & bottom nav
                  ),
                  children: [
                    // Monthly Hero Card
                    HeroMonthlyCard(
                      totalAmount: monthStats.totalAmount,
                      percentageChange: monthStats.percentageChangeFromPrevious,
                      previousAmount: monthStats.previousPeriodAmount,
                    ),
                    const SizedBox(height: AppDimens.spaceMd),

                    // 50/50 Metric Tiles
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: "Today's spending",
                            value: CurrencyFormatter.format(todayStats.total),
                            subtitle: '${todayStats.count} expenses today',
                            icon: Icons.receipt_long_outlined,
                          ),
                        ),
                        const SizedBox(width: AppDimens.spaceMd),
                        Expanded(
                          child: MetricTile(
                            label: 'Transactions',
                            value: '${monthStats.count} items',
                            subtitle:
                                'Avg. ${CurrencyFormatter.format(monthStats.averageAmount)} / tx',
                            icon: Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.spaceLg),

                    // Category Distribution Bar
                    CategoryDistributionBar(
                      breakdowns: monthStats.categoryBreakdowns,
                      topCategoryName:
                          monthStats.topCategory?.category.fullName,
                    ),
                    const SizedBox(height: AppDimens.spaceLg),

                    // Recent Transactions Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: typography.titleSm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.ink,
                          ),
                        ),
                        if (expenses.length > 4)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showAllTransactions = !_showAllTransactions;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _showAllTransactions
                                      ? 'Show less'
                                      : 'View all',
                                  style: typography.labelMd.copyWith(
                                    color: colors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Icon(
                                  _showAllTransactions
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.chevron_right_rounded,
                                  size: 18,
                                  color: colors.primaryDark,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.spaceSm),

                    // Transactions Card Container
                    RecentTransactions(
                      expenses: expenses,
                      showAllTransactions: _showAllTransactions,
                    ),
                  ],
                ),
              ),

              // Floating Action Button anchored bottom-right
              Positioned(
                right: AppDimens.margin,
                bottom: AppDimens.spaceLg,
                child: FloatingActionButton(
                  heroTag: 'home_fab',
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  elevation: 6,
                  onPressed: () {
                    ExpenseBottomSheet.show(context);
                  },
                  child: Icon(Icons.add, size: 28, color: colors.onPrimary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
