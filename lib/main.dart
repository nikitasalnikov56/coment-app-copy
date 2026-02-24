import 'dart:async';
import 'package:coment_app/src/core/utils/refined_logger.dart';
import 'package:coment_app/src/feature/app/logic/app_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gcaptcha_v3/recaptca_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

late final WebViewController controller;

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  final supabaseKey = dotenv.get('ANON_KEY');

  final key = dotenv.get('RECAPTCHA_SITE_KEY');

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Supabase.initialize(
        url: 'https://djauryivkhshlpvnbiax.supabase.co',
        anonKey: supabaseKey,
      );
      // ✅ Инициализация controller
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color.fromARGB(0, 0, 0, 0));
      RecaptchaHandler.instance.setupSiteKey(dataSiteKey: key);

      const AppRunner().initializeAndRun();
    },
    logger.logZoneError,
  );
}
