enum PriceChangeDirection { up, down, flat }

class StockQuote {
  const StockQuote({
    required this.symbol,
    required this.currentPrice,
    required this.previousClose,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.accumulatedTradingVolume,
    required this.countOfListedStock,
  });

  final String symbol;
  final int currentPrice;
  final int previousClose;
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int accumulatedTradingVolume;
  final int countOfListedStock;

  int get priceChange => currentPrice - previousClose;

  PriceChangeDirection get direction => switch (priceChange) {
    > 0 => PriceChangeDirection.up,
    < 0 => PriceChangeDirection.down,
    _ => PriceChangeDirection.flat,
  };

  double get changeRate =>
      previousClose == 0 ? 0 : priceChange / previousClose * 100;

  int get marketCapitalization => currentPrice * countOfListedStock;
}
