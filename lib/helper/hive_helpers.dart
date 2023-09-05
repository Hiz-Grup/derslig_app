import 'package:derslig/models/login_response_model.dart';
import 'package:derslig/models/user_model.dart';
import 'package:derslig/providers/login_register_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class HiveHelpers {
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
    Hive.box('login').put('loginModel', loginResponseModel.toJson()).then(
        (value) =>
            print("loginModel saved" + loginResponseModel.toJson().toString()));
  }

  static LoginResponseModel? getLoginModel() {
    var loginModel = Hive.box('login').get('loginModel');
    if (loginModel != null) {
      return LoginResponseModel.fromJson(
          Map<String, dynamic>.from((loginModel)));
    } else {
      return null;
    }
  }

  static void logout(BuildContext context) {
    Hive.box('login').delete('loginModel');
    Hive.box('user').delete('status');
    Hive.box('user').delete('userModel');
    context.read<LoginRegisterPageProvider>().isLogin = false;
    context.read<LoginRegisterPageProvider>().userModel = null;
  }

  static void saveUserModel(UserModel userModel) {
    Hive.box('user').put('userModel', userModel.toJson());
  }

  static UserModel? getUserModel() {
    var userModel = Hive.box('user').get('userModel');
    if (userModel != null) {
      return UserModel.fromJson(Map<String, dynamic>.from((userModel)));
    } else {
      return null;
    }
  }
}
