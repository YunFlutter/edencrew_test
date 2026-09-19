import 'package:flutter/foundation.dart';

import '../../../domain/models/stock.dart';
import '../../../domain/models/stock_quote.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../../../shared/favorites/favorite_store.dart';
import '../../../shared/models/load_status.dart';
import 'watchlist_view_state.dart';

class WatchlistViewModel extends ChangeNotifier {
  WatchlistViewModel({
    required FavoriteStore favoriteStore,
    required StockRepository stockRepository,
  }) : _favoriteStore = favoriteStore,
       _stockRepository = stockRepository,
       _state = const WatchlistViewState.initial() {
    _favoriteStore.addListener(_syncFavorites);
    _syncFavorites();
  }

  final FavoriteStore _favoriteStore;
  final StockRepository _stockRepository;
  WatchlistViewState _state;
  bool _disposed = false;
  int _requestVersion = 0;

  WatchlistViewState get state => _state;

  List<Stock> get visibleStocks {
    final stocks = List<Stock>.of(_state.stocks);
    stocks.sort(_compareStocks);
    return stocks;
  }

  StockQuote? quoteFor(Stock stock) => _state.quotesBySymbol[stock.symbol];

  Future<void> refreshQuotes() async {
    if (_disposed || _state.stocks.isEmpty || _state.isRefreshing) return;

    final requestVersion = ++_requestVersion;
    final symbols = _state.stocks.map((stock) => stock.symbol).toList();
    final hasExistingQuotes = _state.quotesBySymbol.isNotEmpty;
    _state = _state.copyWith(
      status: hasExistingQuotes ? LoadStatus.success : LoadStatus.loading,
      isRefreshing: true,
      failedSymbols: const <String>{},
      clearError: true,
    );
    notifyListeners();

    try {
      final quotes = await _stockRepository.getQuotes(symbols);
      if (_disposed || requestVersion != _requestVersion) return;

      final currentSymbols = _state.stocks.map((stock) => stock.symbol).toSet();
      final refreshedQuotes = <String, StockQuote>{
        for (final entry in quotes.entries)
          if (currentSymbols.contains(entry.key)) entry.key: entry.value,
      };
      final failedSymbols = currentSymbols.difference(quotes.keys.toSet());
      _state = _state.copyWith(
        status: LoadStatus.success,
        quotesBySymbol: Map<String, StockQuote>.unmodifiable(refreshedQuotes),
        failedSymbols: Set<String>.unmodifiable(failedSymbols),
        isRefreshing: false,
        errorMessage: failedSymbols.isEmpty ? null : '일부 종목의 시세를 불러오지 못했습니다.',
        clearError: failedSymbols.isEmpty,
      );
      notifyListeners();
    } on Object {
      if (_disposed || requestVersion != _requestVersion) return;
      _state = _state.copyWith(
        status: hasExistingQuotes ? LoadStatus.success : LoadStatus.error,
        isRefreshing: false,
        errorMessage: '시세를 불러오지 못했습니다. 다시 시도해 주세요.',
      );
      notifyListeners();
    }
  }

  void changeSortOrder(WatchlistSortOrder sortOrder) {
    if (_disposed || sortOrder == _state.sortOrder) return;
    _state = _state.copyWith(sortOrder: sortOrder);
    notifyListeners();
  }

  void _syncFavorites() {
    if (_disposed) return;
    _requestVersion++;
    final stocks = _favoriteStore.stocks;
    final symbols = stocks.map((stock) => stock.symbol).toSet();
    final quotes = <String, StockQuote>{
      for (final entry in _state.quotesBySymbol.entries)
        if (symbols.contains(entry.key)) entry.key: entry.value,
    };
    _state = _state.copyWith(
      status: stocks.isEmpty ? LoadStatus.empty : LoadStatus.success,
      stocks: stocks,
      quotesBySymbol: Map<String, StockQuote>.unmodifiable(quotes),
      failedSymbols: const <String>{},
      isRefreshing: false,
      clearError: true,
    );
    notifyListeners();
    if (stocks.isNotEmpty) refreshQuotes();
  }

  int _compareStocks(Stock left, Stock right) {
    final leftQuote = quoteFor(left);
    final rightQuote = quoteFor(right);

    if (_state.sortOrder != WatchlistSortOrder.alphabetical) {
      if (leftQuote == null && rightQuote != null) return 1;
      if (leftQuote != null && rightQuote == null) return -1;
      if (leftQuote != null && rightQuote != null) {
        final comparison = switch (_state.sortOrder) {
          WatchlistSortOrder.currentPrice => rightQuote.currentPrice.compareTo(
            leftQuote.currentPrice,
          ),
          WatchlistSortOrder.changeRate => rightQuote.changeRate.compareTo(
            leftQuote.changeRate,
          ),
          WatchlistSortOrder.alphabetical => 0,
        };
        if (comparison != 0) return comparison;
      }
    }

    final nameComparison = left.name.compareTo(right.name);
    return nameComparison != 0
        ? nameComparison
        : left.symbol.compareTo(right.symbol);
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    _favoriteStore.removeListener(_syncFavorites);
    super.dispose();
  }
}
