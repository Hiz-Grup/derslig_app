import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/views/home_page.dart';
import 'package:derslig/views/login_page.dart';
import 'package:derslig/views/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);
  static const String routeName = '/splash';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2)).then(
      (_) => SchedulerBinding.instance.addPostFrameCallback(
        (_) {
          if (HiveHelpers.getOnboardingStatus()) {
            if (HiveHelpers.getUserStatus() == true) {
              Navigator.pushReplacementNamed(context, HomePage.routeName);
            } else {
              Navigator.pushReplacementNamed(context, LoginPage.routeName);
            }
          } else {
            HiveHelpers.saveOnboardingStatus();
            Navigator.pushReplacementNamed(context, OnboardingPage.routeName);
          }
        },
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
