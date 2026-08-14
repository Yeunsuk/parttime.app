import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parttime/app.dart';
void main() {
  testWidgets('smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    // SplashScreen이 1초 지연 후 이동하므로, 남은 타이머 없이 테스트가 끝나도록 흘려보낸다.
    await tester.pump(const Duration(seconds: 2));
  });
}
