import 'dart:io';

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseProvider with ChangeNotifier {
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
}
