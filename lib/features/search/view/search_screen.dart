import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../domain/models/stock.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../../../shared/favorites/favorite_store.dart';
import '../../../shared/models/load_status.dart';
import '../../../theme/theme.dart';
import '../view_model/search_view_model.dart';
import '../view_model/search_view_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    required this.favoriteStore,
    required this.stockRepository,
    super.key,
  });

  final FavoriteStore favoriteStore;
  final StockRepository stockRepository;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchViewModel _viewModel;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _viewModel = SearchViewModel(
      favoriteStore: widget.favoriteStore,
      stockRepository: widget.stockRepository,
    );
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppBottomNavigation(currentTab: AppTab.search),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (BuildContext context, Widget? child) {
            final state = _viewModel.state;
            return Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _SearchBar(
                      controller: _controller,
                      focusNode: _focusNode,
                      query: state.query,
                      onChanged: _viewModel.changeQuery,
                      onSubmitted: (_) => _viewModel.search(),
                      onClear: _clearQuery,
                    ),
                    Expanded(child: _buildContent(state)),
                  ],
                ),
                if (state.favoriteFeedback case final feedback?)
                  Positioned(
                    left: context.dimens.space4,
                    right: context.dimens.space4,
                    bottom: context.dimens.space3,
                    child: _FavoriteToast(feedback: feedback),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(SearchViewState state) {
    return switch (state.status) {
      LoadStatus.initial => const _SearchGuide(),
      LoadStatus.loading => Center(
        child: SizedBox.square(
          dimension: context.dimens.iconMd,
          child: CircularProgressIndicator(
            color: context.colors.accentDefault,
            strokeWidth: context.dimens.borderHairline * 2,
          ),
        ),
      ),
      LoadStatus.success => ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: state.results.length,
        itemBuilder: (BuildContext context, int index) {
          final stock = state.results[index];
          return _SearchResultRow(
            key: ValueKey<String>(stock.id),
            stock: stock,
            query: state.query.trim(),
            isFavorite: _viewModel.isFavorite(stock.id),
            onFavoritePressed: () => _viewModel.toggleFavorite(stock),
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.stockDetail, arguments: stock),
          );
        },
      ),
      LoadStatus.empty => _NoSearchResults(query: state.query.trim()),
      LoadStatus.error => _SearchError(
        message: state.errorMessage ?? '검색 결과를 불러오지 못했습니다.',
        onRetry: _viewModel.search,
      ),
    };
  }

  void _clearQuery() {
    _controller.clear();
    _viewModel.changeQuery('');
    _focusNode.requestFocus();
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.dimens.space4,
        top: context.dimens.space2,
        right: context.dimens.space4,
        bottom: context.dimens.space3,
      ),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          cursorColor: context.colors.accentDefault,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 13,
            height: 18 / 13,
            fontWeight: AppTypography.regular,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.colors.surfaceSunken,
            hintText: '종목명 또는 종목코드',
            hintStyle: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 13,
              height: 18 / 13,
              fontWeight: AppTypography.regular,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.dimens.space3,
              vertical: 10,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: context.dimens.iconSm,
              color: context.colors.textTertiary,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 40,
            ),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: '검색어 지우기',
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: onClear,
                    icon: Icon(
                      Icons.close_rounded,
                      size: context.dimens.iconSm,
                      color: context.colors.textTertiary,
                    ),
                  ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 40,
            ),
            enabledBorder: _border(context),
            focusedBorder: _border(context),
            border: _border(context),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.dimens.radiusMd),
      borderSide: BorderSide(
        color: context.colors.borderStrong,
        width: context.dimens.borderHairline,
      ),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({
    required this.stock,
    required this.query,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onTap,
    super.key,
  });

  final Stock stock;
  final String query;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${stock.name}, ${stock.symbol}, ${stock.market}',
      child: InkWell(
        onTap: onTap,
        child: Container(
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
                    _HighlightedStockName(name: stock.name, query: query),
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
              Semantics(
                button: true,
                selected: isFavorite,
                label: isFavorite ? '관심 해제' : '관심 등록',
                child: SizedBox.square(
                  dimension: 24,
                  child: IconButton(
                    tooltip: isFavorite ? '관심 해제' : '관심 등록',
                    padding: EdgeInsets.zero,
                    onPressed: onFavoritePressed,
                    icon: Icon(
                      isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 18,
                      color: isFavorite
                          ? context.colors.favoriteActive
                          : context.colors.favoriteInactive,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightedStockName extends StatelessWidget {
  const _HighlightedStockName({required this.name, required this.query});

  final String name;
  final String query;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: context.colors.textPrimary,
      fontSize: 15,
      height: 20 / 15,
      letterSpacing: -0.1,
      fontWeight: AppTypography.medium,
    );
    return Text.rich(
      TextSpan(style: baseStyle, children: _highlightedSpans(context)),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<TextSpan> _highlightedSpans(BuildContext context) {
    if (query.isEmpty) return <TextSpan>[TextSpan(text: name)];
    final lowerName = name.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    var cursor = 0;
    while (cursor < name.length) {
      final matchIndex = lowerName.indexOf(lowerQuery, cursor);
      if (matchIndex < 0) {
        spans.add(TextSpan(text: name.substring(cursor)));
        break;
      }
      if (matchIndex > cursor) {
        spans.add(TextSpan(text: name.substring(cursor, matchIndex)));
      }
      final matchEnd = matchIndex + query.length;
      spans.add(
        TextSpan(
          text: name.substring(matchIndex, matchEnd),
          style: TextStyle(color: context.colors.searchHighlight),
        ),
      );
      cursor = matchEnd;
    }
    return spans;
  }
}

class _SearchGuide extends StatelessWidget {
  const _SearchGuide();

  @override
  Widget build(BuildContext context) {
    return const _SearchEmptyState(
      icon: Icons.search_rounded,
      title: '종목을 검색해 보세요',
      description: '종목명 또는 종목코드 6자리로 검색하실 수 있습니다.',
      descriptionWidth: 135,
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return _SearchEmptyState(
      icon: Icons.search_off_rounded,
      title: '검색 결과가 없습니다',
      description: "'$query'와 일치하는 검색 결과를 찾지 못했습니다.",
      descriptionWidth: 240,
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    required this.descriptionWidth,
  });

  final IconData icon;
  final String title;
  final String description;
  final double descriptionWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: context.colors.favoriteInactive,
              size: context.dimens.iconMd * 2,
            ),
            SizedBox(height: context.dimens.space3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 19,
                height: 22 / 19,
                letterSpacing: -0.2,
                fontWeight: AppTypography.bold,
              ),
            ),
            SizedBox(height: context.dimens.space3),
            SizedBox(
              width: descriptionWidth,
              child: Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.textTertiary,
                  fontSize: 11,
                  height: 14 / 11,
                  fontWeight: AppTypography.regular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.message, required this.onRetry});

  final String message;
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
            message,
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

class _FavoriteToast extends StatelessWidget {
  const _FavoriteToast({required this.feedback});

  final SearchFavoriteFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final isAdded = feedback == SearchFavoriteFeedback.added;
    return Container(
      height: 46,
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      decoration: BoxDecoration(
        color: context.colors.surfaceOverlay,
        borderRadius: BorderRadius.circular(context.dimens.radiusLg),
        border: Border.all(
          color: context.colors.borderSubtle,
          width: context.dimens.borderHairline,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.colors.surfaceBase.withValues(alpha: 0.55),
            offset: Offset(0, context.dimens.space2),
            blurRadius: context.dimens.space6,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isAdded ? Icons.star_rounded : Icons.star_border_rounded,
            size: 18,
            color: isAdded
                ? context.colors.favoriteActive
                : context.colors.favoriteInactive,
          ),
          SizedBox(width: context.dimens.space2),
          Expanded(
            child: Text(
              isAdded ? '관심이 등록되었습니다' : '관심이 해제되었습니다',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 13,
                height: 18 / 13,
                fontWeight: AppTypography.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
