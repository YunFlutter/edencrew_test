import 'daily_price.dart';
import 'stock.dart';
import 'stock_quote.dart';

class StockDetail {
  const StockDetail({
    required this.stock,
    required this.quote,
    required this.dailyPrices,
  });

  final Stock stock;
  final StockQuote quote;
  final List<DailyPrice> dailyPrices;
}
