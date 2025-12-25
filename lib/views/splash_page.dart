import 'dart:io';

import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/helper/url_launcher_helper.dart';
import 'package:derslig/models/general_response_model.dart';
import 'package:derslig/providers/login_register_page_provider.dart';
import 'package:derslig/providers/purchase_provider.dart';
import 'package:derslig/services/logger_service.dart';
import 'package:derslig/services/one_signal_service.dart';
import 'package:derslig/services/pending_purchase_service.dart';
import 'package:derslig/views/onboarding_page.dart';
import 'package:derslig/views/web_view_page.dart';
import 'package:derslig/views/widgets/dialog_widgets.dart';
import 'package:derslig/views/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);
  static const String routeName = '/splash';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _logger = LoggerService.instance;
  final _pendingPurchaseService = PendingPurchaseService.instance;

  @override
  void initState() {
    InternetConnectionChecker().hasConnection.then((isDeviceConnected) {
      if (isDeviceConnected == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => const NoInternetWidget(),
          ),
        );
      }
    });

    OneSignalService.init();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) async {
        GeneralResponseModel versionResponse = await context.read<LoginRegisterPageProvider>().controlVersion();
        if (versionResponse.success == false) {
          _showForceUpdateDialog();
        } else {
          await _initializePurchaseAndSync();
        }
      },
    );

    super.initState();
  }

  Future<void> _initializePurchaseAndSync() async {
    try {
      await context.read<PurchaseProvider>().initPlatformState();

      if (HiveHelpers.getOnboardingStatus() == true) {
        await context.read<LoginRegisterPageProvider>().controlUser();

        final userModel = HiveHelpers.getUserModel();
        final loginModel = HiveHelpers.getLoginModel();

        if (userModel != null && loginModel != null) {
          await _handleLoggedInUser(userModel, loginModel);
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const WebViewPage(
                url: "https://derslig.com/giris",
              ),
            ),
          );
        }
      } else {
        HiveHelpers.saveOnboardingStatus();
        if (mounted) {
          Navigator.pushReplacementNamed(context, OnboardingPage.routeName);
        }
      }
    } catch (e, stackTrace) {
      _logger.logError(
        'Splash başlatma hatası',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        if (HiveHelpers.getOnboardingStatus() == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const WebViewPage(
                url: "https://derslig.com/giris",
              ),
            ),
          );
        } else {
          HiveHelpers.saveOnboardingStatus();
          Navigator.pushReplacementNamed(context, OnboardingPage.routeName);
        }
      }
    }
  }

  Future<void> _handleLoggedInUser(userModel, loginModel) async {
    try {
      await context.read<PurchaseProvider>().loginToRevenueCat(
            userId: userModel.id.toString(),
            email: userModel.email,
            displayName: '${userModel.name ?? ''} ${userModel.surname ?? ''}'.trim(),
          );

      await _logger.setUser(
        userId: userModel.id.toString(),
        email: userModel.email,
        username: userModel.name,
      );

      await _processPendingPurchases();
    } catch (e, stackTrace) {
      _logger.logError(
        'Kullanıcı RevenueCat/Abonelik işlemleri hatası',
        error: e,
        stackTrace: stackTrace,
        context: {'userId': userModel.id},
      );
    }
  }

  Future<void> _processPendingPurchases() async {
    try {
      if (!_pendingPurchaseService.hasPendingPurchases) {
        return;
      }

      await _pendingPurchaseService.processPendingPurchases();
    } catch (e, stackTrace) {
      _logger.logError(
        'Bekleyen satın alma işleme hatası',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/derslig-logo.png",
          width: deviceWidthSize(context, 200),
        ),
      ),
    );
  }

  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DialogWidgets().rowCircularButtonDialogWidget(
        context,
        onAcceptButtonPressed: () {
          UrlLauncherHelper().launch(Platform.isAndroid
              ? "https://play.google.com/store/apps/details?id=com.derslig.app"
              : "https://apps.apple.com/us/app/derslig/id6451071489");
        },
        title: "Uygulama Güncellemesi",
        content: "Uygulama sürümünüz güncel değil. Lütfen uygulamanızı güncelleyiniz.",
        buttonText: "Güncelle",
        color: AppTheme.pink,
      ),
    );
  }
}
