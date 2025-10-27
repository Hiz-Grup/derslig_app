import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/providers/page_provider.dart';
import 'package:derslig/providers/purchase_provider.dart';
import 'package:derslig/views/back_button_widget.dart';
import 'package:derslig/views/splash_page.dart';
import 'package:derslig/views/widgets/loading_dialog.dart';
import 'package:derslig/views/widgets/toast_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';

class DersligProPage extends StatefulWidget {
  const DersligProPage({Key? key}) : super(key: key);

  @override
  State<DersligProPage> createState() => _DersligProPageState();
}

class _DersligProPageState extends State<DersligProPage> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseProvider>().getProductDetails(context);
    });
    super.initState();
  }

  Future<void> buyProduct() async {
    int selectedPollenIndex = context.read<PurchaseProvider>().selectedPollenIndex;
    final packages = context.read<PurchaseProvider>().packages;

    if (packages.isEmpty || selectedPollenIndex >= packages.length) {
      ToastWidgets.errorToast(context, "Ürün bilgisi bulunamadı.");
      return;
    }

    final Package package = packages[selectedPollenIndex];

    try {
      context.read<PurchaseProvider>().setBuyState(BuyState.busy);

      CustomerInfo? customerInfo = await context.read<PurchaseProvider>().purchasePackage(package);

      if (customerInfo != null) {
        await context
            .read<PurchaseProvider>()
            .buyProduct(
              dersligCookie: HiveHelpers.getLoginModel()!.dersligCookie,
              xsrfToken: HiveHelpers.getLoginModel()!.xsrfToken,
              index: selectedPollenIndex,
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
      } else {
        context.read<PurchaseProvider>().setBuyState(BuyState.idle);
        ToastWidgets.errorToast(context, "Satın alma işlemi iptal edildi veya başarısız oldu.");
      }
    } on PurchasesErrorCode catch (e) {
      context.read<PurchaseProvider>().setBuyState(BuyState.idle);
      print("RevenueCat hatası: ${e.toString()}");

      if (e == PurchasesErrorCode.purchaseCancelledError) {
        ToastWidgets.errorToast(context, "Satın alma işlemi iptal edildi.");
      } else if (e == PurchasesErrorCode.paymentPendingError) {
        ToastWidgets.errorToast(context, "Ödeme işleminiz beklemede. Lütfen daha sonra tekrar deneyin.");
      } else {
        ToastWidgets.errorToast(context, "Satın alma işlemi başarısız oldu. Lütfen tekrar deneyin.");
      }
    } catch (e) {
      context.read<PurchaseProvider>().setBuyState(BuyState.idle);
      print("Satın alma başlatılırken hata: $e");
      ToastWidgets.errorToast(context, "Satın alma başlatılamadı. Lütfen tekrar deneyin.");
    }
  }

  List<Package> _packages = [];
  @override
  Widget build(BuildContext context) {
    _packages = context.watch<PurchaseProvider>().packages;
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
                      style: AppTheme.blackTextStyle(context, 30, color: AppTheme.black),
                    ),
                  ),
                  ...List.generate(
                    _packages.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: deviceWidthSize(context, 20),
                        vertical: deviceHeightSize(context, 5),
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.shadowList,
                        color: AppTheme.white,
                      ),
                      padding: EdgeInsets.all(deviceWidthSize(context, 16)),
                      child: Column(
                        children: [
                          Text(
                            _packages[index].storeProduct.title,
                            style: AppTheme.boldTextStyle(context, 16, color: AppTheme.grey),
                          ),
                          SizedBox(
                            height: deviceHeightSize(context, 20),
                          ),
                          Text(
                            _packages[index].storeProduct.priceString,
                            style: AppTheme.blackTextStyle(context, 32, color: AppTheme.blue),
                          ),
                          SizedBox(
                            height: deviceHeightSize(context, 10),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              if (context.read<PurchaseProvider>().buyState == BuyState.busy) {
                                return;
                              }

                              final LoadingDialog loadingDialog = LoadingDialog(context);
                              loadingDialog.show();
                              context.read<PurchaseProvider>().setBuyState(BuyState.busy);
                              try {
                                await context
                                    .read<PurchaseProvider>()
                                    .checkUser(
                                        xsrfToken: HiveHelpers.getLoginModel()!.xsrfToken,
                                        dersligCookie: HiveHelpers.getLoginModel()!.dersligCookie)
                                    .then((value) {
                                  if (value.success == true) {
                                    context.read<PurchaseProvider>().selectedPollenIndex = index;
                                    loadingDialog.dismiss();
                                    buyProduct();
                                  } else {
                                    ToastWidgets.errorToast(context, value.message);
                                    loadingDialog.dismiss();
                                    context.read<PurchaseProvider>().setBuyState(BuyState.idle);
                                  }
                                });
                              } catch (e) {
                                print("Kullanıcı kontrolü sırasında hata: $e");
                                loadingDialog.dismiss();
                                context.read<PurchaseProvider>().setBuyState(BuyState.idle);
                                ToastWidgets.errorToast(
                                    context, "Kullanıcı kontrolü başarısız oldu. Lütfen tekrar deneyin.");
                              }
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
                              style: AppTheme.boldTextStyle(context, 16, color: AppTheme.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: deviceHeightSize(context, 40)),
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
