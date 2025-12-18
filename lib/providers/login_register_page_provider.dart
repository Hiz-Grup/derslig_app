import 'package:derslig/controller/login_register_page_controller.dart';
import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/general_response_model.dart';
import 'package:derslig/models/login_response_model.dart';
import 'package:derslig/models/user_model.dart';
import 'package:flutter/material.dart';

class LoginRegisterPageProvider with ChangeNotifier {
  final _loginRegisterPageController = locator<LoginRegisterPageController>();
  int _schoolLevelIndex = -1;
  int get schoolLevelIndex => _schoolLevelIndex;
  set schoolLevelIndex(index) {
    _schoolLevelIndex = index;
    notifyListeners();
  }

  int _schoolClassIndex = -1;
  int get schoolClassIndex => _schoolClassIndex;
  set schoolClassIndex(index) {
    _schoolClassIndex = index;
    notifyListeners();
  }

  bool _coockiePolicy = false;
  bool get coockiePolicy => _coockiePolicy;
  set coockiePolicy(value) {
    _coockiePolicy = value;
    notifyListeners();
  }

  bool _privacyPolicy = false;
  bool get privacyPolicy => _privacyPolicy;
  set privacyPolicy(value) {
    _privacyPolicy = value;
    notifyListeners();
  }

  bool _loginRoute = false;
  bool get loginRoute => _loginRoute;
  set loginRoute(value) {
    _loginRoute = value;
  }

  bool _isTriggeredLogoutPage = false;
  bool get isTriggeredLogoutPage => _isTriggeredLogoutPage;
  set isTriggeredLogoutPage(value) {
    _isTriggeredLogoutPage = value;
    notifyListeners();
  }

  bool _isLogin = false;
  bool get isLogin => _isLogin;
  set isLogin(value) {
    _isLogin = value;
    notifyListeners();
  }

  UserModel? _userModel;
  UserModel? get userModel => _userModel;
  set userModel(value) {
    _userModel = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<GeneralResponseModel> controlVersion() async {
    return await _loginRegisterPageController.controlVersion();
  }

  Future<UserModel> userApiControl({
    required String xsrfToken,
    required String dersligCookie,
  }) async {
    return await _loginRegisterPageController.userApiControl(
      xsrfToken: xsrfToken,
      dersligCookie: dersligCookie,
    );
  }

  Future<void> controlUser() async {
    try {
      LoginResponseModel? loginResponseModel = HiveHelpers.getLoginModel();
      if (loginResponseModel == null) {
        isLogin = false;
      } else {
        userModel = await userApiControl(
          xsrfToken: loginResponseModel.xsrfToken,
          dersligCookie: loginResponseModel.dersligCookie,
        );
        if (userModel!.isPremium != null) {
          isLogin = true;
        } else {
          isLogin = false;
        }
      }
    } catch (e) {
      isLogin = false;
    }
  }
}
