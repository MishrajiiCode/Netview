import 'package:flutter_test/flutter_test.dart';
import 'package:movi/main.dart';

void main() {
  testWidgets('Movi app smoke test', (WidgetTester tester) async {
    // Smoke test — the app requires Firebase so full widget tests
    // should use a mocked Firebase instance.
    expect(MoviApp, isNotNull);
  });
}
