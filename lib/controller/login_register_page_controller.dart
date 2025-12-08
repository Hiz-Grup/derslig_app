import 'dart:convert';
import 'dart:io';

import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/general_response_model.dart';
import 'package:derslig/models/login_response_model.dart';
import 'package:derslig/models/user_model.dart';
import 'package:derslig/services/api_service.dart';
import 'package:derslig/services/logger_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginRegisterPageController {
  final _apiService = locator<ApiService>();
  final _logger = LoggerService.instance;

  Future<LoginResponseModel?> login(String email, String password) async {
    try {
      LoginResponseModel loginResponseModel = await _apiService.login(email, password);

      HiveHelpers.saveLoginModel(loginResponseModel);
      HiveHelpers.saveUserStatus(true);

      _logger.addBreadcrumb('Kullanıcı giriş yaptı', category: 'auth');

      return loginResponseModel;
    } catch (e, stackTrace) {
      _logger.logError(
        'Login hatası',
        error: e,
        stackTrace: stackTrace,
        context: {'email': email},
      );
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
    } catch (e, stackTrace) {
      _logger.logError(
        'Versiyon kontrol hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return GeneralResponseModel(
        message: "Uygulama Güncel",
        success: true,
      );
    }
  }

  Future<UserModel> userApiControl({
    required String xsrfToken,
    required String dersligCookie,
  }) async {
    try {
      _logger.debugLog('User API kontrol başlatıldı');

      final response = await _apiService.getRequest(
        "https://www.derslig.com/api/user",
        headers: {
          "Cookie": "XSRF-TOKEN=$xsrfToken; derslig_cookie=$dersligCookie;",
        },
      );

      UserModel userModel = UserModel.fromJson(json.decode(response.body)["data"]);
      HiveHelpers.saveUserModel(userModel);

      _logger.setUser(
        userId: userModel.id?.toString(),
        email: userModel.email,
        username: userModel.name,
      );

      return userModel;
    } catch (e, stackTrace) {
      _logger.logError(
        'User API kontrol hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return UserModel();
    }
  }
}
