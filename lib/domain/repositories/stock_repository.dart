import '../models/daily_price.dart';
import '../models/stock.dart';
import '../models/stock_quote.dart';

abstract interface class StockRepository {
  Future<List<Stock>> searchStocks(String query);

  Future<Map<String, StockQuote>> getQuotes(List<String> symbols);

  Future<Stock> getStockMetadata(String symbol);

  Future<DailyPricePage> getDailyPrices(String symbol, int page);
}
