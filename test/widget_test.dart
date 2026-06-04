import 'package:flutter_test/flutter_test.dart';

import 'package:hair_connect/main.dart';

void main() {
  testWidgets('MyApp builds without errors and shows HairConnect',
      (WidgetTester tester) async {
    // Construye MyApp (SplashPage con Future.delayed de 3s).
    await tester.pumpWidget(const MyApp());

    // Verifica que el splash se construye correctamente mostrando el nombre
    // de la app.
    expect(find.text('HairConnect'), findsOneWidget);

    // Avanza el reloj falso más allá del Future.delayed de SplashPage (3s)
    // para que no queden timers pendientes al finalizar el test.
    await tester.pump(const Duration(seconds: 4));

    // Procesa el frame de navegación (SplashPage → WelcomePage).
    await tester.pump();
  });
}
