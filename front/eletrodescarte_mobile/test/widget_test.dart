
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrodescarte_mobile/main.dart';

void main() {
  testWidgets('EletroDescarte smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login screen is presented.
    expect(find.text('EletroDescarte'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
