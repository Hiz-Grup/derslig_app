import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/general_response_model.dart';
import 'package:derslig/services/api_service.dart';

class PurchaseController {
  final _apiService = locator<ApiService>();
  Future<GeneralResponseModel> buyProduct({
    required int index,
    required String xsrfToken,
    required String dersligCookie,
  }) async {
    GeneralResponseModel userCheck = await checkUser(
      xsrfToken: xsrfToken,
      dersligCookie: dersligCookie,
    );
    if (userCheck.success == false) {
      return userCheck;
    }

    try {
      final response = await _apiService.postRequest(
        "https://www.derslig.com/api/payment/confirm",
        {
          "index": index.toString(),
          "XSRF-TOKEN": xsrfToken,
          "derslig-cookie": dersligCookie,
        },
      );

      if (response.statusCode == 200) {
        return GeneralResponseModel(
          message: "Satın alma işlemi başarılı",
          success: true,
        );
      } else {
        return GeneralResponseModel(
          message: "Bir hata oluştu",
          success: false,
        );
      }
    } catch (e) {
      return GeneralResponseModel(
        message: "Bir hata oluştu",
        success: false,
      );
    }
  }

  Future<GeneralResponseModel> checkUser(
      {required String xsrfToken, required String dersligCookie}) async {
    try {
      final response = await _apiService.postRequest(
        "https://www.derslig.com/api/payment/check",
        {
          "XSRF-TOKEN": xsrfToken,
          "derslig-cookie": dersligCookie,
        },
      );

      if (response.statusCode == 200) {
        return GeneralResponseModel(
          message: "Kullanıcı kontrolü başarılı",
          success: true,
        );
      } else {
        return GeneralResponseModel(
          message:
              "Telefonunuz sistemde kayıtlı değil! Lütfen profil ayarlarından güncelleyiniz.",
          success: false,
        );
      }
    } catch (e) {
      return GeneralResponseModel(
        message: "Bir hata oluştu",
        success: false,
      );
    }
  }
}
