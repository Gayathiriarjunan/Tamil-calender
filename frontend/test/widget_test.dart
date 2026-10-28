import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamil_nallkaati/main.dart';
import 'package:flutter/material.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Use mock storage during testing.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Tamil Nallkaati welcome screen loads',
      (WidgetTester tester) async {
    // Set a suitable screen size.
    await tester.binding.setSurfaceSize(
      const Size(400, 850),
    );

    // Launch the application.
    await tester.pumpWidget(
      const TamilNallkaatiApp(),
    );

    // Wait for the welcome screen preference check.
    await tester.pumpAndSettle();

    // Verify that the app starts.
    expect(
      find.text('தமிழ் நாள்காட்டி'),
      findsWidgets,
    );

    // Restore the original screen size.
    await tester.binding.setSurfaceSize(null);
  });
}
