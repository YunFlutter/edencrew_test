import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../domain/models/daily_price.dart';
import '../../../domain/models/stock.dart';
import '../../../domain/models/stock_quote.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../../../shared/favorites/favorite_store.dart';
import '../../../shared/models/load_status.dart';
import '../../../theme/theme.dart';
import '../view_model/stock_detail_view_model.dart';
import '../view_model/stock_detail_view_state.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({
    required this.stock,
    required this.favoriteStore,
    required this.stockRepository,
    super.key,
  });

  final Stock stock;
  final FavoriteStore favoriteStore;
  final StockRepository stockRepository;

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late final StockDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = StockDetailViewModel(
      stock: widget.stock,
      favoriteStore: widget.favoriteStore,
      stockRepository: widget.stockRepository,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (BuildContext context, Widget? child) {
            final state = _viewModel.state;
            return Column(
              children: <Widget>[
                _DetailHeader(
                  stock: state.stock,
                  isFavorite: state.isFavorite,
                  onBack: () => Navigator.of(context).maybePop(),
                  onFavoritePressed: _viewModel.toggleFavorite,
                ),
                Expanded(child: _buildContent(state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(StockDetailViewState state) {
    if (state.status == LoadStatus.loading && state.quote == null) {
      return const _DetailLoading();
    }
    if (state.status == LoadStatus.error && state.quote == null) {
      return _DetailError(
        message: state.errorMessage ?? '종목 정보를 불러오지 못했습니다.',
        onRetry: _viewModel.load,
      );
    }

    final quote = state.quote;
    if (quote == null) return const SizedBox.shrink();
    return RefreshIndicator(
      color: context.colors.accentDefault,
      backgroundColor: context.colors.surfaceRaised,
      onRefresh: _viewModel.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: context.dimens.space6),
        children: <Widget>[
          _CurrentPrice(quote: quote),
          _PeriodTabs(
            selectedPeriod: state.period,
            isLoading: state.isLoadingPeriod,
            onSelected: _viewModel.changePeriod,
          ),
          _CandlestickChart(prices: state.dailyPrices),
          _QuoteSummary(quote: quote),
          if (state.errorMessage case final message?)
            _InlineError(message: message, onRetry: _viewModel.load),
          _DailyPriceTable(prices: state.dailyPrices),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.stock,
    required this.isFavorite,
    required this.onBack,
    required this.onFavoritePressed,
  });

  final Stock stock;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.dimens.tabBarHeight,
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.borderSubtle,
            width: context.dimens.borderHairline,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox.square(
            dimension: 40,
            child: IconButton(
              tooltip: '뒤로',
              padding: EdgeInsets.zero,
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: context.dimens.iconSm,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: context.dimens.space1),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  stock.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 15,
                    height: 20 / 15,
                    fontWeight: AppTypography.bold,
                  ),
                ),
                Text(
                  '${stock.symbol} · ${stock.market}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 11,
                    height: 14 / 11,
                    fontWeight: AppTypography.regular,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            selected: isFavorite,
            label: isFavorite ? '관심 해제' : '관심 등록',
            child: SizedBox.square(
              dimension: 40,
              child: IconButton(
                tooltip: isFavorite ? '관심 해제' : '관심 등록',
                padding: EdgeInsets.zero,
                onPressed: onFavoritePressed,
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  size: context.dimens.iconMd,
                  color: isFavorite
                      ? context.colors.favoriteActive
                      : context.colors.favoriteInactive,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentPrice extends StatelessWidget {
  const _CurrentPrice({required this.quote});

  final StockQuote quote;

  @override
  Widget build(BuildContext context) {
    final changeColor = switch (quote.direction) {
      PriceChangeDirection.up => context.colors.priceUpText,
      PriceChangeDirection.down => context.colors.priceDownText,
      PriceChangeDirection.flat => context.colors.priceFlatText,
    };
    final marker = switch (quote.direction) {
      PriceChangeDirection.up => '▲',
      PriceChangeDirection.down => '▼',
      PriceChangeDirection.flat => '—',
    };
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.dimens.space4,
        context.dimens.space4,
        context.dimens.space4,
        context.dimens.space3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: Text(
              formatPrice(quote.currentPrice),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 30,
                height: 36 / 30,
                letterSpacing: -0.5,
                fontWeight: AppTypography.bold,
              ),
            ),
          ),
          SizedBox(width: context.dimens.space2),
          Padding(
            padding: EdgeInsets.only(bottom: context.dimens.space1),
            child: Text(
              '$marker ${formatNumber(quote.priceChange.abs())} '
              '(${formatChangeRate(quote.changeRate)})',
              style: TextStyle(
                color: changeColor,
                fontSize: 13,
                height: 18 / 13,
                fontWeight: AppTypography.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({
    required this.selectedPeriod,
    required this.isLoading,
    required this.onSelected,
  });

  final StockPeriod selectedPeriod;
  final bool isLoading;
  final ValueChanged<StockPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              for (final period in StockPeriod.values)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: selectedPeriod == period,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        context.dimens.radiusMd,
                      ),
                      onTap: isLoading ? null : () => onSelected(period),
                      child: Container(
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selectedPeriod == period
                              ? context.colors.accentBg
                              : null,
                          borderRadius: BorderRadius.circular(
                            context.dimens.radiusMd,
                          ),
                        ),
                        child: Text(
                          period.label,
                          style: TextStyle(
                            color: selectedPeriod == period
                                ? context.colors.accentDefault
                                : context.colors.textSecondary,
                            fontSize: 13,
                            height: 18 / 13,
                            fontWeight: selectedPeriod == period
                                ? AppTypography.bold
                                : AppTypography.regular,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: context.dimens.space1,
            child: isLoading
                ? LinearProgressIndicator(
                    color: context.colors.accentDefault,
                    backgroundColor: context.colors.surfaceBase,
                    minHeight: context.dimens.borderHairline,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _CandlestickChart extends StatelessWidget {
  const _CandlestickChart({required this.prices});

  final List<DailyPrice> prices;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.dimens.space4,
          context.dimens.space3,
          context.dimens.space4,
          context.dimens.space4,
        ),
        child: prices.isEmpty
            ? Center(
                child: Text(
                  '표시할 차트 데이터가 없습니다.',
                  style: TextStyle(
                    color: context.colors.textTertiary,
                    fontSize: 12,
                    fontWeight: AppTypography.regular,
                  ),
                ),
              )
            : CustomPaint(
                key: const ValueKey<String>('stock-detail-chart'),
                painter: _CandlestickPainter(
                  prices: prices,
                  upColor: context.colors.chartLineUp,
                  downColor: context.colors.chartLineDown,
                  flatColor: context.colors.chartLineFlat,
                  baselineColor: context.colors.chartBaseline,
                ),
                size: Size.infinite,
              ),
      ),
    );
  }
}

class _QuoteSummary extends StatelessWidget {
  const _QuoteSummary({required this.quote});

  final StockQuote quote;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      ('시가', formatPrice(quote.openPrice)),
      ('고가', formatPrice(quote.highPrice)),
      ('저가', formatPrice(quote.lowPrice)),
      ('거래량', formatVolume(quote.accumulatedTradingVolume)),
      ('시가총액', formatMarketCapitalization(quote.marketCapitalization)),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.dimens.space4,
        0,
        context.dimens.space4,
        context.dimens.space5,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final spacing = context.dimens.space2;
          final thirdWidth = (constraints.maxWidth - spacing * 2) / 3;
          final halfWidth = (constraints.maxWidth - spacing) / 2;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: <Widget>[
              for (var index = 0; index < items.length; index++)
                SizedBox(
                  width: index < 3 ? thirdWidth : halfWidth,
                  child: _SummaryCard(
                    label: items[index].$1,
                    value: items[index].$2,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: EdgeInsets.symmetric(
        horizontal: context.dimens.space3,
        vertical: context.dimens.space2,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 11,
              height: 14 / 11,
              fontWeight: AppTypography.regular,
            ),
          ),
          SizedBox(height: context.dimens.space1 / 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 15,
              height: 20 / 15,
              fontWeight: AppTypography.medium,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyPriceTable extends StatelessWidget {
  const _DailyPriceTable({required this.prices});

  final List<DailyPrice> prices;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
          child: Text(
            '일별 시세',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 15,
              height: 20 / 15,
              fontWeight: AppTypography.bold,
            ),
          ),
        ),
        SizedBox(height: context.dimens.space3),
        const _DailyPriceHeader(),
        if (prices.isEmpty)
          Padding(
            padding: EdgeInsets.all(context.dimens.space6),
            child: Center(
              child: Text(
                '일별 시세가 없습니다.',
                style: TextStyle(
                  color: context.colors.textTertiary,
                  fontSize: 12,
                  fontWeight: AppTypography.regular,
                ),
              ),
            ),
          )
        else
          for (var index = 0; index < prices.length; index++)
            _DailyPriceRow(
              price: prices[index],
              change: index + 1 < prices.length
                  ? prices[index].closePrice - prices[index + 1].closePrice
                  : 0,
            ),
      ],
    );
  }
}

class _DailyPriceHeader extends StatelessWidget {
  const _DailyPriceHeader();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: context.colors.textTertiary,
      fontSize: 11,
      height: 14 / 11,
      fontWeight: AppTypography.regular,
    );
    return Container(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.borderSubtle,
            width: context.dimens.borderHairline,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(flex: 18, child: Text('날짜', style: style)),
          Expanded(
            flex: 27,
            child: Text('종가', textAlign: TextAlign.right, style: style),
          ),
          Expanded(
            flex: 22,
            child: Text('등락', textAlign: TextAlign.right, style: style),
          ),
          Expanded(
            flex: 33,
            child: Text('거래량', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

class _DailyPriceRow extends StatelessWidget {
  const _DailyPriceRow({required this.price, required this.change});

  final DailyPrice price;
  final int change;

  @override
  Widget build(BuildContext context) {
    final changeColor = change > 0
        ? context.colors.priceUpText
        : change < 0
        ? context.colors.priceDownText
        : context.colors.priceFlatText;
    final baseStyle = TextStyle(
      color: context.colors.textSecondary,
      fontSize: 11,
      height: 14 / 11,
      fontWeight: AppTypography.regular,
    );
    return Container(
      height: 36,
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.borderSubtle,
            width: context.dimens.borderHairline,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 18,
            child: Text(formatMonthDay(price.localDate), style: baseStyle),
          ),
          Expanded(
            flex: 27,
            child: Text(
              formatPrice(price.closePrice),
              textAlign: TextAlign.right,
              style: baseStyle.copyWith(color: context.colors.textPrimary),
            ),
          ),
          Expanded(
            flex: 22,
            child: Text(
              formatPriceChange(change),
              textAlign: TextAlign.right,
              style: baseStyle.copyWith(color: changeColor),
            ),
          ),
          Expanded(
            flex: 33,
            child: Text(
              formatNumber(price.accumulatedTradingVolume),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: baseStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        context.dimens.space4,
        0,
        context.dimens.space4,
        context.dimens.space4,
      ),
      padding: EdgeInsets.all(context.dimens.space3),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: context.colors.feedbackWarning,
                fontSize: 12,
                fontWeight: AppTypography.regular,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              '재시도',
              style: TextStyle(color: context.colors.accentDefault),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dimens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _Skeleton(width: 150, height: 36),
          SizedBox(height: context.dimens.space5),
          const _Skeleton(width: double.infinity, height: 36),
          SizedBox(height: context.dimens.space4),
          const _Skeleton(width: double.infinity, height: 174),
          SizedBox(height: context.dimens.space4),
          const _Skeleton(width: double.infinity, height: 124),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.feedbackSkeleton,
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dimens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              color: context.colors.feedbackWarning,
              size: context.dimens.iconMd,
            ),
            SizedBox(height: context.dimens.space3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
                height: 18 / 13,
                fontWeight: AppTypography.regular,
              ),
            ),
            SizedBox(height: context.dimens.space3),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  _CandlestickPainter({
    required this.prices,
    required this.upColor,
    required this.downColor,
    required this.flatColor,
    required this.baselineColor,
  });

  final List<DailyPrice> prices;
  final Color upColor;
  final Color downColor;
  final Color flatColor;
  final Color baselineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final candles = _aggregate(prices.reversed.toList(growable: false));
    if (candles.isEmpty || size.isEmpty) return;

    final highest = candles.map((candle) => candle.high).reduce(math.max);
    final lowest = candles.map((candle) => candle.low).reduce(math.min);
    final range = math.max(1, highest - lowest);
    final slotWidth = size.width / candles.length;
    final bodyWidth = math.max(1.5, math.min(6.0, slotWidth * 0.58));
    final wickPaint = Paint()..strokeWidth = 1;
    final bodyPaint = Paint();
    double yFor(int price) =>
        size.height - ((price - lowest) / range * size.height);

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = baselineColor
        ..strokeWidth = 1,
    );
    for (var index = 0; index < candles.length; index++) {
      final candle = candles[index];
      final color = candle.close > candle.open
          ? upColor
          : candle.close < candle.open
          ? downColor
          : flatColor;
      final centerX = slotWidth * index + slotWidth / 2;
      wickPaint.color = color;
      bodyPaint.color = color;
      canvas.drawLine(
        Offset(centerX, yFor(candle.high)),
        Offset(centerX, yFor(candle.low)),
        wickPaint,
      );
      final openY = yFor(candle.open);
      final closeY = yFor(candle.close);
      canvas.drawRect(
        Rect.fromLTWH(
          centerX - bodyWidth / 2,
          math.min(openY, closeY),
          bodyWidth,
          math.max(1.5, (openY - closeY).abs()),
        ),
        bodyPaint,
      );
    }
  }

  List<_Candle> _aggregate(List<DailyPrice> chronological) {
    const maxCandles = 72;
    if (chronological.length <= maxCandles) {
      return chronological
          .map(
            (price) => _Candle(
              open: price.openPrice,
              close: price.closePrice,
              high: price.highPrice,
              low: price.lowPrice,
            ),
          )
          .toList(growable: false);
    }

    final bucketSize = (chronological.length / maxCandles).ceil();
    final candles = <_Candle>[];
    for (var start = 0; start < chronological.length; start += bucketSize) {
      final end = math.min(start + bucketSize, chronological.length);
      final bucket = chronological.sublist(start, end);
      candles.add(
        _Candle(
          open: bucket.first.openPrice,
          close: bucket.last.closePrice,
          high: bucket.map((price) => price.highPrice).reduce(math.max),
          low: bucket.map((price) => price.lowPrice).reduce(math.min),
        ),
      );
    }
    return candles;
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) {
    return oldDelegate.prices != prices ||
        oldDelegate.upColor != upColor ||
        oldDelegate.downColor != downColor ||
        oldDelegate.flatColor != flatColor ||
        oldDelegate.baselineColor != baselineColor;
  }
}

class _Candle {
  const _Candle({
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  });

  final int open;
  final int close;
  final int high;
  final int low;
}
