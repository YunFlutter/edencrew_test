import 'package:edencrew_assignment_starter/domain/models/stock.dart';
import 'package:edencrew_assignment_starter/domain/models/stock_quote.dart';
import 'package:edencrew_assignment_starter/features/watchlist/view_model/watchlist_view_model.dart';
import 'package:edencrew_assignment_starter/features/watchlist/view_model/watchlist_view_state.dart';
import 'package:edencrew_assignment_starter/shared/favorites/favorite_store.dart';
import 'package:edencrew_assignment_starter/shared/models/load_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_stock_repository.dart';

void main() {
  const samsung = Stock(
    id: 'domestic:005930',
    symbol: '005930',
    name: '삼성전자',
    market: '코스피',
  );
  const kakao = Stock(
    id: 'domestic:035720',
    symbol: '035720',
    name: '카카오',
    market: '코스피',
  );
  const lg = Stock(
    id: 'domestic:066570',
    symbol: '066570',
    name: 'LG전자',
    market: '코스피',
  );
  const samsungQuote = StockQuote(
    symbol: '005930',
    currentPrice: 72000,
    previousClose: 70000,
    openPrice: 70000,
    highPrice: 73000,
    lowPrice: 69000,
    accumulatedTradingVolume: 100,
    countOfListedStock: 1000,
  );
  const kakaoQuote = StockQuote(
    symbol: '035720',
    currentPrice: 45000,
    previousClose: 40000,
    openPrice: 41000,
    highPrice: 46000,
    lowPrice: 40000,
    accumulatedTradingVolume: 200,
    countOfListedStock: 2000,
  );

  late FavoriteStore store;
  late FakeStockRepository repository;
  late WatchlistViewModel viewModel;

  setUp(() {
    store = FavoriteStore();
    repository = FakeStockRepository(
      quotes: <String, StockQuote>{
        samsung.symbol: samsungQuote,
        kakao.symbol: kakaoQuote,
      },
    );
  });

  tearDown(() {
    viewModel.dispose();
    store.dispose();
  });

  test('관심 종목 시세를 한 번의 batch 요청으로 불러온다', () async {
    store
      ..add(samsung)
      ..add(kakao);

    viewModel = WatchlistViewModel(
      favoriteStore: store,
      stockRepository: repository,
    );
    await _settleAsyncWork();

    expect(repository.quoteRequestCount, 1);
    expect(repository.lastRequestedSymbols, <String>['005930', '035720']);
    expect(viewModel.state.status, LoadStatus.success);
    expect(viewModel.state.quotesBySymbol, hasLength(2));
  });

  test('현재가와 등락률은 내림차순이며 시세 없는 종목은 마지막이다', () async {
    store
      ..add(lg)
      ..add(samsung)
      ..add(kakao);
    viewModel = WatchlistViewModel(
      favoriteStore: store,
      stockRepository: repository,
    );
    await _settleAsyncWork();

    viewModel.changeSortOrder(WatchlistSortOrder.currentPrice);
    expect(viewModel.visibleStocks.map((stock) => stock.symbol), <String>[
      '005930',
      '035720',
      '066570',
    ]);

    viewModel.changeSortOrder(WatchlistSortOrder.changeRate);
    expect(viewModel.visibleStocks.map((stock) => stock.symbol), <String>[
      '035720',
      '005930',
      '066570',
    ]);
  });

  test('가나다순은 종목명과 종목코드 순으로 안정적으로 정렬한다', () {
    store
      ..add(kakao)
      ..add(samsung)
      ..add(lg);
    viewModel = WatchlistViewModel(
      favoriteStore: store,
      stockRepository: repository,
    );

    expect(viewModel.visibleStocks.map((stock) => stock.symbol), <String>[
      '066570',
      '005930',
      '035720',
    ]);
  });

  test('새로고침 실패 시 기존 시세를 유지한다', () async {
    store.add(samsung);
    viewModel = WatchlistViewModel(
      favoriteStore: store,
      stockRepository: repository,
    );
    await _settleAsyncWork();
    repository.quotesError = StateError('network');

    await viewModel.refreshQuotes();

    expect(viewModel.state.status, LoadStatus.success);
    expect(viewModel.quoteFor(samsung), same(samsungQuote));
    expect(viewModel.state.errorMessage, isNotNull);
    expect(viewModel.state.isRefreshing, isFalse);
  });

  test('일부 시세가 누락되면 이전 값 대신 실패 상태로 분리한다', () async {
    store
      ..add(samsung)
      ..add(kakao);
    viewModel = WatchlistViewModel(
      favoriteStore: store,
      stockRepository: repository,
    );
    await _settleAsyncWork();
    repository.quotes.remove(kakao.symbol);

    await viewModel.refreshQuotes();

    expect(viewModel.quoteFor(samsung), same(samsungQuote));
    expect(viewModel.quoteFor(kakao), isNull);
    expect(viewModel.state.failedSymbols, contains(kakao.symbol));
    viewModel.changeSortOrder(WatchlistSortOrder.currentPrice);
    expect(viewModel.visibleStocks.last, same(kakao));
  });
}

Future<void> _settleAsyncWork() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}
