import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:timer_app/main.dart';
import 'package:timer_app/providers/timer_provider.dart';

void main() {
  testWidgets('Timer app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TimerProvider()),
        ],
        child: const MaterialApp(
          home: MyApp(),
        ),
      ),
    );

    // Verify that our app starts with timer at 00:00:00
    expect(find.text('00:00:00'), findsOneWidget);
    expect(find.text('开始'), findsOneWidget);
  });

  testWidgets('Timer provider test', (WidgetTester tester) async {
    final timerProvider = TimerProvider();
    
    // Test initial state
    expect(timerProvider.isRunning, false);
    expect(timerProvider.elapsedSeconds, 0);
    expect(timerProvider.formattedTime, '00:00:00');
    
    // Test description setting
    timerProvider.setDescription('测试任务');
    expect(timerProvider.description, '测试任务');
    
    // Test timer start
    timerProvider.startTimer();
    expect(timerProvider.isRunning, true);
    expect(timerProvider.startTime, isNotNull);
    
    // Test timer pause
    timerProvider.pauseTimer();
    expect(timerProvider.isRunning, false);
    
    // Test timer reset
    timerProvider.resetTimer();
    expect(timerProvider.isRunning, false);
    expect(timerProvider.elapsedSeconds, 0);
    expect(timerProvider.description, '');
  });
}
