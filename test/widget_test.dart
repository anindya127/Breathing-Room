import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smoke_counter/main.dart';

void main() {
  testWidgets('App builds without errors', (tester) async {
    // The app reads its settings from SharedPreferences before the first frame,
    // so the test needs the same override main() installs.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: const BreathingRoomApp(),
      ),
    );
    await tester.pumpAndSettle();
  });
}
