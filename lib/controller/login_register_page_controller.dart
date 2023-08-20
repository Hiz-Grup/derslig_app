import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/login_response_model.dart';
import 'package:derslig/services/api_service.dart';

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
}
