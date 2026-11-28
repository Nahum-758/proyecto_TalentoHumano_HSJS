import 'package:flutter_test/flutter_test.dart';
import 'package:talento_humano/src/app.dart';

void main() {
  testWidgets('TalentoHumanoApp se construye correctamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TalentoHumanoApp());
    await tester.pump();

    expect(find.byType(TalentoHumanoApp), findsOneWidget);
  });
}