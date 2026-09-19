class SearchStockDto {
  const SearchStockDto({
    required this.symbol,
    required this.name,
    required this.market,
    required this.nationCode,
  });

  final String symbol;
  final String name;
  final String market;
  final String nationCode;
}
