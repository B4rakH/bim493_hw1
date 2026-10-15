import 'package:flutter_test/flutter_test.dart';
import 'package:bim493_hw1/main.dart';

void main() {
  testWidgets('App smoke test loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusEventExplorerApp());
    expect(find.text('Explore Events'), findsOneWidget);
  });
}
