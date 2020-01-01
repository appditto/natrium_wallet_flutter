// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:natrium_wallet_flutter/main.dart';
import 'package:natrium_wallet_flutter/ui/intro/intro_welcome.dart';

// TODO - we can probably do with some proper widget testing

void main() {
  testWidgets('App loads and draws at least 1 widget',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    //await tester.pumpWidget(IntroWelcomePage());

    // Verify that we are on New Wallet screen
    //expect(find.text('New Wallet'), findsOneWidget);
/*
    // Tap the 'New Wallet' icon and trigger a frame.
    await tester.tap(find.text('New Wallet'));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('Require a password'), findsOneWidget);*/
  });
}
