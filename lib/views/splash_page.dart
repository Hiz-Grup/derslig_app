import 'dart:io';

import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/helper/url_launcher_helper.dart';
import 'package:derslig/models/general_response_model.dart';
import 'package:derslig/providers/login_register_page_provider.dart';
import 'package:derslig/providers/purchase_provider.dart';
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
    SchedulerBinding.instance.addPostFrameCallback(
      (_) async {
        GeneralResponseModel versionResponse =
            await context.read<LoginRegisterPageProvider>().controlVersion();
        if (versionResponse.success == false) {
          _showForceUpdateDialog();
        } else {
          context
              .read<PurchaseProvider>()
              .initPlatformState()
              .then((value) async {
            if (HiveHelpers.getOnboardingStatus() == true) {
              await context.read<LoginRegisterPageProvider>().controlUser();
              // ignore: use_build_context_synchronously
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
          });
        }
      },
    );

    //TARAYICI ÜZERİNDEN ÇIKIŞ YAPINCA KOMPLE ÇIK

    super.initState();
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
              ? "https://play.google.com/store/apps/details?id=com.focus.pupa"
              : "https://apps.apple.com/tr/app/focused-pupa/id1579390348");
        },
        title: "Uygulama Güncellemesi",
        content:
            "Uygulama sürümünüz güncel değil. Lütfen uygulamanızı güncelleyiniz.",
        buttonText: "Güncelle",
        color: AppTheme.pink,
      ),
    );
  }
}
