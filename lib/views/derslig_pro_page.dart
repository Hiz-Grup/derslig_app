import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/models/pending_purchase_model.dart';
import 'package:derslig/providers/page_provider.dart';
import 'package:derslig/providers/purchase_provider.dart';
import 'package:derslig/services/logger_service.dart';
import 'package:derslig/services/pending_purchase_service.dart';
import 'package:derslig/views/back_button_widget.dart';
import 'package:derslig/views/splash_page.dart';
import 'package:derslig/views/widgets/dialog_widgets.dart';
import 'package:derslig/views/widgets/loading_dialog.dart';
import 'package:derslig/views/widgets/toast_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:provider/provider.dart';

class DersligProPage extends StatefulWidget {
  const DersligProPage({Key? key}) : super(key: key);

  @override
  State<DersligProPage> createState() => _DersligProPageState();
}

class _DersligProPageState extends State<DersligProPage> {
  final _logger = LoggerService.instance;
  final _pendingPurchaseService = PendingPurchaseService.instance;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseProvider>().getProductDetails(context);
    });
    super.initState();
  }

  Future<void> buyProduct() async {
    int selectedProductIndex = context.read<PurchaseProvider>().selectedProductIndex;
    final packages = context.read<PurchaseProvider>().packages;

    if (packages.isEmpty || selectedProductIndex >= packages.length) {
      ToastWidgets.errorToast(context, "Ürün bilgisi bulunamadı.");
      return;
    }

    final rc.Package package = packages[selectedProductIndex];

    try {
      context.read<PurchaseProvider>().setBuyState(BuyState.busy);

      final purchaseResult = await context.read<PurchaseProvider>().purchasePackage(package);

      if (purchaseResult != null) {
        final loginModel = HiveHelpers.getLoginModel()!;
        final backendResult = await context.read<PurchaseProvider>().buyProduct(
              transactionId: purchaseResult.transactionId,
              productId: (selectedProductIndex + 1).toString(),
              productIdentifier: purchaseResult.productIdentifier,
              purchaseDate: purchaseResult.purchaseDate,
              dersligCookie: loginModel.dersligCookie,
              xsrfToken: loginModel.xsrfToken,
            );

        context.read<PurchaseProvider>().setBuyState(BuyState.idle);

        if (backendResult.success == true) {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              SplashPage.routeName,
            );
            ToastWidgets.successToast(context, "Satın alma işlemi başarılı!");
          }
        } else {
          await _handleBackendFailure(
            purchaseResult: purchaseResult,
            selectedProductIndex: selectedProductIndex,
          );
        }
      } else {
        context.read<PurchaseProvider>().setBuyState(BuyState.idle);
        ToastWidgets.errorToast(context, "Satın alma işlemi iptal edildi veya başarısız oldu.");
      }
    } on rc.PurchasesErrorCode catch (e) {
      context.read<PurchaseProvider>().setBuyState(BuyState.idle);

      if (e == rc.PurchasesErrorCode.purchaseCancelledError) {
        ToastWidgets.errorToast(context, "Satın alma işlemi iptal edildi.");
      } else if (e == rc.PurchasesErrorCode.paymentPendingError) {
        ToastWidgets.errorToast(context, "Ödeme işleminiz beklemede. Lütfen daha sonra tekrar deneyin.");
      } else {
        ToastWidgets.errorToast(context, "Satın alma işlemi başarısız oldu. Lütfen tekrar deneyin.");
      }
    } catch (e, stackTrace) {
      context.read<PurchaseProvider>().setBuyState(BuyState.idle);

      _logger.logError(
        'Satın alma beklenmeyen hata',
        error: e,
        stackTrace: stackTrace,
        context: {
          'packageId': package.identifier,
          'selectedIndex': selectedProductIndex,
        },
      );

      ToastWidgets.errorToast(context, "Satın alma başlatılamadı. Lütfen tekrar deneyin.");
    }
  }

  Future<void> _handleBackendFailure({
    required PurchaseResultData purchaseResult,
    required int selectedProductIndex,
  }) async {
    final pendingPurchase = PendingPurchaseModel(
      transactionId: purchaseResult.transactionId,
      productId: (selectedProductIndex + 1).toString(),
      productIdentifier: purchaseResult.productIdentifier,
      purchaseDate: purchaseResult.purchaseDate,
    );

    await _pendingPurchaseService.addPendingPurchase(pendingPurchase);

    await _logger.logFatal(
      'Satın alma backend\'e iletilemedi - Pending queue\'ya eklendi',
      context: {
        'transactionId': purchaseResult.transactionId,
        'productId': (selectedProductIndex + 1).toString(),
        'productIdentifier': purchaseResult.productIdentifier,
        'purchaseDate': purchaseResult.purchaseDate.toIso8601String(),
        'userId': HiveHelpers.getUserModel()?.id?.toString(),
        'userEmail': HiveHelpers.getUserModel()?.email,
      },
    );

    if (mounted) {
      _showBackendErrorDialog();
    }
  }

  void _showBackendErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DialogWidgets().rowCircularButtonDialogWidget(
        ctx,
        title: "Siparişinizi Aldık",
        content: "Satın alma işleminiz başarıyla tamamlandı ancak sistemimize kaydedilirken bir sorun oluştu. "
            "Endişelenmeyin, ödemeniz alındı ve Pro üyeliğiniz kısa süre içinde aktif olacaktır.\n\n"
            "Eğer 24 saat içinde aktif olmazsa lütfen Derslig ekibiyle iletişime geçiniz.",
        color: AppTheme.pink,
        buttonText: "Tamam",
        cancelButtonText: "Kapat",
        onAcceptButtonPressed: () {
          Navigator.of(ctx).pop();
          Navigator.pushReplacementNamed(context, SplashPage.routeName);
        },
        onCancelButtonPressed: () {
          Navigator.of(ctx).pop();
          Navigator.pushReplacementNamed(context, SplashPage.routeName);
        },
      ),
    );
  }

  List<rc.Package> _packages = [];

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
                                final checkResult = await context.read<PurchaseProvider>().checkUser(
                                      xsrfToken: HiveHelpers.getLoginModel()!.xsrfToken,
                                      dersligCookie: HiveHelpers.getLoginModel()!.dersligCookie,
                                    );

                                if (checkResult.success == true) {
                                  context.read<PurchaseProvider>().selectProduct(index);
                                  loadingDialog.dismiss();
                                  buyProduct();
                                } else {
                                  ToastWidgets.errorToast(context, checkResult.message);
                                  loadingDialog.dismiss();
                                  context.read<PurchaseProvider>().setBuyState(BuyState.idle);
                                }
                              } catch (e, stackTrace) {
                                _logger.logError(
                                  'Kullanıcı kontrolü sırasında hata',
                                  error: e,
                                  stackTrace: stackTrace,
                                );
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
