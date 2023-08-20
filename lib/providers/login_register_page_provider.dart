import 'package:derslig/controller/login_register_page_controller.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/login_response_model.dart';
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

  Future<LoginResponseModel?> login(String email, String password) async {
    return await _loginRegisterPageController.login(email, password);
  }
}
