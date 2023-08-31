import 'dart:convert';
import 'dart:io';

import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/general_response_model.dart';
import 'package:derslig/models/login_response_model.dart';
import 'package:derslig/models/user_model.dart';
import 'package:derslig/services/api_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginRegisterPageController {
  final _apiService = locator<ApiService>();

  Future<LoginResponseModel?> login(String email, String password) async {
    try {
      LoginResponseModel loginResponseModel =
          await _apiService.login(email, password);

      HiveHelpers.saveLoginModel(loginResponseModel);
      HiveHelpers.saveUserStatus(true);
      return loginResponseModel;
    } catch (e) {
      print("LOGİN ERROR : " + e.toString());
      return null;
    }
  }

  Future<GeneralResponseModel> controlVersion() async {
    try {
      final response = await _apiService.getRequest(
        "https://www.derslig.com/api/app-version",
      );

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (Platform.isAndroid) {
        String version = json.decode(response.body)["data"]["android"];
        int versionCode = int.parse(version.replaceAll(".", ""));
        if (versionCode > int.parse(packageInfo.version.replaceAll(".", ""))) {
          return GeneralResponseModel(
            message: "Uygulama Güncellenmeli",
            success: false,
          );
        }
      } else if (Platform.isIOS) {
        String version = json.decode(response.body)["data"]["ios"];
        int versionCode = int.parse(version.replaceAll(".", ""));
        if (versionCode > int.parse(packageInfo.version.replaceAll(".", ""))) {
          return GeneralResponseModel(
            message: "Uygulama Güncellenmeli",
            success: false,
          );
        }
      }
      return GeneralResponseModel(
        message: "Uygulama Güncel",
        success: true,
      );
    } catch (e) {
      return GeneralResponseModel(
        message: "Uygulama Güncel",
        success: true,
      );
    }
  }

  Future<UserModel> userApiControl(
      {required String xsrfToken, required String desligCookie}) async {
    try {
      final response = await _apiService.postRequest(
        "https://www.derslig.com/api/user",
        {},
        headers: {
          "x-xsrf-token": xsrfToken,
          "cookie": desligCookie,
        },
      );
      UserModel userModel = UserModel.fromJson(json.decode(response.body));
      HiveHelpers.saveUserModel(userModel);

      return userModel;
    } catch (e) {
      return UserModel();
    }
  }
}
