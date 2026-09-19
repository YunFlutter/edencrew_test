class SearchStockDto {
  const SearchStockDto({
    required this.symbol,
    required this.name,
    required this.market,
    required this.nationCode,
    required this.category,
  });

  final String symbol;
  final String name;
  final String market;
  final String nationCode;
  final String category;
}
