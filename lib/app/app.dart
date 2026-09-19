import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'app_dependencies.dart';
import 'app_routes.dart';

class EdencrewAssignmentApp extends StatefulWidget {
  const EdencrewAssignmentApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<EdencrewAssignmentApp> createState() => _EdencrewAssignmentAppState();
}

class _EdencrewAssignmentAppState extends State<EdencrewAssignmentApp> {
  @override
  void dispose() {
    widget.dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '이든크루 평가 과제',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.watchlist,
      onGenerateRoute: (RouteSettings settings) =>
          AppRoutes.onGenerateRoute(settings, widget.dependencies),
    );
  }
}
