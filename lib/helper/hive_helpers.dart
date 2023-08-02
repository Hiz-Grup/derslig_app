import 'package:hive_flutter/hive_flutter.dart';

class HiveHelpers {
  static Future<void> saveOnboardingStatus() async {
    await Hive.box('onboarding').put('status', true);
  }

  static bool getOnboardingStatus() {
    return Hive.box('onboarding').get('status', defaultValue: false);
  }

  static Future<void> saveUserStatus() async {
    await Hive.box('user').put('status', true);
  }

  static bool getUserStatus() {
    return Hive.box('user').get('status', defaultValue: false);
  }
}
