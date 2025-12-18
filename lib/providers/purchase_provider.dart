import 'dart:io';

import 'package:derslig/controller/purchase_controller.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/general_response_model.dart';
import 'package:derslig/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

enum BuyState { idle, busy }

class PurchaseProvider with ChangeNotifier {
  final _purchaseController = locator<PurchaseController>();
  final _logger = LoggerService.instance;
  BuyState buyState = BuyState.idle;

  List<rc.Package> packages = [];
  rc.Offering? currentOffering;

  int selectedProductIndex = -1;

  bool _isLoggedInToRevenueCat = false;
  bool get isLoggedInToRevenueCat => _isLoggedInToRevenueCat;

  void selectProduct(int index) {
    selectedProductIndex = index;
    notifyListeners();
  }

  Future<void> initPlatformState() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await rc.Purchases.setLogLevel(rc.LogLevel.debug);

        rc.PurchasesConfiguration? configuration;
        if (Platform.isAndroid) {
          configuration = rc.PurchasesConfiguration("goog_wRHmEaOoDcFcIIYldGLpguNccvC");
          await rc.Purchases.configure(configuration);
          await rc.Purchases.enableAdServicesAttributionTokenCollection();
        } else if (Platform.isIOS) {
          configuration = rc.PurchasesConfiguration("appl_VjzrIVjfeEsQXHftXmwCdBasNQK");
          await rc.Purchases.configure(configuration);
        }
      }
    } catch (e, stackTrace) {
      _logger.logError(
        'Purchases başlatma hatası',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> loginToRevenueCat({
    required String userId,
    String? email,
    String? displayName,
  }) async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        return;
      }

      await rc.Purchases.logIn(userId);

      _isLoggedInToRevenueCat = true;

      if (email != null && email.isNotEmpty) {
        await rc.Purchases.setEmail(email);
      }

      if (displayName != null && displayName.isNotEmpty) {
        await rc.Purchases.setDisplayName(displayName);
      }

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.logError(
        'RevenueCat login hatası',
        error: e,
        stackTrace: stackTrace,
        context: {'userId': userId},
      );
    }
  }

  Future<void> logoutFromRevenueCat() async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        return;
      }

      await rc.Purchases.logOut();
      _isLoggedInToRevenueCat = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.logError(
        'RevenueCat logout hatası',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<GeneralResponseModel> syncSubscriptionStatus({
    required String xsrfToken,
    required String dersligCookie,
  }) async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        return GeneralResponseModel(
          message: "Platform desteklenmiyor",
          success: false,
        );
      }

      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) {
        return GeneralResponseModel(
          message: "Müşteri bilgileri alınamadı",
          success: false,
        );
      }

      final activeEntitlements = customerInfo.entitlements.active;
      final isActive = activeEntitlements.isNotEmpty;

      String? expirationDate;
      String? productId;

      if (isActive && activeEntitlements.values.isNotEmpty) {
        final entitlement = activeEntitlements.values.first;
        expirationDate = entitlement.expirationDate;
        productId = entitlement.productIdentifier;
      }

      return await _purchaseController.syncSubscriptionStatus(
        isActive: isActive,
        expirationDate: expirationDate,
        productId: productId,
        originalAppUserId: customerInfo.originalAppUserId,
        xsrfToken: xsrfToken,
        dersligCookie: dersligCookie,
      );
    } catch (e, stackTrace) {
      _logger.logError(
        'Abonelik senkronizasyonu hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return GeneralResponseModel(
        message: "Senkronizasyon hatası",
        success: false,
      );
    }
  }

  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) {
        return SubscriptionStatus.unknown;
      }

      if (customerInfo.entitlements.active.isNotEmpty) {
        return SubscriptionStatus.active;
      }

      return SubscriptionStatus.inactive;
    } catch (e) {
      return SubscriptionStatus.unknown;
    }
  }

  Future<void> getProductDetails(BuildContext context) async {
    try {
      rc.Offerings offerings = await rc.Purchases.getOfferings();

      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        currentOffering = offerings.current;
        packages = offerings.current!.availablePackages;

        packages.sort((a, b) {
          String aId = a.storeProduct.identifier.toLowerCase();
          String bId = b.storeProduct.identifier.toLowerCase();

          int aMonths = _extractMonthsFromId(aId);
          int bMonths = _extractMonthsFromId(bId);

          return aMonths.compareTo(bMonths);
        });

        notifyListeners();
      }
    } catch (e, stackTrace) {
      _logger.logError(
        'RevenueCat: Ürün detayları alınırken hata',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  int _extractMonthsFromId(String id) {
    if (id.contains('1aylik')) return 1;
    if (id.contains('3aylik')) return 3;
    if (id.contains('6aylik')) return 6;
    if (id.contains('12aylik')) return 12;
    return 0;
  }

  setBuyState(BuyState state) {
    buyState = state;
    notifyListeners();
  }

  Future<PurchaseResultData?> purchasePackage(rc.Package package) async {
    try {
      rc.PurchaseResult result = await rc.Purchases.purchasePackage(package);

      String? transactionId;
      DateTime purchaseDate = DateTime.now();

      if (result.customerInfo.nonSubscriptionTransactions.isNotEmpty) {
        final lastTransaction = result.customerInfo.nonSubscriptionTransactions.last;
        transactionId = lastTransaction.transactionIdentifier;
        try {
          purchaseDate = DateTime.parse(lastTransaction.purchaseDate);
        } catch (_) {
          purchaseDate = DateTime.now();
        }
      }

      if (transactionId == null && result.customerInfo.entitlements.active.isNotEmpty) {
        final entitlement = result.customerInfo.entitlements.active.values.first;
        transactionId = entitlement.productIdentifier;
      }

      transactionId ??= '${package.storeProduct.identifier}_${DateTime.now().millisecondsSinceEpoch}';

      return PurchaseResultData(
        customerInfo: result.customerInfo,
        transactionId: transactionId,
        productIdentifier: package.storeProduct.identifier,
        purchaseDate: purchaseDate,
      );
    } catch (e, stackTrace) {
      _logger.logError(
        'RevenueCat: Satın alma hatası',
        error: e,
        stackTrace: stackTrace,
        context: {
          'packageId': package.identifier,
          'productId': package.storeProduct.identifier,
        },
      );
      return null;
    }
  }

  Future<GeneralResponseModel> buyProduct({
    required String transactionId,
    required String productId,
    required String productIdentifier,
    required DateTime purchaseDate,
    required String xsrfToken,
    required String dersligCookie,
  }) async {
    return await _purchaseController.buyProduct(
      transactionId: transactionId,
      productId: productId,
      productIdentifier: productIdentifier,
      purchaseDate: purchaseDate,
      xsrfToken: xsrfToken,
      dersligCookie: dersligCookie,
    );
  }

  Future<GeneralResponseModel> checkUser({
    required String xsrfToken,
    required String dersligCookie,
  }) async {
    return await _purchaseController.checkUser(
      xsrfToken: xsrfToken,
      dersligCookie: dersligCookie,
    );
  }

  Future<rc.CustomerInfo?> getCustomerInfo() async {
    try {
      rc.CustomerInfo customerInfo = await rc.Purchases.getCustomerInfo();
      return customerInfo;
    } catch (e, stackTrace) {
      _logger.logError(
        'RevenueCat: Kullanıcı bilgileri alınırken hata',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<rc.CustomerInfo?> restorePurchases() async {
    try {
      rc.CustomerInfo customerInfo = await rc.Purchases.restorePurchases();
      return customerInfo;
    } catch (e, stackTrace) {
      _logger.logError(
        'RevenueCat: Satın almalar geri yüklenirken hata',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}

class PurchaseResultData {
  final rc.CustomerInfo customerInfo;
  final String transactionId;
  final String productIdentifier;
  final DateTime purchaseDate;

  PurchaseResultData({
    required this.customerInfo,
    required this.transactionId,
    required this.productIdentifier,
    required this.purchaseDate,
  });
}

enum SubscriptionStatus {
  active,
  inactive,
  unknown,
}
