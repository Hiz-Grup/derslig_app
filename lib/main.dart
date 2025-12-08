import 'dart:async';
import 'dart:io';

import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/helper/provider_list.dart';
import 'package:derslig/services/logger_service.dart';
import 'package:derslig/services/one_signal_service.dart';
import 'package:derslig/views/home_page.dart';
import 'package:derslig/views/onboarding_page.dart';
import 'package:derslig/views/splash_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  await LoggerService.init(
    appRunner: () async {
      await _initializeApp();

      FlutterError.onError = (FlutterErrorDetails details) {
        LoggerService.instance.captureFlutterError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        LoggerService.instance.logError(
          'Platform Error',
          error: error,
          stackTrace: stack,
        );
        return true;
      };

      runApp(MultiProvider(
        providers: providers,
        child: const MyApp(),
      ));
    },
  );
}

Future<void> _initializeApp() async {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  setupLocator();

  if (Platform.isIOS) {
    WebViewPlatform.instance = WebKitWebViewPlatform();
  }

  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox('user'),
    Hive.openBox('onboarding'),
    Hive.openBox('login'),
  ]);

  if (Platform.isAndroid || Platform.isIOS) {
    try {
      await OneSignalService.init();
    } catch (e, stackTrace) {
      LoggerService.instance.logError(
        'OneSignal başlatma hatası',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  LoggerService.instance.addBreadcrumb(
    'Uygulama başlatıldı',
    category: 'app.lifecycle',
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Derslig',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: AppTheme.appFontFamily,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        SplashPage.routeName: (context) => const SplashPage(),
        OnboardingPage.routeName: (context) => const OnboardingPage(),
      },
      initialRoute: SplashPage.routeName,
    );
  }
}
