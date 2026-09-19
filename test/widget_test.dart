import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edencrew_assignment_starter/app/app.dart';
import 'package:edencrew_assignment_starter/app/app_dependencies.dart';
import 'package:edencrew_assignment_starter/shared/favorites/favorite_store.dart';

void main() {
  testWidgets('관심 화면이 다크 테마로 렌더링된다', (WidgetTester tester) async {
    final dependencies = AppDependencies(favoriteStore: FavoriteStore());
    await tester.pumpWidget(EdencrewAssignmentApp(dependencies: dependencies));

    expect(find.text('관심 종목이 없습니다'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
  });
}
