import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smoke_counter/main.dart';

void main() {
  testWidgets('App builds without errors', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BreathingRoomApp()),
    );
    await tester.pumpAndSettle();
  });
}
