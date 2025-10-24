import 'dart:async';
import 'package:coment_app/src/core/utils/refined_logger.dart';
import 'package:coment_app/src/feature/app/logic/app_runner.dart';

void main() => runZonedGuarded(
      () => const AppRunner().initializeAndRun(),
      logger.logZoneError,
    );


