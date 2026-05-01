import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_front/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ChatSaoApp());

    expect(find.text('Welcome Back!'), findsOneWidget);
  });
}
