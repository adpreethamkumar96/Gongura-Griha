import 'package:flutter_test/flutter_test.dart';

import 'package:gongura_griha/app/app.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GonguraGrihaApp());

    // Verify that splash screen loads (finds at least one "Splash" text)
    expect(find.text('Splash'), findsWidgets);
  });
}
