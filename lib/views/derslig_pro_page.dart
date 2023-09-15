import 'dart:async';

import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/providers/page_provider.dart';
import 'package:derslig/providers/purchase_provider.dart';
import 'package:derslig/views/back_button_widget.dart';
import 'package:derslig/views/splash_page.dart';
import 'package:derslig/views/widgets/toast_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class DersligProPage extends StatefulWidget {
  const DersligProPage({Key? key}) : super(key: key);

  @override
  State<DersligProPage> createState() => _DersligProPageState();
}

class _DersligProPageState extends State<DersligProPage> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseProvider>().getProductDetails();
      final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription!.cancel();
      }, onError: (error) {
        // handle error here.
        print("Error : " + error.toString());
      });
    });
    super.initState();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      print('purchaseDetails: ${purchaseDetails.productID}');
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print('pending');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print('error');
          ToastWidgets.errorToast(
              context,
              "Satın alma işlemi başarısız oldu. " +
                  purchaseDetails.error!.message);
          context.read<PurchaseProvider>().setBuyState(BuyState.idle);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          print('purchased');

          context.read<PurchaseProvider>().setBuyState(BuyState.busy);
          context
              .read<PurchaseProvider>()
              .buyProduct(
                dersligCookie: HiveHelpers.getLoginModel()!.dersligCookie,
                xsrfToken: HiveHelpers.getLoginModel()!.xsrfToken,
                index: _products.indexWhere(
                  (element) => element.id == purchaseDetails.productID,
                ),
              )
              .then(
            (value) {
              context.read<PurchaseProvider>().setBuyState(BuyState.idle);
              if (value.success == true) {
                Navigator.pushReplacementNamed(
                  context,
                  SplashPage.routeName,
                );
              }
              ToastWidgets.responseToast(context, value);
            },
          );
          // bool valid = await _verifyPurchase(purchaseDetails);
          // if (valid) {
          //   _deliverProduct(purchaseDetails);
          // } else {
          //   _handleInvalidPurchase(purchaseDetails);
          // }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          print('pendingCompletePurchase');
          await InAppPurchase.instance.completePurchase(purchaseDetails);
          context.read<PurchaseProvider>().setBuyState(BuyState.idle);
        }
      }
    });
  }

  buyProduct() async {
    int selectedPollenIndex =
        context.read<PurchaseProvider>().selectedPollenIndex;

    final ProductDetails productDetails =
        context.read<PurchaseProvider>().products[
            selectedPollenIndex]; // Saved earlier from queryProductDetails().

    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    // if (_isConsumable(productDetails)) {
    InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
    // } else {
    // InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    // }
  }

  List<ProductDetails> _products = [];
  @override
  Widget build(BuildContext context) {
    _products = context.watch<PurchaseProvider>().products;
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: deviceTopPadding(context),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: deviceWidthSize(context, 20),
                    ),
                    alignment: Alignment.centerLeft,
                    child: BackButtonWidget(
                      onPressed: () {
                        context.read<PageProvider>().pageIndex = 0;
                        context.read<PageProvider>().currentIndex = 0;

                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(deviceWidthSize(context, 20)),
                    child: Text(
                      "Derslig Pro ile Başarını Yükselt!",
                      textAlign: TextAlign.center,
                      style: AppTheme.blackTextStyle(context, 30,
                          color: AppTheme.black),
                    ),
                  ),
                  ...List.generate(
                    _products.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: deviceWidthSize(context, 20),
                        vertical: deviceHeightSize(context, 5),
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppTheme.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.shadowList,
                        color: AppTheme.white,
                      ),
                      padding: EdgeInsets.all(deviceWidthSize(context, 16)),
                      child: Column(
                        children: [
                          Text(
                            _products[index].title,
                            style: AppTheme.boldTextStyle(context, 16,
                                color: AppTheme.grey),
                          ),
                          SizedBox(
                            height: deviceHeightSize(context, 20),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _products[index].price,
                                style: AppTheme.blackTextStyle(context, 32,
                                    color: AppTheme.blue),
                              ),
                              // Text(
                              //   " / ",
                              //   style: AppTheme.boldTextStyle(context, 20,
                              //       color: AppTheme.grey),
                              // ),
                              // Text(
                              //   _products[index].duration,
                              //   style: AppTheme.boldTextStyle(context, 20,
                              //       color: AppTheme.blue),
                              // ),
                            ],
                          ),
                          SizedBox(
                            height: deviceHeightSize(context, 10),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              context
                                  .read<PurchaseProvider>()
                                  .setBuyState(BuyState.busy);
                              context
                                  .read<PurchaseProvider>()
                                  .checkUser(
                                      xsrfToken: HiveHelpers.getLoginModel()!
                                          .xsrfToken,
                                      dersligCookie:
                                          HiveHelpers.getLoginModel()!
                                              .dersligCookie)
                                  .then((value) {
                                if (value.success == true) {
                                  context
                                      .read<PurchaseProvider>()
                                      .selectedPollenIndex = index;
                                  buyProduct();
                                } else {
                                  ToastWidgets.errorToast(
                                      context, value.message);
                                }
                                context
                                    .read<PurchaseProvider>()
                                    .setBuyState(BuyState.idle);
                              });
                            },
                            color: AppTheme.pink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: deviceWidthSize(context, 30),
                              vertical: deviceHeightSize(context, 8),
                            ),
                            child: Text(
                              "Satın Al",
                              style: AppTheme.boldTextStyle(context, 16,
                                  color: AppTheme.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Consumer<PurchaseProvider>(
                builder: (context, value, child) {
                  if (value.buyState == BuyState.busy) {
                    return Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.pink,
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductModel {
  final String title;
  final String price;
  final String duration;

  ProductModel({
    required this.title,
    required this.price,
    required this.duration,
  });
}
