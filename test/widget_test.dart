import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edencrew_assignment_starter/app/app.dart';
import 'package:edencrew_assignment_starter/app/app_dependencies.dart';
import 'package:edencrew_assignment_starter/core/widgets/app_bottom_navigation.dart';
import 'package:edencrew_assignment_starter/shared/favorites/favorite_store.dart';

import 'helpers/fake_stock_repository.dart';

void main() {
  testWidgets('관심 화면이 다크 테마로 렌더링된다', (WidgetTester tester) async {
    final dependencies = AppDependencies(
      favoriteStore: FavoriteStore(),
      stockRepository: FakeStockRepository(),
    );
    await tester.pumpWidget(EdencrewAssignmentApp(dependencies: dependencies));

    expect(find.text('관심 종목이 없습니다'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
    expect(
      find.descendant(
        of: find.byType(AppBottomNavigation),
        matching: find.byType(SafeArea),
      ),
      findsOneWidget,
    );
  });

  testWidgets('정렬 시트에서 선택한 기준을 헤더에 반영한다', (WidgetTester tester) async {
    final dependencies = AppDependencies(
      favoriteStore: FavoriteStore(),
      stockRepository: FakeStockRepository(),
    );
    await tester.pumpWidget(EdencrewAssignmentApp(dependencies: dependencies));

    await tester.tap(find.text('가나다순'));
    await tester.pumpAndSettle();

    expect(find.text('현재가순'), findsOneWidget);
    expect(find.text('등락률순'), findsOneWidget);
    await tester.tap(find.text('현재가순'));
    await tester.pumpAndSettle();

    expect(find.text('현재가순'), findsOneWidget);
    expect(find.text('가나다순'), findsNothing);
  });
}
