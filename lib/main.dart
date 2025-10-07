import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/helper/provider_list.dart';
import 'package:derslig/services/one_signal_service.dart';
import 'package:derslig/views/home_page.dart';
import 'package:derslig/views/login_page.dart';
import 'package:derslig/views/onboarding_page.dart';
import 'package:derslig/views/register_page.dart';
import 'package:derslig/views/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  // WebView platform implementasyonunu başlat
  if (Platform.isIOS) {
    WebViewPlatform.instance = WebKitWebViewPlatform();
  } else if (Platform.isWindows) {
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
    } catch (e) {
      print('OneSignal başlatma hatası: $e');
    }
  }

  runApp(MultiProvider(
    providers: providers,
    child: const MyApp(),
  ));
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
        LoginPage.routeName: (context) => const LoginPage(),
        RegisterPage.routeName: (context) => const RegisterPage(),
      },
      initialRoute: SplashPage.routeName,
    );
  }
}
