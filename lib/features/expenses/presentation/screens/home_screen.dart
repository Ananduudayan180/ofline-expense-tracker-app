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
import '../widgets/quick_add_bottom_sheet.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/transaction_list_tile.dart';
import 'add_expense_screen.dart';

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
          style: typography.titleSm.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          const ThemeToggleButton(),
          const SizedBox(width: AppDimens.spaceXs),
          IconButton(
            tooltip: 'Add Full Expense',
            icon: Icon(Icons.add_circle_outline, color: colors.ink),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: AppDimens.spaceSm),
        ],
      ),
      body: expensesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading data: $err',
            style: TextStyle(color: colors.error),
          ),
        ),
        data: (expenses) {
          final displayedTransactions = _showAllTransactions
              ? expenses
              : expenses.take(4).toList();

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
                      previousAmount: monthStats.previousPeriodAmount > 0
                          ? monthStats.previousPeriodAmount
                          : 1482.00,
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
                      topCategoryName: monthStats.topCategory?.category.fullName,
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
                                  _showAllTransactions ? 'Show less' : 'View all',
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
                    if (expenses.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(AppDimens.spaceXl),
                        decoration: BoxDecoration(
                          color: colors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                          border: Border.all(
                            color: colors.borderSubtle,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.wallet_outlined,
                              size: 48,
                              color: colors.textMuted,
                            ),
                            const SizedBox(height: AppDimens.spaceSm),
                            Text(
                              'No transactions yet',
                              style: typography.titleSm,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap + below to add your first expense.',
                              style: typography.bodyMd,
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                          border: Border.all(
                            color: colors.borderSubtle,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: colors.isDark ? 0.3 : 0.02),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            for (int i = 0;
                                i < displayedTransactions.length;
                                i++) ...[
                              TransactionListTile(
                                expense: displayedTransactions[i],
                                onDelete: () {
                                  ref
                                      .read(expenseListProvider.notifier)
                                      .deleteExpense(displayedTransactions[i].id);
                                },
                              ),
                              if (i < displayedTransactions.length - 1)
                                Divider(
                                  height: 1,
                                  indent: AppDimens.spaceMd,
                                  endIndent: AppDimens.spaceMd,
                                  color: colors.surfaceContainerLow,
                                ),
                            ],
                          ],
                        ),
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
                  shape: const CircleBorder(),
                  onPressed: () {
                    QuickAddBottomSheet.show(context);
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
