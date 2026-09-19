import 'package:flutter/material.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../domain/models/stock.dart';
import '../../../domain/models/stock_quote.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../../../shared/favorites/favorite_store.dart';
import '../../../shared/models/load_status.dart';
import '../../../theme/theme.dart';
import '../view_model/watchlist_view_model.dart';
import '../view_model/watchlist_view_state.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({
    required this.favoriteStore,
    required this.stockRepository,
    super.key,
  });

  final FavoriteStore favoriteStore;
  final StockRepository stockRepository;

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late final WatchlistViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = WatchlistViewModel(
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
      bottomNavigationBar: const AppBottomNavigation(
        currentTab: AppTab.watchlist,
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (BuildContext context, Widget? child) {
            final state = _viewModel.state;
            return Column(
              children: <Widget>[
                _WatchlistHeader(
                  sortOrder: state.sortOrder,
                  isRefreshing: state.isRefreshing,
                  onSortPressed: _showSortSheet,
                  onRefreshPressed: _viewModel.refreshQuotes,
                ),
                Expanded(child: _buildContent(state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(WatchlistViewState state) {
    if (state.stocks.isEmpty) return const _EmptyWatchlist();

    if (state.status == LoadStatus.error && state.quotesBySymbol.isEmpty) {
      return _LoadError(onRetry: _viewModel.refreshQuotes);
    }

    final stocks = _viewModel.visibleStocks;
    return Column(
      children: <Widget>[
        if (state.errorMessage != null)
          _ErrorBanner(
            message: state.errorMessage!,
            onRetry: _viewModel.refreshQuotes,
          ),
        Expanded(
          child: RefreshIndicator(
            color: context.colors.accentDefault,
            backgroundColor: context.colors.surfaceRaised,
            onRefresh: _viewModel.refreshQuotes,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: stocks.length,
              itemBuilder: (BuildContext context, int index) {
                final stock = stocks[index];
                return _WatchlistRow(
                  key: ValueKey<String>(stock.id),
                  stock: stock,
                  quote: _viewModel.quoteFor(stock),
                  quoteFailed: state.failedSymbols.contains(stock.symbol),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showSortSheet() async {
    final selected = await showModalBottomSheet<WatchlistSortOrder>(
      context: context,
      backgroundColor: context.colors.surfaceOverlay,
      barrierColor: context.colors.surfaceBase.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.dimens.space4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      useSafeArea: false,
      builder: (BuildContext context) =>
          _SortBottomSheet(selectedOrder: _viewModel.state.sortOrder),
    );
    if (selected != null) _viewModel.changeSortOrder(selected);
  }
}

class _WatchlistHeader extends StatelessWidget {
  const _WatchlistHeader({
    required this.sortOrder,
    required this.isRefreshing,
    required this.onSortPressed,
    required this.onRefreshPressed,
  });

  final WatchlistSortOrder sortOrder;
  final bool isRefreshing;
  final VoidCallback onSortPressed;
  final VoidCallback onRefreshPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '관심',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 19,
                height: 22 / 19,
                letterSpacing: -0.2,
                fontWeight: AppTypography.bold,
              ),
            ),
            Row(
              children: <Widget>[
                Semantics(
                  button: true,
                  label: '정렬 기준 ${sortOrder.label}',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      context.dimens.radiusSm,
                    ),
                    onTap: onSortPressed,
                    child: SizedBox(
                      height: 28,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: context.dimens.space1,
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              sortOrder.label,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 13,
                                height: 18 / 13,
                                fontWeight: AppTypography.bold,
                              ),
                            ),
                            Icon(
                              Icons.arrow_downward_rounded,
                              color: context.colors.textSecondary,
                              size: context.dimens.iconSm,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.dimens.space4),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: '시세 새로고침',
                    onPressed: isRefreshing ? null : onRefreshPressed,
                    icon: isRefreshing
                        ? SizedBox.square(
                            dimension: context.dimens.iconSm,
                            child: CircularProgressIndicator(
                              color: context.colors.textSecondary,
                              strokeWidth: context.dimens.borderHairline * 2,
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            color: context.colors.textSecondary,
                            size: context.dimens.iconMd,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistRow extends StatelessWidget {
  const _WatchlistRow({
    required this.stock,
    required this.quote,
    required this.quoteFailed,
    super.key,
  });

  final Stock stock;
  final StockQuote? quote;
  final bool quoteFailed;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: context.dimens.rowMinHeight),
      padding: EdgeInsets.symmetric(
        horizontal: context.dimens.space4,
        vertical: context.dimens.space3,
      ),
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
            child: Column(
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
                    letterSpacing: -0.1,
                    fontWeight: AppTypography.medium,
                  ),
                ),
                SizedBox(height: context.dimens.space1 / 2),
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
          SizedBox(width: context.dimens.space3),
          if (quote != null)
            _QuoteView(quote: quote!)
          else if (quoteFailed)
            const _QuoteFailure()
          else
            const _QuoteSkeleton(),
        ],
      ),
    );
  }
}

class _QuoteView extends StatelessWidget {
  const _QuoteView({required this.quote});

  final StockQuote quote;

  @override
  Widget build(BuildContext context) {
    final changeColor = switch (quote.direction) {
      PriceChangeDirection.up => context.colors.priceUpText,
      PriceChangeDirection.down => context.colors.priceDownText,
      PriceChangeDirection.flat => context.colors.priceFlatText,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          formatPrice(quote.currentPrice),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 15,
            height: 20 / 15,
            letterSpacing: -0.1,
            fontWeight: AppTypography.medium,
          ),
        ),
        SizedBox(height: context.dimens.space1 / 2),
        Text(
          '${formatPriceChange(quote.priceChange)} '
          '(${formatChangeRate(quote.changeRate)})',
          style: TextStyle(
            color: changeColor,
            fontSize: 11,
            height: 14 / 11,
            fontWeight: AppTypography.regular,
          ),
        ),
      ],
    );
  }
}

class _QuoteSkeleton extends StatelessWidget {
  const _QuoteSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        _SkeletonBox(width: 56, height: context.dimens.space3),
        SizedBox(height: context.dimens.space2),
        _SkeletonBox(width: 68, height: context.dimens.space2),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.feedbackSkeleton,
        borderRadius: BorderRadius.circular(context.dimens.radiusSm),
      ),
    );
  }
}

class _QuoteFailure extends StatelessWidget {
  const _QuoteFailure();

  @override
  Widget build(BuildContext context) {
    return Text(
      '시세 없음',
      style: TextStyle(
        color: context.colors.feedbackWarning,
        fontSize: 11,
        height: 14 / 11,
        fontWeight: AppTypography.regular,
      ),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.star_border_rounded,
              color: context.colors.favoriteInactive,
              size: context.dimens.iconMd * 2,
            ),
            SizedBox(height: context.dimens.space3),
            Text(
              '관심 종목이 없습니다',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 19,
                height: 22 / 19,
                letterSpacing: -0.2,
                fontWeight: AppTypography.bold,
              ),
            ),
            SizedBox(height: context.dimens.space3),
            Text(
              '검색 탭에서 종목을 찾아 별 아이콘을 눌러 추가해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                height: 14 / 11,
                fontWeight: AppTypography.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surfaceRaised,
      padding: EdgeInsets.symmetric(
        horizontal: context.dimens.space4,
        vertical: context.dimens.space2,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            size: context.dimens.iconSm,
            color: context.colors.feedbackWarning,
          ),
          SizedBox(width: context.dimens.space2),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 11,
                height: 14 / 11,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('재시도')),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            color: context.colors.feedbackWarning,
            size: context.dimens.iconMd * 2,
          ),
          SizedBox(height: context.dimens.space3),
          Text(
            '시세를 불러오지 못했습니다',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 15,
              height: 20 / 15,
              fontWeight: AppTypography.medium,
            ),
          ),
          SizedBox(height: context.dimens.space2),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

class _SortBottomSheet extends StatelessWidget {
  const _SortBottomSheet({required this.selectedOrder});

  final WatchlistSortOrder selectedOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceOverlay,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.dimens.space4),
        ),
      ),
      padding: EdgeInsets.only(top: context.dimens.borderHairline),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 64,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.dimens.space6,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '정렬',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 19,
                      height: 22 / 19,
                      letterSpacing: -0.2,
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                ),
              ),
            ),
            for (final order in WatchlistSortOrder.values)
              _SortOption(
                order: order,
                selected: order == selectedOrder,
                onTap: () => Navigator.of(context).pop(order),
              ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.order,
    required this.selected,
    required this.onTap,
  });

  final WatchlistSortOrder order;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: context.dimens.rowMinHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dimens.space6),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    order.label,
                    style: TextStyle(
                      color: selected
                          ? context.colors.textPrimary
                          : context.colors.textSecondary,
                      fontSize: 15,
                      height: 20 / 15,
                      fontWeight: selected
                          ? AppTypography.medium
                          : AppTypography.regular,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_rounded,
                    size: context.dimens.iconMd,
                    color: context.colors.textPrimary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
