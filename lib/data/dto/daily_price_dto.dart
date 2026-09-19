class DailyPriceDto {
  const DailyPriceDto({
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

class DailyPricePageDto {
  const DailyPricePageDto({required this.items, required this.lastPage});

  final List<DailyPriceDto> items;
  final int lastPage;
}
