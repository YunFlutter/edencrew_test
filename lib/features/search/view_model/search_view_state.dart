import '../../../domain/models/stock.dart';
import '../../../shared/models/load_status.dart';

enum SearchFavoriteFeedback { added, removed }

class SearchViewState {
  const SearchViewState({
    required this.query,
    required this.status,
    required this.results,
    this.errorMessage,
    this.favoriteFeedback,
  });

  const SearchViewState.initial()
    : query = '',
      status = LoadStatus.initial,
      results = const <Stock>[],
      errorMessage = null,
      favoriteFeedback = null;

  final String query;
  final LoadStatus status;
  final List<Stock> results;
  final String? errorMessage;
  final SearchFavoriteFeedback? favoriteFeedback;

  SearchViewState copyWith({
    String? query,
    LoadStatus? status,
    List<Stock>? results,
    String? errorMessage,
    bool clearErrorMessage = false,
    SearchFavoriteFeedback? favoriteFeedback,
    bool clearFavoriteFeedback = false,
  }) {
    return SearchViewState(
      query: query ?? this.query,
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      favoriteFeedback: clearFavoriteFeedback
          ? null
          : favoriteFeedback ?? this.favoriteFeedback,
    );
  }
}
