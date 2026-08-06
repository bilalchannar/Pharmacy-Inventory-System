import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_inventory_system/main.dart';

void main() {
  testWidgets('App loads successfully smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Pharmacy Inventory System'), findsOneWidget);
  });
}
