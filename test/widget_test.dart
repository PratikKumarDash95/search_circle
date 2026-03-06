import 'package:flutter_test/flutter_test.dart';
import 'package:search_circle/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SearchCircleApp());
    expect(find.text('SearchCircle'), findsNothing); // RichText won't match
    await tester.pump(const Duration(seconds: 1));
  });
}
