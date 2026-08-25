// Базовый smoke-test: приложение запускается и показывает splash-экран.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fishing_app/app.dart';
import 'package:fishing_app/core/constants/app_constants.dart';

void main() {
  testWidgets('Splash screen отображается при старте', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FishingApp()),
    );

    expect(find.text(AppStrings.appName), findsOneWidget);

    // Даём сработать таймеру автоперехода со splash-экрана, чтобы после
    // теста не осталось незавершённых таймеров.
    await tester.pump(const Duration(milliseconds: 1300));
  });
}
