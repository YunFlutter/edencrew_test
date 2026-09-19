class Stock {
  const Stock({
    required this.id,
    required this.symbol,
    required this.name,
    required this.market,
  });

  factory Stock.domestic({
    required String symbol,
    required String name,
    required String market,
  }) {
    if (!RegExp(r'^\d{6}$').hasMatch(symbol)) {
      throw ArgumentError.value(symbol, 'symbol', '6자리 숫자여야 합니다.');
    }
    return Stock(
      id: 'domestic:$symbol',
      symbol: symbol,
      name: name,
      market: market,
    );
  }

  final String id;
  final String symbol;
  final String name;
  final String market;
}
