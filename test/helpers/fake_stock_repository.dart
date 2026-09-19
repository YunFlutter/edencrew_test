import 'package:edencrew_assignment_starter/domain/models/daily_price.dart';
import 'package:edencrew_assignment_starter/domain/models/stock.dart';
import 'package:edencrew_assignment_starter/domain/models/stock_quote.dart';
import 'package:edencrew_assignment_starter/domain/repositories/stock_repository.dart';

class FakeStockRepository implements StockRepository {
  FakeStockRepository({
    Map<String, StockQuote>? quotes,
    List<Stock>? searchResults,
    this.quotesError,
    this.searchError,
    Map<int, DailyPricePage>? dailyPricePages,
    this.dailyPricesError,
  }) : quotes = quotes ?? <String, StockQuote>{},
       searchResults = searchResults ?? <Stock>[],
       dailyPricePages = dailyPricePages ?? <int, DailyPricePage>{};

  final Map<String, StockQuote> quotes;
  final List<Stock> searchResults;
  Object? quotesError;
  Object? searchError;
  final Map<int, DailyPricePage> dailyPricePages;
  Object? dailyPricesError;
  int quoteRequestCount = 0;
  List<String> lastRequestedSymbols = const <String>[];
  int searchRequestCount = 0;
  String? lastSearchQuery;
  final List<int> requestedDailyPricePages = <int>[];

  @override
  Future<Map<String, StockQuote>> getQuotes(List<String> symbols) async {
    quoteRequestCount++;
    lastRequestedSymbols = List<String>.unmodifiable(symbols);
    if (quotesError case final error?) throw error;

    final result = <String, StockQuote>{};
    for (final symbol in symbols) {
      final quote = quotes[symbol];
      if (quote != null) result[symbol] = quote;
    }
    return result;
  }

  @override
  Future<DailyPricePage> getDailyPrices(String symbol, int page) async {
    requestedDailyPricePages.add(page);
    if (dailyPricesError case final error?) throw error;
    return dailyPricePages[page] ??
        const DailyPricePage(items: <DailyPrice>[], lastPage: 1);
  }

  @override
  Future<Stock> getStockMetadata(String symbol) {
    throw UnimplementedError();
  }

  @override
  Future<List<Stock>> searchStocks(String query) async {
    searchRequestCount++;
    lastSearchQuery = query;
    if (searchError case final error?) throw error;
    return List<Stock>.unmodifiable(searchResults);
  }
}
