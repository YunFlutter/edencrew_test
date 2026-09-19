import 'package:flutter/foundation.dart';

import '../../../domain/models/stock.dart';
import '../../../domain/models/daily_price.dart';
import '../../../domain/models/stock_quote.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../../../shared/favorites/favorite_store.dart';
import '../../../shared/models/load_status.dart';
import 'stock_detail_view_state.dart';

class StockDetailViewModel extends ChangeNotifier {
  StockDetailViewModel({
    required Stock stock,
    required FavoriteStore favoriteStore,
    required StockRepository stockRepository,
  }) : _favoriteStore = favoriteStore,
       _stockRepository = stockRepository,
       _state = StockDetailViewState(
         stock: stock,
         status: LoadStatus.initial,
         period: StockPeriod.oneMonth,
         isFavorite: favoriteStore.contains(stock.id),
       ) {
    _favoriteStore.addListener(_syncFavorite);
    load();
  }

  final FavoriteStore _favoriteStore;
  final StockRepository _stockRepository;
  final Map<int, DailyPricePage> _dailyPricePages = <int, DailyPricePage>{};
  StockDetailViewState _state;
  bool _disposed = false;
  int _requestVersion = 0;

  StockDetailViewState get state => _state;

  Future<void> changePeriod(StockPeriod period) async {
    if (_disposed || period == _state.period) return;
    _state = _state.copyWith(
      period: period,
      isLoadingPeriod: true,
      clearErrorMessage: true,
    );
    notifyListeners();
    await _loadPeriod(period);
  }

  Future<void> load() async {
    if (_disposed) return;
    final hasContent = _state.quote != null || _state.dailyPrices.isNotEmpty;
    _state = _state.copyWith(
      status: hasContent ? LoadStatus.success : LoadStatus.loading,
      isLoadingPeriod: hasContent,
      clearErrorMessage: true,
    );
    notifyListeners();

    final requestVersion = ++_requestVersion;
    try {
      final quoteFuture = _state.quote == null
          ? _stockRepository.getQuotes(<String>[_state.stock.symbol])
          : Future<Map<String, StockQuote>>.value(<String, StockQuote>{
              _state.stock.symbol: _state.quote!,
            });
      final results = await Future.wait<Object>(<Future<Object>>[
        quoteFuture,
        _loadDailyPrices(_state.period),
      ]);
      if (_disposed || requestVersion != _requestVersion) return;

      final quotes = results[0] as Map<String, StockQuote>;
      final dailyPrices = results[1] as List<DailyPrice>;
      final quote = quotes[_state.stock.symbol];
      if (quote == null) throw StateError('실시간 시세가 없습니다.');
      _state = _state.copyWith(
        status: dailyPrices.isEmpty ? LoadStatus.empty : LoadStatus.success,
        quote: quote,
        dailyPrices: dailyPrices,
        isLoadingPeriod: false,
        clearErrorMessage: true,
      );
      notifyListeners();
    } on Object {
      if (_disposed || requestVersion != _requestVersion) return;
      _state = _state.copyWith(
        status: hasContent ? LoadStatus.success : LoadStatus.error,
        isLoadingPeriod: false,
        errorMessage: '종목 정보를 불러오지 못했습니다. 다시 시도해 주세요.',
      );
      notifyListeners();
    }
  }

  Future<void> _loadPeriod(StockPeriod period) async {
    final requestVersion = ++_requestVersion;
    try {
      final prices = await _loadDailyPrices(period);
      if (_disposed || requestVersion != _requestVersion) return;
      _state = _state.copyWith(
        status: prices.isEmpty ? LoadStatus.empty : LoadStatus.success,
        dailyPrices: prices,
        isLoadingPeriod: false,
        clearErrorMessage: true,
      );
      notifyListeners();
    } on Object {
      if (_disposed || requestVersion != _requestVersion) return;
      _state = _state.copyWith(
        isLoadingPeriod: false,
        errorMessage: '기간 시세를 불러오지 못했습니다. 다시 시도해 주세요.',
      );
      notifyListeners();
    }
  }

  Future<List<DailyPrice>> _loadDailyPrices(StockPeriod period) async {
    if (!_dailyPricePages.containsKey(1)) {
      _dailyPricePages[1] = await _stockRepository.getDailyPrices(
        _state.stock.symbol,
        1,
      );
    }

    final lastPage = _dailyPricePages[1]!.lastPage;
    final targetPage = period.pageCount.clamp(1, lastPage);
    final missingPages = <int>[
      for (var page = 2; page <= targetPage; page++)
        if (!_dailyPricePages.containsKey(page)) page,
    ];
    final fetchedPages = await Future.wait(
      missingPages.map(
        (page) => _stockRepository.getDailyPrices(_state.stock.symbol, page),
      ),
    );
    for (var index = 0; index < missingPages.length; index++) {
      _dailyPricePages[missingPages[index]] = fetchedPages[index];
    }

    final byDate = <String, DailyPrice>{};
    for (var page = 1; page <= targetPage; page++) {
      for (final price
          in _dailyPricePages[page]?.items ?? const <DailyPrice>[]) {
        byDate.putIfAbsent(price.localDate, () => price);
      }
    }
    final prices = byDate.values.toList()
      ..sort((left, right) => right.localDate.compareTo(left.localDate));
    return List<DailyPrice>.unmodifiable(prices.take(period.tradingDayCount));
  }

  void toggleFavorite() {
    _favoriteStore.toggle(_state.stock);
  }

  void _syncFavorite() {
    if (_disposed) return;
    _state = _state.copyWith(
      isFavorite: _favoriteStore.contains(_state.stock.id),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    _favoriteStore.removeListener(_syncFavorite);
    super.dispose();
  }
}
