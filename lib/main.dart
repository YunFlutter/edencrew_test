import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';

void main() {
  final AppDependencies dependencies = AppDependencies.bootstrap();
  runApp(EdencrewAssignmentApp(dependencies: dependencies));
}
