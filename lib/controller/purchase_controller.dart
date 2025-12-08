import 'dart:convert';

import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/general_response_model.dart';
import 'package:derslig/services/api_service.dart';
import 'package:derslig/services/logger_service.dart';

class PurchaseController {
  final _apiService = locator<ApiService>();
  final _logger = LoggerService.instance;

  Future<GeneralResponseModel> buyProduct({
    required int index,
    required String xsrfToken,
    required String dersligCookie,
  }) async {
    try {
      _logger.addBreadcrumb(
        'Satın alma başlatıldı',
        category: 'purchase',
        data: {'productId': index + 1},
      );

      final response = await _apiService.postRequest(
        "https://www.derslig.com/api/payment/confirm",
        {
          "productId": (index + 1).toString(),
        },
        headers: {
          "Cookie": "XSRF-TOKEN=$xsrfToken; derslig_cookie=$dersligCookie;",
        },
      );

      if (response.statusCode == 200) {
        _logger.addBreadcrumb(
          'Satın alma başarılı',
          category: 'purchase',
          data: {'productId': index + 1},
        );
        return GeneralResponseModel(
          message: "Satın alma işlemi başarılı",
          success: true,
        );
      } else {
        final errorMessage = json.decode(response.body)["error"];
        _logger.logWarning(
          'Satın alma başarısız',
          context: {
            'productId': index + 1,
            'statusCode': response.statusCode,
            'error': errorMessage,
          },
        );
        return GeneralResponseModel(
          message: errorMessage,
          success: false,
        );
      }
    } catch (e, stackTrace) {
      _logger.logError(
        'Satın alma hatası',
        error: e,
        stackTrace: stackTrace,
        context: {'productId': index + 1},
      );
      return GeneralResponseModel(
        message: "Bir hata oluştu",
        success: false,
      );
    }
  }

  Future<GeneralResponseModel> checkUser({
    required String xsrfToken,
    required String dersligCookie,
  }) async {
    try {
      final response = await _apiService.postRequest(
        "https://www.derslig.com/api/payment/check",
        {},
        headers: {
          "Cookie": "XSRF-TOKEN=$xsrfToken; derslig_cookie=$dersligCookie;",
        },
      );

      if (response.statusCode == 200) {
        return GeneralResponseModel(
          message: "Kullanıcı kontrolü başarılı",
          success: true,
        );
      } else {
        final errorMessage = json.decode(response.body)["error"];
        _logger.logWarning(
          'Kullanıcı kontrolü başarısız',
          context: {
            'statusCode': response.statusCode,
            'error': errorMessage,
          },
        );
        return GeneralResponseModel(
          message: errorMessage,
          success: false,
        );
      }
    } catch (e, stackTrace) {
      _logger.logError(
        'Kullanıcı kontrol hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return GeneralResponseModel(
        message: "Bir hata oluştu!",
        success: false,
      );
    }
  }
}
