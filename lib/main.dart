import 'dart:async';
import 'package:coment_app/src/core/utils/refined_logger.dart';
import 'package:coment_app/src/feature/app/logic/app_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gcaptcha_v3/recaptca_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

late final WebViewController controller;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

// ✅ Инициализация controller
  controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color.fromARGB(0, 0, 0, 0));

  final key = dotenv.get('RECAPTCHA_SITE_KEY');
  RecaptchaHandler.instance.setupSiteKey(dataSiteKey: key);

  runZonedGuarded(
    () => const AppRunner().initializeAndRun(),
    logger.logZoneError,
  );
}
