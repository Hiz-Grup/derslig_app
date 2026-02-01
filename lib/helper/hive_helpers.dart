import 'package:derslig/models/login_response_model.dart';
import 'package:derslig/models/user_model.dart';
import 'package:derslig/providers/login_register_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import '../services/logger_service.dart';

class HiveHelpers {
  static final _logger = LoggerService.instance;
  static Future<void> saveOnboardingStatus() async {
    await Hive.box('onboarding').put('status', true);
  }

  static bool getOnboardingStatus() {
    return Hive.box('onboarding').get('status', defaultValue: false);
  }

  static Future<void> saveUserStatus(bool value) async {
    await Hive.box('user').put('status', value);
  }

  static void saveLoginModel(LoginResponseModel loginResponseModel) {
    Hive.box('login')
        .put('loginModel', loginResponseModel.toJson())
        .then((value) => _logger.debugLog("[HiveHelpers] LoginModel saved", data: loginResponseModel.toJson()));
  }

  static LoginResponseModel? getLoginModel() {
    var loginModel = Hive.box('login').get('loginModel');
    if (loginModel != null) {
      return LoginResponseModel.fromJson(Map<String, dynamic>.from((loginModel)));
    } else {
      return null;
    }
  }

  static void logout(BuildContext context) {
    Hive.box('login').delete('loginModel');
    Hive.box('user').delete('status');
    Hive.box('user').delete('userModel');
    OneSignal.logout();
    context.read<LoginRegisterPageProvider>().isLogin = false;
    context.read<LoginRegisterPageProvider>().userModel = null;
  }

  static void saveUserModel(UserModel userModel) {
    Hive.box('user')
        .put('userModel', userModel.toJson())
        .then((value) => _logger.debugLog("[HiveHelpers] UserModel saved", data: userModel.toJson()));
  }

  static UserModel? getUserModel() {
    var userModel = Hive.box('user').get('userModel');
    if (userModel != null) {
      return UserModel.fromJson(Map<String, dynamic>.from((userModel)));
    } else {
      return null;
    }
  }

  static void saveLastPremiumCheckTime(DateTime time) {
    Hive.box('user')
        .put('lastPremiumCheckTime', time.toIso8601String())
        .then((value) => _logger.debugLog("[HiveHelpers] LastPremiumCheckTime saved", data: time.toIso8601String()));
  }

  static DateTime? getLastPremiumCheckTime() {
    var time = Hive.box('user').get('lastPremiumCheckTime');
    if (time != null) {
      return DateTime.tryParse(time);
    }
    return null;
  }

  static bool shouldCheckPremiumToday() {
    final lastCheck = getLastPremiumCheckTime();
    if (lastCheck == null) return true;

    final now = DateTime.now();
    final lastCheckDate = DateTime(lastCheck.year, lastCheck.month, lastCheck.day);
    final today = DateTime(now.year, now.month, now.day);

    return today.isAfter(lastCheckDate);
  }
}
