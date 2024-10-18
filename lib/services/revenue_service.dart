// import 'dart:io' show Platform;

// import 'package:derslig/models/general_response_model.dart';
// import 'package:flutter/services.dart';

// import 'package:purchases_flutter/purchases_flutter.dart';

// class RevenueServices {
//   Future<void> initPlatformState() async {
//     await Purchases.setDebugLogsEnabled(true);

//     PurchasesConfiguration? configuration;
//     if (Platform.isAndroid) {
//       configuration =
//           PurchasesConfiguration("goog_YHWWgmoacQCpeaiRKdpzqendZWa");
//     } else if (Platform.isIOS) {
//       configuration =
//           PurchasesConfiguration("appl_USgeOnssQsYOliBYdlODmChSWcD");
//     }
//     await Purchases.configure(configuration!);
//   }

//   Future<void> logIn(String userId) async {
//     Purchases.logIn(userId);
//   }

//   Future<Offerings> getProducts() async {
//     try {
//       Offerings offerings = await Purchases.getOfferings();

//       if (offerings.current != null) {
//         // Display current offering with offerings.current

//         offerings.current!.availablePackages.forEach((element) {
//           StoreProduct storeProduct = element.storeProduct;

//           print("- " +
//               storeProduct.title +
//               " : " +
//               storeProduct.priceString +
//               " : " +
//               storeProduct.description +
//               " : " +
//               storeProduct.identifier.toString());
//         });
//       }
//       return offerings;
//     } on PlatformException catch (e) {
//       // optional error handling
//       print(e);
//       return Offerings({});
//     }
//   }

//   Future<GeneralResponseModel> buyProduct(Package package) async {
//     try {
//       CustomerInfo customerInfo = await Purchases.purchasePackage(package);
//       var isPro = customerInfo.entitlements.all["pupa-premium"]!.isActive;
//       if (isPro) {
//         // Unlock that great "pro" content
//         print("Purchase successful, isPro: " + isPro.toString());
//         return GeneralResponseModel(
//             message: "Purchase successful", success: true);
//       } else {
//         return GeneralResponseModel(message: "Purchase failed", success: false);
//       }
//     } on PlatformException catch (e) {
//       var errorCode = PurchasesErrorHelper.getErrorCode(e);
//       if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
//         print(e);
//       }
//       return GeneralResponseModel(message: "Purchase failed", success: false);
//     }
//   }

//   // Future<bool?> checkSubscriptionStatus() async {
//   //   try {
//   //     CustomerInfo customerInfo = await Purchases.getCustomerInfo();
//   //     if (customerInfo.entitlements.all["pupa-premium"]!.isActive) {
//   //       // Grant user "pro" access
//   //       print("PRODUCT ID : " +
//   //           customerInfo.entitlements.all["pupa-premium"]!.toString());
//   //       return true;
//   //     } else {
//   //       return false;
//   //     }
//   //   } catch (e) {
//   //     // Error fetching purchaser info
//   //     print("Error fetching pro plan info: " + e.toString());
//   //     return null;
//   //   }
//   // }

//   // Future<void> restorePurchases() async {
//   //   try {
//   //     CustomerInfo purchaserInfo = await Purchases.restorePurchases();
//   //     if (purchaserInfo.entitlements.all["pupa-premium"]!.isActive) {
//   //       // Grant user "pro" access

//   //     }
//   //   } on PlatformException catch (e) {
//   //     // Error fetching purchaser info
//   //   }
//   // }

//   // Future<String> getPremiumType() async {
//   //   try {
//   //     CustomerInfo customerInfo = await Purchases.getCustomerInfo();
//   //     if (customerInfo.entitlements.all["pupa-premium"]!.isActive) {
//   //       // Grant user "pro" access

//   //       return customerInfo.entitlements.all["pupa-premium"]!.productIdentifier;
//   //     } else {
//   //       return "";
//   //     }
//   //   } catch (e) {
//   //     // Error fetching purchaser info
//   //     print("Error fetching pro plan info: " + e.toString());
//   //     return "";
//   //   }
//   // }
// }
