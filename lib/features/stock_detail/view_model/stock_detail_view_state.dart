import '../../../domain/models/stock.dart';
import '../../../domain/models/daily_price.dart';
import '../../../domain/models/stock_quote.dart';
import '../../../shared/models/load_status.dart';

enum StockPeriod { oneMonth, threeMonths, sixMonths, oneYear }

extension StockPeriodInfo on StockPeriod {
  String get label => switch (this) {
    StockPeriod.oneMonth => '1개월',
    StockPeriod.threeMonths => '3개월',
    StockPeriod.sixMonths => '6개월',
    StockPeriod.oneYear => '1년',
  };

  int get pageCount => switch (this) {
    StockPeriod.oneMonth => 2,
    StockPeriod.threeMonths => 6,
    StockPeriod.sixMonths => 12,
    StockPeriod.oneYear => 25,
  };

  int get tradingDayCount => switch (this) {
    StockPeriod.oneMonth => 20,
    StockPeriod.threeMonths => 60,
    StockPeriod.sixMonths => 120,
    StockPeriod.oneYear => 245,
  };
}

class StockDetailViewState {
  const StockDetailViewState({
    required this.stock,
    required this.status,
    required this.period,
    required this.isFavorite,
    this.quote,
    this.dailyPrices = const <DailyPrice>[],
    this.isLoadingPeriod = false,
    this.errorMessage,
  });

  final Stock stock;
  final LoadStatus status;
  final StockPeriod period;
  final bool isFavorite;
  final StockQuote? quote;
  final List<DailyPrice> dailyPrices;
  final bool isLoadingPeriod;
  final String? errorMessage;

  StockDetailViewState copyWith({
    LoadStatus? status,
    StockPeriod? period,
    bool? isFavorite,
    StockQuote? quote,
    List<DailyPrice>? dailyPrices,
    bool? isLoadingPeriod,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return StockDetailViewState(
      stock: stock,
      status: status ?? this.status,
      period: period ?? this.period,
      isFavorite: isFavorite ?? this.isFavorite,
      quote: quote ?? this.quote,
      dailyPrices: dailyPrices ?? this.dailyPrices,
      isLoadingPeriod: isLoadingPeriod ?? this.isLoadingPeriod,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
