class DailyPrice {
  const DailyPrice({
    required this.localDate,
    required this.closePrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.accumulatedTradingVolume,
  });

  final String localDate;
  final int closePrice;
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int accumulatedTradingVolume;
}

class DailyPricePage {
  const DailyPricePage({required this.items, required this.lastPage});

  final List<DailyPrice> items;
  final int lastPage;
}
