import '../../../domain/models/stock.dart';
import '../../../shared/models/load_status.dart';

class WatchlistViewState {
  const WatchlistViewState({required this.status, required this.stocks});

  const WatchlistViewState.initial()
    : status = LoadStatus.initial,
      stocks = const <Stock>[];

  final LoadStatus status;
  final List<Stock> stocks;
}
