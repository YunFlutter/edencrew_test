import 'package:edencrew_assignment_starter/domain/models/daily_price.dart';
import 'package:edencrew_assignment_starter/domain/models/stock.dart';
import 'package:edencrew_assignment_starter/domain/models/stock_quote.dart';
import 'package:edencrew_assignment_starter/features/stock_detail/view/stock_detail_screen.dart';
import 'package:edencrew_assignment_starter/shared/favorites/favorite_store.dart';
import 'package:edencrew_assignment_starter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_stock_repository.dart';

void main() {
  testWidgets('393x852에서 상세 핵심 영역을 오버플로 없이 렌더링한다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const stock = Stock(
      id: 'domestic:005930',
      symbol: '005930',
      name: '삼성전자',
      market: '코스피',
    );
    const quote = StockQuote(
      symbol: '005930',
      currentPrice: 179700,
      previousClose: 180100,
      openPrice: 172100,
      highPrice: 181700,
      lowPrice: 172000,
      accumulatedTradingVolume: 29113331,
      countOfListedStock: 5919637922,
    );
    final store = FavoriteStore()..add(stock);
    addTearDown(store.dispose);
    final repository = FakeStockRepository(
      quotes: const <String, StockQuote>{'005930': quote},
      dailyPricePages: const <int, DailyPricePage>{
        1: DailyPricePage(
          lastPage: 1,
          items: <DailyPrice>[
            DailyPrice(
              localDate: '20260919',
              closePrice: 179700,
              openPrice: 178000,
              highPrice: 181700,
              lowPrice: 172000,
              accumulatedTradingVolume: 29113466,
            ),
          ],
        ),
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: StockDetailScreen(
          stock: stock,
          favoriteStore: store,
          stockRepository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('삼성전자'), findsOneWidget);
    expect(find.text('179,700'), findsWidgets);
    expect(find.text('1개월'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('stock-detail-chart')),
      findsOneWidget,
    );
    expect(find.text('시가총액'), findsOneWidget);
    expect(find.text('일별 시세'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
