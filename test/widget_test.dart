import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hiveescape/main.dart' as app;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Hive Escape home loads correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 950);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues(<String, Object>{
      'hive_escape_language': 'it',
      'hive_escape_age_group_v1': 'child',
      'hive_escape_tutorial_completed_v1': true,
      'hive_escape_current_level_easy': 1,
    });

    app.currentAppLanguage = app.AppLanguage.italian;
    app.appLanguageNotifier.value = app.AppLanguage.italian;

    await tester.pumpWidget(const app.HiveEscapeApp());
    await tester.pump(const Duration(milliseconds: 800));

    expect(
      find.text('FUGA DALL’ALVEARE', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('GIOCA', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byIcon(Icons.settings_rounded, skipOffstage: false),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  });
}
