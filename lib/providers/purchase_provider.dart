import 'dart:io';

import 'package:derslig/controller/purchase_controller.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/general_response_model.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum BuyState { idle, busy }

class PurchaseProvider with ChangeNotifier {
  final _purchaseController = locator<PurchaseController>();
  BuyState buyState = BuyState.idle;

  List<Package> packages = [];
  Offering? currentOffering;

  int selectedPollenIndex = 1;

  void selectPollen(int index) {
    selectedPollenIndex = index;
    notifyListeners();
  }

  Future<void> initPlatformState() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await Purchases.setLogLevel(LogLevel.debug);

        PurchasesConfiguration? configuration;
        if (Platform.isAndroid) {
          configuration = PurchasesConfiguration("goog_wRHmEaOoDcFcIIYldGLpguNccvC");
          await Purchases.configure(configuration);
          await Purchases.enableAdServicesAttributionTokenCollection();
        } else if (Platform.isIOS) {
          configuration = PurchasesConfiguration("appl_VjzrIVjfeEsQXHftXmwCdBasNQK");
          await Purchases.configure(configuration);
        }
      } else {
        print(
            'Purchases sadece Android ve iOS platformlarında desteklenir. Mevcut platform: ${Platform.operatingSystem}');
      }
    } catch (e) {
      print('Purchases başlatma hatası: $e');
    }
  }

  Future<void> getProductDetails(BuildContext context) async {
    try {
      Offerings offerings = await Purchases.getOfferings();

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
      } else {
        print('RevenueCat: Mevcut teklif bulunamadı');
      }
    } catch (e) {
      print('RevenueCat: Ürün detayları alınırken hata: $e');
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

  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      PurchaseResult result = await Purchases.purchasePackage(package);
      return result.customerInfo;
    } catch (e) {
      print('RevenueCat: Satın alma hatası: $e');
      return null;
    }
  }

  Future<GeneralResponseModel> buyProduct({
    required int index,
    required String xsrfToken,
    required String dersligCookie,
  }) async {
    return await _purchaseController.buyProduct(
      index: index,
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

  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } catch (e) {
      print('RevenueCat: Kullanıcı bilgileri alınırken hata: $e');
      return null;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo;
    } catch (e) {
      print('RevenueCat: Satın almalar geri yüklenirken hata: $e');
      return null;
    }
  }
}
