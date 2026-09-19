class StockMetadataDto {
  const StockMetadataDto({
    required this.symbol,
    required this.name,
    required this.market,
  });

  final String symbol;
  final String name;
  final String market;
}
