// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smiley_painter/main.dart';

void main() {
  testWidgets('Smiley screen shows mood controls', (WidgetTester tester) async {
    await tester.pumpWidget(const SmileyApp());

    expect(find.text('Mood: 0.80'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('Face buttons switch the painter face', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SmileyApp());

    SmileyPainter painter() =>
        tester.widget<CustomPaint>(find.byKey(const Key('smiley'))).painter!
            as SmileyPainter;

    expect(painter().faceType, FaceType.classic);

    await tester.tap(find.text('Surprised'));
    await tester.pump();
    expect(painter().faceType, FaceType.surprised);

    await tester.tap(find.text('Sleepy'));
    await tester.pump();
    expect(painter().faceType, FaceType.sleepy);
  });

  testWidgets('Tap cycles faces and long-press randomizes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SmileyApp());
    final smiley = find.byKey(const Key('smiley'));

    await tester.tap(smiley);
    await tester.pump();
    expect(find.text('Face changed to Sleepy'), findsOneWidget);

    await tester.longPress(smiley);
    await tester.pumpAndSettle();
    expect(find.textContaining('Random mood'), findsOneWidget);
    expect(find.text('Face changed to Sleepy'), findsNothing);
    expect(
      (tester.widget<CustomPaint>(smiley).painter! as SmileyPainter).faceColor,
      isNotNull,
    );
  });
}
