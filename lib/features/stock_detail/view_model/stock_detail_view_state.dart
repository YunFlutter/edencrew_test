import '../../../domain/models/stock.dart';
import '../../../shared/models/load_status.dart';

enum StockPeriod { oneMonth, threeMonths, sixMonths, oneYear }

class StockDetailViewState {
  const StockDetailViewState({
    required this.stock,
    required this.status,
    required this.period,
    required this.isFavorite,
  });

  final Stock stock;
  final LoadStatus status;
  final StockPeriod period;
  final bool isFavorite;

  StockDetailViewState copyWith({
    LoadStatus? status,
    StockPeriod? period,
    bool? isFavorite,
  }) {
    return StockDetailViewState(
      stock: stock,
      status: status ?? this.status,
      period: period ?? this.period,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
