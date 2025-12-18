import 'dart:convert';
import 'dart:io';

import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/general_response_model.dart';
import 'package:derslig/services/api_service.dart';
import 'package:derslig/services/logger_service.dart';

class PurchaseController {
  final _apiService = locator<ApiService>();
  final _logger = LoggerService.instance;

  Future<GeneralResponseModel> buyProduct({
    required String transactionId,
    required String productId,
    required String productIdentifier,
    required DateTime purchaseDate,
    required String xsrfToken,
    required String dersligCookie,
    String source = 'direct',
  }) async {
    try {
      final response = await _apiService.postRequest(
        "https://www.derslig.com/api/payment/confirm",
        {
          "productId": productId,
          "transactionId": transactionId,
          "productIdentifier": productIdentifier,
          "purchaseDate": purchaseDate.toIso8601String(),
          "source": source,
          "platform": Platform.isAndroid ? "android" : "ios",
        },
        headers: {
          "Cookie": "XSRF-TOKEN=$xsrfToken; derslig_cookie=$dersligCookie;",
        },
      );

      if (response.statusCode == 200) {
        return GeneralResponseModel(
          message: "Satın alma işlemi başarılı",
          success: true,
        );
      } else {
        final errorMessage = _tryParseError(response.body);

        await _logger.logError(
          'Backend satın alma bildirimi başarısız',
          context: {
            'transactionId': transactionId,
            'productId': productId,
            'productIdentifier': productIdentifier,
            'statusCode': response.statusCode,
            'error': errorMessage,
            'source': source,
          },
        );

        return GeneralResponseModel(
          message: errorMessage ?? "Satın alma işlemi başarısız",
          success: false,
        );
      }
    } catch (e, stackTrace) {
      await _logger.logFatal(
        'Satın alma backend iletişim hatası',
        error: e,
        stackTrace: stackTrace,
        context: {
          'transactionId': transactionId,
          'productId': productId,
          'productIdentifier': productIdentifier,
          'purchaseDate': purchaseDate.toIso8601String(),
          'source': source,
        },
      );

      return GeneralResponseModel(
        message: "Bir hata oluştu",
        success: false,
      );
    }
  }

  Future<GeneralResponseModel> syncSubscriptionStatus({
    required bool isActive,
    required String? expirationDate,
    required String? productId,
    required String? originalAppUserId,
    required String xsrfToken,
    required String dersligCookie,
  }) async {
    try {
      final response = await _apiService.postRequest(
        "https://www.derslig.com/api/subscription/sync",
        {
          "isActive": isActive.toString(),
          "expirationDate": expirationDate ?? "",
          "productId": productId ?? "",
          "revenueCatProductId": productId ?? "",
          "revenueCatUserId": originalAppUserId ?? "",
          "platform": Platform.isAndroid ? "android" : "ios",
        },
        headers: {
          "Cookie": "XSRF-TOKEN=$xsrfToken; derslig_cookie=$dersligCookie;",
        },
      );

      if (response.statusCode == 200) {
        return GeneralResponseModel(
          message: "Abonelik durumu güncellendi",
          success: true,
        );
      } else {
        return GeneralResponseModel(
          message: _tryParseError(response.body) ?? "Senkronizasyon başarısız",
          success: false,
        );
      }
    } catch (e, stackTrace) {
      _logger.logError(
        'Abonelik senkronizasyonu hatası',
        error: e,
        stackTrace: stackTrace,
        context: {
          'isActive': isActive,
          'productId': productId,
        },
      );

      return GeneralResponseModel(
        message: "Bir hata oluştu!",
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
        return GeneralResponseModel(
          message: _tryParseError(response.body) ?? "Kontrol başarısız",
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

  String? _tryParseError(String body) {
    try {
      final decoded = json.decode(body);
      return decoded["error"] as String?;
    } catch (_) {
      return null;
    }
  }
}
