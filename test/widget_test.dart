import 'package:firebase_core/firebase_core.dart';
import 'package:kakikenyang/main.dart';
import 'package:flutter_test/flutter_test.dart';
import './mock.dart';

void main() {
  // Setup Mock Firebase sebelum semua test
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app using AppRoot (which includes MultiProvider)
    await tester.pumpWidget(const AppRoot());

    // Cek apakah inisialisasi awal berjalan tanpa crash
    expect(find.byType(AppRoot), findsOneWidget);
  });
}
