import 'package:derslig/models/login_response_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  static bool getUserStatus() {
    return Hive.box('user').get('status', defaultValue: false);
  }

  static void saveLoginModel(LoginResponseModel loginResponseModel) {
    Hive.box('login')
        .put('loginModel', loginResponseModel.toJson())
        .then((value) => print("loginModel saved"));
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
}
