import '../../../domain/models/stock.dart';
import '../../../shared/models/load_status.dart';

class SearchViewState {
  const SearchViewState({
    required this.query,
    required this.status,
    required this.results,
  });

  const SearchViewState.initial()
    : query = '',
      status = LoadStatus.initial,
      results = const <Stock>[];

  final String query;
  final LoadStatus status;
  final List<Stock> results;

  SearchViewState copyWith({
    String? query,
    LoadStatus? status,
    List<Stock>? results,
  }) {
    return SearchViewState(
      query: query ?? this.query,
      status: status ?? this.status,
      results: results ?? this.results,
    );
  }
}
