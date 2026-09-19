import 'package:edencrew_assignment_starter/domain/models/daily_price.dart';
import 'package:edencrew_assignment_starter/domain/models/stock.dart';
import 'package:edencrew_assignment_starter/domain/models/stock_quote.dart';
import 'package:edencrew_assignment_starter/domain/repositories/stock_repository.dart';

class FakeStockRepository implements StockRepository {
  FakeStockRepository({Map<String, StockQuote>? quotes, this.quotesError})
    : quotes = quotes ?? <String, StockQuote>{};

  final Map<String, StockQuote> quotes;
  Object? quotesError;
  int quoteRequestCount = 0;
  List<String> lastRequestedSymbols = const <String>[];

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
  Future<DailyPricePage> getDailyPrices(String symbol, int page) {
    throw UnimplementedError();
  }

  @override
  Future<Stock> getStockMetadata(String symbol) {
    throw UnimplementedError();
  }

  @override
  Future<List<Stock>> searchStocks(String query) {
    throw UnimplementedError();
  }
}
