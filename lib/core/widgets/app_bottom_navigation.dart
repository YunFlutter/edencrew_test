import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../theme/theme.dart';

enum AppTab { watchlist, search }

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({required this.currentTab, super.key});

  final AppTab currentTab;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        border: Border(
          top: BorderSide(
            color: context.colors.borderSubtle,
            width: context.dimens.borderHairline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height:
              context.dimens.tabBarHeight +
              context.dimens.space2 -
              context.dimens.borderHairline,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: context.dimens.space2),
            child: Row(
              children: <Widget>[
                _NavigationItem(
                  label: '관심',
                  icon: Icons.star_border_rounded,
                  selectedIcon: Icons.star_rounded,
                  isSelected: currentTab == AppTab.watchlist,
                  onTap: () => _navigate(context, AppTab.watchlist),
                ),
                _NavigationItem(
                  label: '검색',
                  icon: Icons.search_rounded,
                  selectedIcon: Icons.search_rounded,
                  isSelected: currentTab == AppTab.search,
                  onTap: () => _navigate(context, AppTab.search),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, AppTab destination) {
    if (destination == currentTab) return;
    Navigator.of(context).pushReplacementNamed(
      destination == AppTab.watchlist ? AppRoutes.watchlist : AppRoutes.search,
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? context.colors.navActive
        : context.colors.navInactive;
    return Expanded(
      child: Semantics(
        selected: isSelected,
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                isSelected ? selectedIcon : icon,
                size: context.dimens.iconMd,
                color: color,
              ),
              SizedBox(height: context.dimens.space1),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  height: 14 / 11,
                  fontWeight: AppTypography.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
