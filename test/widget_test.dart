import 'package:kakikenyang/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app using AppRoot (which includes MultiProvider)
    // We use AppRoot because it provides the necessary MultiProvider for MyApp
    await tester.pumpWidget(const AppRoot());

    // Basic check to ensure the app starts without crashing
    expect(find.byType(AppRoot), findsOneWidget);
  });
}