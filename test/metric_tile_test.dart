import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/app_dimens.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/metric_tile.dart';

void main() {
  group('MetricTile and Metric Boxes Row Responsiveness Tests', () {
    testWidgets('renders MetricTile on 132px width without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 132,
                child: MetricTile(
                  label: "Today's spending",
                  value: '\$120.00',
                  subtitle: '3 expenses today',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text("TODAY'S SPENDING"), findsOneWidget);
      expect(find.text('\$120.00'), findsOneWidget);
      expect(find.text('3 expenses today'), findsOneWidget);
    });

    testWidgets('renders Transactions MetricTile on small width without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 132,
                child: MetricTile(
                  label: 'Transactions',
                  value: '15 items',
                  subtitle: 'Avg. \$24.50 / tx',
                  icon: Icons.payments_outlined,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('TRANSACTIONS'), findsOneWidget);
      expect(find.text('15 items'), findsOneWidget);
    });

    testWidgets('handles extreme narrow width (100px) and long content gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 100,
                child: MetricTile(
                  label: "Today's very long spending label",
                  value: '\$9,999,999.00',
                  subtitle: '999 expenses today with very long description',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    // Test the 50/50 Metric Boxes Row exactly as laid out in HomeScreen
    final screenWidths = [280.0, 320.0, 360.0, 375.0, 390.0, 412.0, 600.0, 800.0];

    for (final width in screenWidths) {
      testWidgets('Metric boxes 50/50 Row renders with no overflow on width $width', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.margin),
                    child: Row(
                      children: const [
                        Expanded(
                          child: MetricTile(
                            label: "Today's spending",
                            value: '\$142.50',
                            subtitle: '4 expenses today',
                            icon: Icons.receipt_long_outlined,
                          ),
                        ),
                        SizedBox(width: AppDimens.spaceMd),
                        Expanded(
                          child: MetricTile(
                            label: 'Transactions',
                            value: '28 items',
                            subtitle: 'Avg. \$35.20 / tx',
                            icon: Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text("TODAY'S SPENDING"), findsOneWidget);
        expect(find.text('TRANSACTIONS'), findsOneWidget);
        expect(find.text('\$142.50'), findsOneWidget);
        expect(find.text('28 items'), findsOneWidget);
      });
    }
  });
}
