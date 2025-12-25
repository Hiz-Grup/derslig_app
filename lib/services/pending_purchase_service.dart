import 'dart:async';

import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/pending_purchase_model.dart';
import 'package:derslig/services/api_service.dart';
import 'package:derslig/services/logger_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PendingPurchaseService {
  static final PendingPurchaseService _instance = PendingPurchaseService._internal();
  static PendingPurchaseService get instance => _instance;

  PendingPurchaseService._internal();

  final _logger = LoggerService.instance;
  final _apiService = locator<ApiService>();

  static const String _boxName = 'pendingPurchases';
  static const int _maxRetryCount = 5;

  Box get _box => Hive.box(_boxName);

  Future<void> addPendingPurchase(PendingPurchaseModel purchase) async {
    try {
      await _box.put(purchase.transactionId, purchase.toJson());
    } catch (e, stackTrace) {
      _logger.logError(
        'Bekleyen satın alma eklenirken hata',
        error: e,
        stackTrace: stackTrace,
        context: {
          'transactionId': purchase.transactionId,
          'productId': purchase.productId,
        },
      );
    }
  }

  List<PendingPurchaseModel> getPendingPurchases() {
    try {
      final purchases = <PendingPurchaseModel>[];

      for (var key in _box.keys) {
        final json = _box.get(key);
        if (json != null) {
          purchases.add(PendingPurchaseModel.fromJson(Map<String, dynamic>.from(json)));
        }
      }

      return purchases;
    } catch (e, stackTrace) {
      _logger.logError(
        'Bekleyen satın almalar getirilirken hata',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  int get pendingCount => _box.length;

  bool get hasPendingPurchases => _box.isNotEmpty;

  Future<void> removePendingPurchase(String transactionId) async {
    try {
      await _box.delete(transactionId);
    } catch (e, stackTrace) {
      _logger.logError(
        'Bekleyen satın alma silinirken hata',
        error: e,
        stackTrace: stackTrace,
        context: {'transactionId': transactionId},
      );
    }
  }

  Future<void> updatePendingPurchase(PendingPurchaseModel purchase) async {
    try {
      await _box.put(purchase.transactionId, purchase.toJson());
    } catch (e, stackTrace) {
      _logger.logError(
        'Bekleyen satın alma güncellenirken hata',
        error: e,
        stackTrace: stackTrace,
        context: {'transactionId': purchase.transactionId},
      );
    }
  }

  Future<PendingPurchaseResult> processPendingPurchases() async {
    final purchases = getPendingPurchases();

    if (purchases.isEmpty) {
      return PendingPurchaseResult(processed: 0, successful: 0, failed: 0);
    }

    int processed = 0;
    int successful = 0;
    int failed = 0;

    for (final purchase in purchases) {
      processed++;

      if (purchase.retryCount >= _maxRetryCount) {
        await _logger.logFatal(
          'Satın alma backend\'e iletilemedi - Max retry aşıldı',
          context: {
            'transactionId': purchase.transactionId,
            'productId': purchase.productId,
            'productIdentifier': purchase.productIdentifier,
            'purchaseDate': purchase.purchaseDate.toIso8601String(),
            'retryCount': purchase.retryCount,
            'createdAt': purchase.createdAt.toIso8601String(),
          },
        );
        failed++;
        continue;
      }

      if (purchase.lastRetryAt != null) {
        final backoffMinutes = _calculateBackoffMinutes(purchase.retryCount);
        final nextRetryTime = purchase.lastRetryAt!.add(Duration(minutes: backoffMinutes));

        if (DateTime.now().isBefore(nextRetryTime)) {
          continue;
        }
      }

      final success = await _sendPurchaseToBackend(purchase);

      if (success) {
        await removePendingPurchase(purchase.transactionId);
        successful++;
      } else {
        final updatedPurchase = purchase.copyWithIncrementedRetry();
        await updatePendingPurchase(updatedPurchase);
        failed++;
      }
    }

    return PendingPurchaseResult(
      processed: processed,
      successful: successful,
      failed: failed,
    );
  }

  int _calculateBackoffMinutes(int retryCount) {
    return (1 << retryCount).clamp(1, 60);
  }

  Future<bool> _sendPurchaseToBackend(PendingPurchaseModel purchase) async {
    try {
      final loginModel = HiveHelpers.getLoginModel();
      if (loginModel == null) {
        return false;
      }

      final response = await _apiService.postRequest(
        "https://www.derslig.com/api/payment/confirm",
        {
          "productId": purchase.productId,
          "transactionId": purchase.transactionId,
          "productIdentifier": purchase.productIdentifier,
          "purchaseDate": purchase.purchaseDate.toIso8601String(),
          "source": "pending_retry",
        },
        headers: {
          "Cookie": "XSRF-TOKEN=${loginModel.xsrfToken}; derslig_cookie=${loginModel.dersligCookie};",
        },
      );

      return response.statusCode == 200;
    } catch (e, stackTrace) {
      _logger.logError(
        'Bekleyen satın alma gönderilirken hata',
        error: e,
        stackTrace: stackTrace,
        context: {
          'transactionId': purchase.transactionId,
          'productId': purchase.productId,
        },
      );
      return false;
    }
  }
}

class PendingPurchaseResult {
  final int processed;
  final int successful;
  final int failed;

  PendingPurchaseResult({
    required this.processed,
    required this.successful,
    required this.failed,
  });

  bool get hasFailures => failed > 0;
  bool get allSuccessful => processed > 0 && failed == 0;
}