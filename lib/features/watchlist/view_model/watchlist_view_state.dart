import '../../../domain/models/stock.dart';
import '../../../domain/models/stock_quote.dart';
import '../../../shared/models/load_status.dart';

enum WatchlistSortOrder {
  currentPrice('현재가순'),
  changeRate('등락률순'),
  alphabetical('가나다순');

  const WatchlistSortOrder(this.label);

  final String label;
}

class WatchlistViewState {
  const WatchlistViewState({
    required this.status,
    required this.stocks,
    required this.quotesBySymbol,
    required this.failedSymbols,
    required this.sortOrder,
    required this.isRefreshing,
    this.errorMessage,
  });

  const WatchlistViewState.initial()
    : status = LoadStatus.initial,
      stocks = const <Stock>[],
      quotesBySymbol = const <String, StockQuote>{},
      failedSymbols = const <String>{},
      sortOrder = WatchlistSortOrder.alphabetical,
      isRefreshing = false,
      errorMessage = null;

  final LoadStatus status;
  final List<Stock> stocks;
  final Map<String, StockQuote> quotesBySymbol;
  final Set<String> failedSymbols;
  final WatchlistSortOrder sortOrder;
  final bool isRefreshing;
  final String? errorMessage;

  WatchlistViewState copyWith({
    LoadStatus? status,
    List<Stock>? stocks,
    Map<String, StockQuote>? quotesBySymbol,
    Set<String>? failedSymbols,
    WatchlistSortOrder? sortOrder,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WatchlistViewState(
      status: status ?? this.status,
      stocks: stocks ?? this.stocks,
      quotesBySymbol: quotesBySymbol ?? this.quotesBySymbol,
      failedSymbols: failedSymbols ?? this.failedSymbols,
      sortOrder: sortOrder ?? this.sortOrder,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
