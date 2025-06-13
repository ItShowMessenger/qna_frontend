import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qna_frontend/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Mock data for Profile_stu
    final mockData = {
      'userDto': {
        'name': '테스트 사용자',
        'email': 'test@example.com',
      }
    };

    // Build our app and trigger a frame.
    await tester.pumpWidget(QAApp(data: mockData));

    // Since there's no counter in your QAApp, we'll just test that mock name is visible
    expect(find.text('테스트 사용자'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
  });
}
