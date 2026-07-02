// Test de fumée : l'app Aria se construit sans erreur.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aria/main.dart';

void main() {
  testWidgets('Aria se lance sans erreur', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AriaApp());
    await tester.pump();

    expect(find.byType(AriaApp), findsOneWidget);
  });
}
