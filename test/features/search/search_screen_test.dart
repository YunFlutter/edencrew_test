import 'package:edencrew_assignment_starter/domain/models/stock.dart';
import 'package:edencrew_assignment_starter/features/search/view/search_screen.dart';
import 'package:edencrew_assignment_starter/shared/favorites/favorite_store.dart';
import 'package:edencrew_assignment_starter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_stock_repository.dart';

void main() {
  testWidgets('검색 전 초기 안내와 결과 없음 상태를 전환한다', (tester) async {
    final store = FavoriteStore();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: SearchScreen(
          favoriteStore: store,
          stockRepository: FakeStockRepository(),
        ),
      ),
    );

    expect(find.text('종목을 검색해 보세요'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '없는종목');
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pump();

    expect(find.text('검색 결과가 없습니다'), findsOneWidget);
    expect(find.text("'없는종목'와 일치하는 검색 결과를 찾지 못했습니다."), findsOneWidget);

    await tester.tap(find.byTooltip('검색어 지우기'));
    await tester.pump();
    expect(find.text('종목을 검색해 보세요'), findsOneWidget);
    store.dispose();
  });

  testWidgets('검색 결과의 관심 등록과 해제 토스트를 즉시 반영한다', (tester) async {
    final store = FavoriteStore();
    final stock = Stock.domestic(symbol: '005930', name: '삼성전자', market: '코스피');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: SearchScreen(
          favoriteStore: store,
          stockRepository: FakeStockRepository(searchResults: <Stock>[stock]),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '삼성');
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pump();

    expect(find.text('삼성전자'), findsOneWidget);
    expect(find.text('005930 · 코스피'), findsOneWidget);

    await tester.tap(find.byTooltip('관심 등록'));
    await tester.pump();
    expect(store.contains(stock.id), isTrue);
    expect(find.text('관심이 등록되었습니다'), findsOneWidget);

    await tester.tap(find.byTooltip('관심 해제'));
    await tester.pump();
    expect(store.contains(stock.id), isFalse);
    expect(find.text('관심이 해제되었습니다'), findsOneWidget);
    expect(find.text('관심이 등록되었습니다'), findsNothing);
    store.dispose();
  });
}
