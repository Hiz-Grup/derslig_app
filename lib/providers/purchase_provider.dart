import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum BuyState { idle, busy }

class PurchaseProvider with ChangeNotifier {
  BuyState buyState = BuyState.idle;

  List<ProductDetails> products = [];

  int selectedPollenIndex = 1;
  int checkCount = 0;

  void selectPollen(int index) {
    selectedPollenIndex = index;
    notifyListeners();
  }

  Future<void> initPlatformState() async {
    await Purchases.setDebugLogsEnabled(true);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      // configuration = PurchasesConfiguration(<public_google_api_key>);
    } else if (Platform.isIOS) {
      configuration =
          PurchasesConfiguration("appl_VjzrIVjfeEsQXHftXmwCdBasNQK");
    }
    await Purchases.configure(configuration!);
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
    const Set<String> _kIds = <String>{
      '1aylikdersligpro',
      '3aylikdersligpro',
      '6aylikdersligpro',
      '12aylikdersligpro',
    };
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
      print('notFoundIDs: ${response.notFoundIDs}');
    }

    if (response.notFoundIDs.isNotEmpty && checkCount < 3) {
      Future.delayed(Duration(seconds: 1), () {
        getProductDetails();
        checkCount++;
      });
    }
    products = response.productDetails;
    products.sort((a, b) => a.price.compareTo(b.price));

    notifyListeners();
    // print(products[0].title +
    //     ' - ' +
    //     products[0].description +
    //     ' - ' +
    //     products[0].price +
    //     ' - ' +
    //     products[0].id +
    //     ' - ' +
    //     products[0].currencyCode +
    //     ' - ' +
    //     products[0].rawPrice.toString() +
    //     ' - ' +
    //     products[0].currencySymbol);
  }

  setBuyState(BuyState state) {
    buyState = state;
    notifyListeners();
  }
}
