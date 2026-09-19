import 'package:edencrew_assignment_starter/domain/models/daily_price.dart';
import 'package:edencrew_assignment_starter/domain/models/stock.dart';
import 'package:edencrew_assignment_starter/domain/models/stock_quote.dart';
import 'package:edencrew_assignment_starter/features/stock_detail/view_model/stock_detail_view_model.dart';
import 'package:edencrew_assignment_starter/features/stock_detail/view_model/stock_detail_view_state.dart';
import 'package:edencrew_assignment_starter/shared/favorites/favorite_store.dart';
import 'package:edencrew_assignment_starter/shared/models/load_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_stock_repository.dart';

void main() {
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

  test('기간을 늘리면 부족한 페이지만 받고 줄이면 캐시를 재사용한다', () async {
    final store = FavoriteStore();
    final repository = FakeStockRepository(
      quotes: const <String, StockQuote>{'005930': quote},
      dailyPricePages: _pages(lastPage: 25),
    );
    final viewModel = StockDetailViewModel(
      stock: stock,
      favoriteStore: store,
      stockRepository: repository,
    );

    await pumpEventQueue();
    expect(repository.requestedDailyPricePages, <int>[1, 2]);
    expect(viewModel.state.status, LoadStatus.success);
    expect(viewModel.state.dailyPrices, hasLength(20));

    await viewModel.changePeriod(StockPeriod.threeMonths);
    expect(repository.requestedDailyPricePages, <int>[1, 2, 3, 4, 5, 6]);
    expect(viewModel.state.dailyPrices, hasLength(60));

    await viewModel.changePeriod(StockPeriod.oneMonth);
    expect(repository.requestedDailyPricePages, <int>[1, 2, 3, 4, 5, 6]);
    expect(viewModel.state.dailyPrices, hasLength(20));

    viewModel.dispose();
    store.dispose();
  });

  test('요청 기간보다 lastPage가 작으면 마지막 페이지까지만 받는다', () async {
    final store = FavoriteStore();
    final repository = FakeStockRepository(
      quotes: const <String, StockQuote>{'005930': quote},
      dailyPricePages: _pages(lastPage: 4),
    );
    final viewModel = StockDetailViewModel(
      stock: stock,
      favoriteStore: store,
      stockRepository: repository,
    );

    await pumpEventQueue();
    await viewModel.changePeriod(StockPeriod.oneYear);

    expect(repository.requestedDailyPricePages, <int>[1, 2, 3, 4]);
    expect(viewModel.state.dailyPrices, hasLength(40));

    viewModel.dispose();
    store.dispose();
  });
}

Map<int, DailyPricePage> _pages({required int lastPage}) {
  final pages = <int, DailyPricePage>{};
  final baseDate = DateTime.utc(2026, 9, 19);
  for (var page = 1; page <= lastPage; page++) {
    pages[page] = DailyPricePage(
      lastPage: lastPage,
      items: <DailyPrice>[
        for (var index = 0; index < 10; index++)
          _dailyPrice(
            baseDate.subtract(Duration(days: (page - 1) * 10 + index)),
          ),
      ],
    );
  }
  return pages;
}

DailyPrice _dailyPrice(DateTime date) {
  final dateText =
      '${date.year.toString().padLeft(4, '0')}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';
  final close = 100000 + date.day;
  return DailyPrice(
    localDate: dateText,
    closePrice: close,
    openPrice: close - 100,
    highPrice: close + 200,
    lowPrice: close - 200,
    accumulatedTradingVolume: 1000000 + date.day,
  );
}
