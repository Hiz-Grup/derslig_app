import 'dart:io';

import 'package:derslig/controller/purchase_controller.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/general_response_model.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum BuyState { idle, busy }

class PurchaseProvider with ChangeNotifier {
  final _purchaseController = locator<PurchaseController>();
  BuyState buyState = BuyState.idle;

  List<ProductDetails> products = [];

  int selectedPollenIndex = 1;
  int checkCount = 0;

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
        print('Purchases sadece Android ve iOS platformlarında desteklenir. Mevcut platform: ${Platform.operatingSystem}');
      }
    } catch (e) {
      print('Purchases başlatma hatası: $e');
    }
  }

  // Future<GeneralResponseModel> buyPollen(PolenEkleModel polenEkleModel) async {
  //   GeneralResponseModel responseModel =
  //       await _purchaseController.buyPollen(polenEkleModel);
  //   await getActivePolen(
  //       polenEkleModel.userEmail ?? HiveHelpers().getUserEmail());
  //   buyState = BuyState.idle;
  //   return responseModel;
  // }

  getProductDetails() async {
    Set<String> _kIds = Platform.isIOS
        ? <String>{
            '1aylikdersligpro',
            '3aylikdersligpro',
            '6aylikdersligpro',
            '12aylikdersligpro',
          }
        : <String>{
            '1aylikdersligpro_android',
            '3aylikdersligpro_android',
            '6aylikdersligpro_android',
            '12aylikdersligpro_android',
          };
    List<String> _kIdsForSort = Platform.isIOS
        ? [
            '1aylikdersligpro',
            '3aylikdersligpro',
            '6aylikdersligpro',
            '12aylikdersligpro',
          ]
        : [
            '1aylikdersligpro_android',
            '3aylikdersligpro_android',
            '6aylikdersligpro_android',
            '12aylikdersligpro_android',
          ];
          
    try {
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        // Handle the error.
        print('notFoundIDs: ${response.notFoundIDs}');
      }

      if (response.notFoundIDs.isNotEmpty && checkCount < 3) {
        Future.delayed(const Duration(seconds: 1), () {
          getProductDetails();
          checkCount++;
        });
      }
      products = response.productDetails;

      //sort
      products.sort((a, b) =>
          _kIdsForSort.indexOf(a.id).compareTo(_kIdsForSort.indexOf(b.id)));

      notifyListeners();
    } catch (e) {
      print("Ürün detayları alınırken hata: $e");
    }
  }

  setBuyState(BuyState state) {
    buyState = state;
    notifyListeners();
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
}
