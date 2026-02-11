import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bridge/app.dart';

void main() {
  testWidgets('Bridge app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BridgeApp()),
    );
    expect(find.byType(MaterialApp), findsNothing); // uses MaterialApp.router
    expect(find.byType(Router), findsOneWidget);
  });
}
