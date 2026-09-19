import 'package:flutter/material.dart';

import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../shared/favorites/favorite_store.dart';
import '../../../theme/theme.dart';
import '../view_model/search_view_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({required this.favoriteStore, super.key});

  final FavoriteStore favoriteStore;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchViewModel _viewModel;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _viewModel = SearchViewModel(favoriteStore: widget.favoriteStore);
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('종목 검색')),
      bottomNavigationBar: const AppBottomNavigation(currentTab: AppTab.search),
      body: Padding(
        padding: EdgeInsets.all(context.dimens.space4),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              onChanged: _viewModel.changeQuery,
              decoration: InputDecoration(
                hintText: '종목명 또는 종목코드',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    _controller.clear();
                    _viewModel.changeQuery('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _viewModel,
                builder: (BuildContext context, Widget? child) {
                  final String query = _viewModel.state.query;
                  return Center(
                    child: Text(
                      query.isEmpty
                          ? '종목을 검색해 보세요'
                          : "'$query'와 일치하는 검색 결과를 찾지 못했습니다.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
