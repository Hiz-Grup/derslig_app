import 'dart:io';

import 'package:derslig/controller/purchase_controller.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/general_response_model.dart';
import 'package:derslig/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

enum BuyState { idle, busy }

class EntitlementIds {
  static const String proAccess = 'pro_access';
  static const String legacyIos = 'derslig-pro';
  static const String legacyAndroid = 'derslig-pro-android';
}

class BranchInfo {
  static const Map<int, String> branchNames = {
    1: 'İlkokul İngilizce Öğretmeni',
    2: 'Sınıf Öğretmeni',
    3: 'Ortaokul Matematik Öğretmeni',
    4: 'Fen Bilimleri Öğretmeni',
    5: 'Türkçe Öğretmeni',
    6: 'Sosyal Bilgiler Öğretmeni',
    7: 'Ortaokul İngilizce Öğretmeni',
    8: 'Lise Matematik Öğretmeni',
    9: 'Edebiyat Öğretmeni',
    10: 'Fizik Öğretmeni',
    11: 'Kimya Öğretmeni',
    12: 'Biyoloji Öğretmeni',
    13: 'Tarih Öğretmeni',
    14: 'Coğrafya Öğretmeni',
    15: 'Felsefe Öğretmeni',
    16: 'Lise İngilizce Öğretmeni',
    17: 'Almanca Öğretmeni',
    18: 'Beden Eğitimi Öğretmeni',
    19: 'Müzik Öğretmeni',
    20: 'Görsel Sanatlar Öğretmeni',
    21: 'Teknoloji ve Tasarım Öğretmeni',
    22: 'Din Kültürü ve Ahlak Bilgisi Öğretmeni',
    23: 'Rehber Öğretmen',
    24: 'İspanyolca Öğretmeni',
  };

  static String? getBranchName(int? branchId) {
    if (branchId == null) return null;
    return branchNames[branchId];
  }
}

class SchoolLevelInfo {
  static const Map<int, String> levelNames = {
    1: 'İlkokul',
    2: 'Ortaokul',
    3: 'Lise',
  };

  static String? getLevelName(int? levelId) {
    if (levelId == null) return null;
    return levelNames[levelId];
  }
}

class UserTypeInfo {
  static const Map<int, String> typeNames = {
    1: 'Öğretmen',
    2: 'Öğrenci',
  };

  static String? getTypeName(int? typeId) {
    if (typeId == null) return null;
    return typeNames[typeId];
  }
}

class PurchaseProvider with ChangeNotifier {
  final _purchaseController = locator<PurchaseController>();
  final _logger = LoggerService.instance;
  BuyState buyState = BuyState.idle;

  List<rc.Package> packages = [];
  rc.Offering? currentOffering;

  int selectedProductIndex = -1;

  bool _isLoggedInToRevenueCat = false;
  bool get isLoggedInToRevenueCat => _isLoggedInToRevenueCat;

  SubscriptionInfo? _activeSubscription;
  SubscriptionInfo? get activeSubscription => _activeSubscription;

  void selectProduct(int index) {
    selectedProductIndex = index;
    notifyListeners();
  }

  void _logSubscriptionDebug(String message) {
    _logger.debugLog('💳 [Subscription] $message');
  }

  void _logSubscriptionStatus(SubscriptionInfo info, {required String entitlementId}) {
    _logger.debugLog('''
💳 ══════════════════════════════════════
💳 SUBSCRIPTION STATUS
💳 ══════════════════════════════════════
💳 Entitlement: $entitlementId
💳 Is Active: ${info.isActive}
💳 Is Legacy: ${info.isLegacy}
💳 Product ID: ${info.productIdentifier}
💳 Is Trial: ${info.isTrialPeriod}
💳 Will Renew: ${info.willRenew}
💳 Is Sandbox: ${info.isSandbox}
💳 Expiration: ${info.expirationDate}
💳 Days Until Expiry: ${info.daysUntilExpiration}
💳 ══════════════════════════════════════
''');
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
    String? phone,
    int? type,
    int? isPremium,
    int? schoolLevelId,
    int? gradeId,
    int? branchId,
    int? schoolId,
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

      if (phone != null && phone.isNotEmpty) {
        await rc.Purchases.setPhoneNumber(phone);
      }

      final Map<String, String> attributes = {};

      if (gradeId != null) {
        attributes['class'] = gradeId.toString();
      }

      if (type != null) {
        attributes['type'] = type.toString();
        attributes['typeName'] = UserTypeInfo.getTypeName(type) ?? '';
      }

      if (isPremium != null) {
        attributes['isPremium'] = isPremium.toString();
      }

      if (schoolLevelId != null) {
        attributes['schoolLevelId'] = schoolLevelId.toString();
        attributes['schoolLevelName'] = SchoolLevelInfo.getLevelName(schoolLevelId) ?? '';
      }

      if (gradeId != null) {
        attributes['gradeId'] = gradeId.toString();
      }

      if (type == 1 && branchId != null) {
        attributes['branchId'] = branchId.toString();
        attributes['branchName'] = BranchInfo.getBranchName(branchId) ?? '';
      }

      if (schoolId != null) {
        attributes['schoolId'] = schoolId.toString();
      }

      if (attributes.isNotEmpty) {
        await rc.Purchases.setAttributes(attributes);
        _logger.debugLog('💳 [RevenueCat] Attributes set: $attributes');
      }

      await refreshSubscriptionStatus();

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
      _activeSubscription = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.logError(
        'RevenueCat logout hatası',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> hasProAccess() async {
    final subscriptionInfo = await getActiveSubscription();
    return subscriptionInfo.isActive;
  }

  Future<SubscriptionInfo> getActiveSubscription() async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) {
        _logSubscriptionDebug('CustomerInfo null - returning inactive');
        return SubscriptionInfo.inactive();
      }

      _logSubscriptionDebug('Active entitlements: ${customerInfo.entitlements.active.keys.toList()}');

      if (customerInfo.entitlements.active.containsKey(EntitlementIds.proAccess)) {
        final entitlement = customerInfo.entitlements.active[EntitlementIds.proAccess]!;
        final info = _createSubscriptionInfoFromEntitlement(entitlement, isLegacy: false);
        _logSubscriptionStatus(info, entitlementId: EntitlementIds.proAccess);
        return info;
      }

      if (customerInfo.entitlements.active.containsKey(EntitlementIds.legacyIos)) {
        final entitlement = customerInfo.entitlements.active[EntitlementIds.legacyIos]!;
        final info = _createSubscriptionInfoFromEntitlement(entitlement, isLegacy: true);
        _logSubscriptionStatus(info, entitlementId: EntitlementIds.legacyIos);
        return info;
      }

      if (customerInfo.entitlements.active.containsKey(EntitlementIds.legacyAndroid)) {
        final entitlement = customerInfo.entitlements.active[EntitlementIds.legacyAndroid]!;
        final info = _createSubscriptionInfoFromEntitlement(entitlement, isLegacy: true);
        _logSubscriptionStatus(info, entitlementId: EntitlementIds.legacyAndroid);
        return info;
      }

      _logSubscriptionDebug('No active entitlements found - returning inactive');
      return SubscriptionInfo.inactive();
    } catch (e, stackTrace) {
      _logger.logError(
        'Subscription bilgisi alınırken hata',
        error: e,
        stackTrace: stackTrace,
      );
      return SubscriptionInfo.unknown();
    }
  }

  SubscriptionInfo _createSubscriptionInfoFromEntitlement(
    rc.EntitlementInfo entitlement, {
    required bool isLegacy,
  }) {
    DateTime? expirationDate;
    if (entitlement.expirationDate != null) {
      expirationDate = DateTime.tryParse(entitlement.expirationDate!);
    }

    return SubscriptionInfo(
      isActive: true,
      isLegacy: isLegacy,
      productIdentifier: entitlement.productIdentifier,
      expirationDate: expirationDate,
      isTrialPeriod: entitlement.periodType == rc.PeriodType.trial,
      willRenew: entitlement.willRenew,
      isSandbox: entitlement.isSandbox,
    );
  }

  Future<void> refreshSubscriptionStatus() async {
    _logSubscriptionDebug('Refreshing subscription status...');
    _activeSubscription = await getActiveSubscription();
    notifyListeners();
  }

  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final subscriptionInfo = await getActiveSubscription();
      if (subscriptionInfo.isActive) {
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

      _logger.debugLog('📦 All available offerings: ${offerings.all.keys.toList()}');
      _logger.debugLog('📦 Current offering identifier: ${offerings.current?.identifier}');

      final subscriptionOffering = offerings.getOffering("derslig-pro-subscription");

      _logger.debugLog('📦 Subscription offering found: ${subscriptionOffering != null}');
      if (subscriptionOffering != null) {
        _logger.debugLog('📦 Subscription offering packages: ${subscriptionOffering.availablePackages.length}');
        for (final pkg in subscriptionOffering.availablePackages) {
          _logger.debugLog(
              '📦 Package: ${pkg.identifier} -> ${pkg.storeProduct.identifier} (category: ${pkg.storeProduct.productCategory})');
        }
      }

      if (subscriptionOffering != null && subscriptionOffering.availablePackages.isNotEmpty) {
        _logger.debugLog('📦 Using: derslig-pro-subscription offering');
        currentOffering = subscriptionOffering;
        packages = subscriptionOffering.availablePackages;
      } else if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        _logger.debugLog('📦 FALLBACK: Using current/default offering: ${offerings.current!.identifier}');
        currentOffering = offerings.current;
        packages = offerings.current!.availablePackages;
      }

      packages.sort((a, b) {
        String aId = a.storeProduct.identifier.toLowerCase();
        String bId = b.storeProduct.identifier.toLowerCase();

        int aMonths = _extractMonthsFromId(aId);
        int bMonths = _extractMonthsFromId(bId);

        return aMonths.compareTo(bMonths);
      });

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.logError(
        'RevenueCat: Ürün detayları alınırken hata',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  int _extractMonthsFromId(String id) {
    if (id.contains('monthly') && !id.contains('3') && !id.contains('6') && !id.contains('12')) {
      return 1;
    }
    if (id.contains('3months') || id.contains('3aylik')) return 3;
    if (id.contains('6months') || id.contains('6aylik')) return 6;
    if (id.contains('annual') || id.contains('12aylik') || id.contains('12months')) return 12;

    if (id.contains('1aylik')) return 1;

    return 0;
  }

  setBuyState(BuyState state) {
    buyState = state;
    notifyListeners();
  }

  Future<PurchaseResultData?> purchasePackage(rc.Package package) async {
    try {
      rc.PurchaseResult result = await rc.Purchases.purchasePackage(package);
      final customerInfo = result.customerInfo;

      String? transactionId = result.storeTransaction.transactionIdentifier;
      DateTime purchaseDate = DateTime.now();
      DateTime? expirationDate;
      bool isTrialPeriod = false;
      bool willRenew = true;

      if (customerInfo.entitlements.active.containsKey(EntitlementIds.proAccess)) {
        final entitlement = customerInfo.entitlements.active[EntitlementIds.proAccess]!;

        if (entitlement.expirationDate != null) {
          expirationDate = DateTime.tryParse(entitlement.expirationDate!);
        }

        purchaseDate = DateTime.tryParse(entitlement.latestPurchaseDate) ?? DateTime.now();

        isTrialPeriod = entitlement.periodType == rc.PeriodType.trial;
        willRenew = entitlement.willRenew;
      }

      if (customerInfo.nonSubscriptionTransactions.isNotEmpty) {
        final lastTransaction = customerInfo.nonSubscriptionTransactions.last;
        try {
          purchaseDate = DateTime.parse(lastTransaction.purchaseDate);
        } catch (_) {}
      }

      await refreshSubscriptionStatus();

      return PurchaseResultData(
        customerInfo: customerInfo,
        transactionId: transactionId,
        productIdentifier: package.storeProduct.identifier,
        purchaseDate: purchaseDate,
        expirationDate: expirationDate,
        isTrialPeriod: isTrialPeriod,
        willRenew: willRenew,
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

  Future<GeneralResponseModel> confirmSubscription({
    required String transactionId,
    required String productIdentifier,
    required DateTime purchaseDate,
    DateTime? expirationDate,
    required bool isTrialPeriod,
    required bool willRenew,
    required String xsrfToken,
    required String dersligCookie,
  }) async {
    return await _purchaseController.confirmSubscription(
      transactionId: transactionId,
      productIdentifier: productIdentifier,
      purchaseDate: purchaseDate,
      expirationDate: expirationDate,
      isTrialPeriod: isTrialPeriod,
      willRenew: willRenew,
      xsrfToken: xsrfToken,
      dersligCookie: dersligCookie,
    );
  }

  @Deprecated('Use confirmSubscription instead. This method is for legacy consumable products only.')
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

      await refreshSubscriptionStatus();

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

  Future<void> openSubscriptionManagement() async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo?.managementURL != null) {
        _logger.logInfo(
          'Subscription management URL',
          context: {'url': customerInfo!.managementURL},
        );
      }
    } catch (e, stackTrace) {
      _logger.logError(
        'Subscription yönetim sayfası açılırken hata',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

class PurchaseResultData {
  final rc.CustomerInfo customerInfo;
  final String transactionId;
  final String productIdentifier;
  final DateTime purchaseDate;
  final DateTime? expirationDate;
  final bool isTrialPeriod;
  final bool willRenew;

  PurchaseResultData({
    required this.customerInfo,
    required this.transactionId,
    required this.productIdentifier,
    required this.purchaseDate,
    this.expirationDate,
    this.isTrialPeriod = false,
    this.willRenew = true,
  });
}

class SubscriptionInfo {
  final bool isActive;
  final bool isLegacy;
  final String? productIdentifier;
  final DateTime? expirationDate;
  final bool isTrialPeriod;
  final bool willRenew;
  final bool isSandbox;
  final SubscriptionStatus status;

  SubscriptionInfo({
    required this.isActive,
    this.isLegacy = false,
    this.productIdentifier,
    this.expirationDate,
    this.isTrialPeriod = false,
    this.willRenew = true,
    this.isSandbox = false,
  }) : status = isActive ? SubscriptionStatus.active : SubscriptionStatus.inactive;

  factory SubscriptionInfo.inactive() => SubscriptionInfo(isActive: false);

  factory SubscriptionInfo.unknown() => SubscriptionInfo(
        isActive: false,
      );

  int? get daysUntilExpiration {
    if (expirationDate == null) return null;
    return expirationDate!.difference(DateTime.now()).inDays;
  }
}

enum SubscriptionStatus {
  active,
  inactive,
  unknown,
}
