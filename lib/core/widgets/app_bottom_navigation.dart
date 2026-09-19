import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../theme/theme.dart';

enum AppTab { watchlist, search }

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({required this.currentTab, super.key});

  final AppTab currentTab;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.dimens.tabBarHeight,
      child: NavigationBar(
        selectedIndex: currentTab.index,
        onDestinationSelected: (int index) {
          final AppTab destination = AppTab.values[index];
          if (destination == currentTab) return;
          Navigator.of(context).pushReplacementNamed(
            destination == AppTab.watchlist
                ? AppRoutes.watchlist
                : AppRoutes.search,
          );
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.star_border_rounded),
            selectedIcon: Icon(Icons.star_rounded),
            label: '관심',
          ),
          NavigationDestination(icon: Icon(Icons.search_rounded), label: '검색'),
        ],
      ),
    );
  }
}
