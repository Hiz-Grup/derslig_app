import 'dart:io';
import 'dart:ui';

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
import 'package:derslig/views/widgets/toast_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:provider/provider.dart';

class DersligProPage extends StatefulWidget {
  const DersligProPage({Key? key}) : super(key: key);

  static const String routeName = '/derslig-pro';

  @override
  State<DersligProPage> createState() => _DersligProPageState();
}

class _DersligProPageState extends State<DersligProPage> {
  final _logger = LoggerService.instance;
  final _pendingPurchaseService = PendingPurchaseService.instance;

  int _selectedPlanIndex = -1;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseProvider>().getProductDetails(context);
    });
  }

  static const List<_FeatureItem> _features = [
    _FeatureItem(icon: Icons.all_inclusive, text: "Tüm derslere sınırsız erişim"),
    _FeatureItem(icon: Icons.video_library_outlined, text: "Binlerce video içerik"),
    _FeatureItem(icon: Icons.quiz_outlined, text: "Sınırsız soru çözümü"),
    _FeatureItem(icon: Icons.block, text: "Reklamsız deneyim"),
  ];

  Future<void> _purchaseSelectedPlan() async {
    final packages = context.read<PurchaseProvider>().packages;

    if (packages.isEmpty || _selectedPlanIndex >= packages.length) {
      ToastWidgets.errorToast(context, "Ürün bilgisi bulunamadı.");
      return;
    }

    final rc.Package package = packages[_selectedPlanIndex];

    try {
      context.read<PurchaseProvider>().setBuyState(BuyState.busy);

      final loginModel = HiveHelpers.getLoginModel();
      if (loginModel == null) {
        ToastWidgets.errorToast(context, "Lütfen önce giriş yapın.");
        context.read<PurchaseProvider>().setBuyState(BuyState.idle);
        return;
      }

      final checkResult = await context.read<PurchaseProvider>().checkUser(
            xsrfToken: loginModel.xsrfToken,
            dersligCookie: loginModel.dersligCookie,
          );

      if (checkResult.success != true) {
        ToastWidgets.errorToast(context, checkResult.message);
        context.read<PurchaseProvider>().setBuyState(BuyState.idle);
        return;
      }

      final purchaseResult = await context.read<PurchaseProvider>().purchasePackage(package);

      if (purchaseResult != null) {
        final backendResult = await context.read<PurchaseProvider>().confirmSubscription(
              transactionId: purchaseResult.transactionId,
              productIdentifier: purchaseResult.productIdentifier,
              purchaseDate: purchaseResult.purchaseDate,
              expirationDate: purchaseResult.expirationDate,
              isTrialPeriod: purchaseResult.isTrialPeriod,
              willRenew: purchaseResult.willRenew,
              xsrfToken: loginModel.xsrfToken,
              dersligCookie: loginModel.dersligCookie,
            );

        context.read<PurchaseProvider>().setBuyState(BuyState.idle);

        if (backendResult.success == true) {
          if (mounted) {
            final message =
                purchaseResult.isTrialPeriod ? "Ücretsiz denemeniz başladı!" : "Aboneliğiniz aktifleştirildi!";
            ToastWidgets.successToast(context, message);
            Navigator.pushReplacementNamed(context, SplashPage.routeName);
          }
        } else {
          await _handleBackendFailure(purchaseResult: purchaseResult);
        }
      } else {
        context.read<PurchaseProvider>().setBuyState(BuyState.idle);
      }
    } on rc.PurchasesErrorCode catch (e) {
      context.read<PurchaseProvider>().setBuyState(BuyState.idle);

      if (e == rc.PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled, no need to show error
      } else if (e == rc.PurchasesErrorCode.paymentPendingError) {
        ToastWidgets.errorToast(context, "Ödeme işleminiz beklemede.");
      } else {
        ToastWidgets.errorToast(context, "Satın alma başarısız oldu. Lütfen tekrar deneyin.");
      }
    } catch (e, stackTrace) {
      context.read<PurchaseProvider>().setBuyState(BuyState.idle);

      _logger.logError(
        'Satın alma beklenmeyen hata',
        error: e,
        stackTrace: stackTrace,
        context: {
          'packageId': package.identifier,
          'selectedIndex': _selectedPlanIndex,
        },
      );

      ToastWidgets.errorToast(context, "Bir hata oluştu. Lütfen tekrar deneyin.");
    }
  }

  Future<void> _handleBackendFailure({
    required PurchaseResultData purchaseResult,
  }) async {
    final pendingPurchase = PendingPurchaseModel.subscription(
      transactionId: purchaseResult.transactionId,
      productIdentifier: purchaseResult.productIdentifier,
      purchaseDate: purchaseResult.purchaseDate,
      expirationDate: purchaseResult.expirationDate,
      isTrialPeriod: purchaseResult.isTrialPeriod,
      willRenew: purchaseResult.willRenew,
    );

    await _pendingPurchaseService.addPendingPurchase(pendingPurchase);

    await _logger.logFatal(
      'Subscription backend\'e iletilemedi - Pending queue\'ya eklendi',
      context: {
        'transactionId': purchaseResult.transactionId,
        'productIdentifier': purchaseResult.productIdentifier,
        'purchaseDate': purchaseResult.purchaseDate.toIso8601String(),
        'isTrialPeriod': purchaseResult.isTrialPeriod,
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
        content: "Abonelik işleminiz başarıyla tamamlandı ancak sistemimize kaydedilirken bir sorun oluştu. "
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<PurchaseProvider>(
        builder: (context, purchaseProvider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: deviceWidthSize(context, 20),
                  right: deviceWidthSize(context, 20),
                  bottom: deviceHeightSize(context, 160),
                ),
                child: Column(
                  spacing: deviceHeightSize(context, 20),
                  children: [
                    SizedBox(height: deviceTopPadding(context) + deviceHeightSize(context, 60)),
                    _buildProBadge(),
                    _buildTitle(),
                    _buildFeaturesList(),
                    _buildPlanSelector(purchaseProvider.packages),
                    _buildTrialBadge(purchaseProvider.packages),
                    _buildTermsText(),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: _buildHeader(),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildFixedBottomButton(purchaseProvider),
              ),
              if (purchaseProvider.buyState == BuyState.busy) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFixedBottomButton(PurchaseProvider provider) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(deviceHeightSize(context, 20)),
        topRight: Radius.circular(deviceHeightSize(context, 20)),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.white.withValues(alpha: 0.1),
          padding: EdgeInsets.only(
            left: deviceWidthSize(context, 20),
            right: deviceWidthSize(context, 20),
            top: deviceHeightSize(context, 12),
            bottom: MediaQuery.of(context).padding.bottom + (Platform.isAndroid ? deviceHeightSize(context, 12) : 0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSubscribeButton(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.white.withValues(alpha: 0.3),
          padding: EdgeInsets.only(
            top: deviceTopPadding(context) + deviceHeightSize(context, 8),
            left: deviceWidthSize(context, 16),
            right: deviceWidthSize(context, 16),
            bottom: deviceHeightSize(context, 8),
          ),
          child: Row(
            children: [
              BackButtonWidget(
                onPressed: () {
                  context.read<PageProvider>().pageIndex = 0;
                  context.read<PageProvider>().currentIndex = 0;
                  Navigator.pop(context);
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: deviceWidthSize(context, 24),
        vertical: deviceHeightSize(context, 10),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.pink, Color(0xFFFF6B9D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pink.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 22),
          SizedBox(width: deviceWidthSize(context, 8)),
          Text(
            "PRO",
            style: AppTheme.blackTextStyle(context, 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          "Derslig Pro ile",
          textAlign: TextAlign.center,
          style: AppTheme.boldTextStyle(context, 28, color: AppTheme.black),
        ),
        Text(
          "Başarını Yükselt!",
          textAlign: TextAlign.center,
          style: AppTheme.blackTextStyle(context, 28, color: AppTheme.pink),
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      padding: EdgeInsets.all(deviceWidthSize(context, 20)),
      decoration: BoxDecoration(
        color: AppTheme.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.blue.withOpacity(0.1)),
      ),
      child: Column(
        children: _features
            .map((feature) => Padding(
                  padding: EdgeInsets.symmetric(vertical: deviceHeightSize(context, 8)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(deviceWidthSize(context, 8)),
                        decoration: BoxDecoration(
                          color: AppTheme.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          feature.icon,
                          color: AppTheme.blue,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: deviceWidthSize(context, 14)),
                      Expanded(
                        child: Text(
                          feature.text,
                          style: AppTheme.semiBoldTextStyle(context, 15, color: AppTheme.black),
                        ),
                      ),
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.blue,
                        size: 22,
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPlanSelector(List<rc.Package> packages) {
    if (packages.isEmpty) {
      return Container(
        padding: EdgeInsets.all(deviceWidthSize(context, 20)),
        child: const CircularProgressIndicator(color: AppTheme.pink),
      );
    }

    final sortedPackages = List<rc.Package>.from(packages);
    sortedPackages.sort((a, b) {
      int aMonths = _extractMonthsFromPackage(a);
      int bMonths = _extractMonthsFromPackage(b);
      return bMonths.compareTo(aMonths);
    });

    if (_selectedPlanIndex == -1 && sortedPackages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedPlanIndex = packages.indexOf(sortedPackages.first);
          });
        }
      });
    }

    return Column(
      children: List.generate(sortedPackages.length, (index) {
        final package = sortedPackages[index];
        final originalIndex = packages.indexOf(package);
        final isSelected = _selectedPlanIndex == originalIndex;
        final isRecommended = index == 0;

        return _buildPlanCard(
          package: package,
          isSelected: isSelected,
          isPopular: isRecommended,
          onTap: () => setState(() => _selectedPlanIndex = originalIndex),
        );
      }),
    );
  }

  int _extractMonthsFromPackage(rc.Package package) {
    final id = package.storeProduct.identifier.toLowerCase();
    if (id.contains('annual') || id.contains('12')) return 12;
    if (id.contains('6')) return 6;
    if (id.contains('3')) return 3;
    if (id.contains('monthly') || id.contains('1')) return 1;
    return 0;
  }

  Widget _buildPlanCard({
    required rc.Package package,
    required bool isSelected,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    final storeProduct = package.storeProduct;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: deviceHeightSize(context, 12)),
        padding: EdgeInsets.all(deviceWidthSize(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.pink : AppTheme.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.pink : AppTheme.grey.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.pink,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: deviceWidthSize(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeProduct.title,
                    style: AppTheme.boldTextStyle(context, 16, color: AppTheme.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: deviceHeightSize(context, 4)),
                  Row(
                    children: [
                      if (storeProduct.subscriptionPeriod != null)
                        Text(
                          _getSubscriptionPeriodText(storeProduct.subscriptionPeriod!),
                          style: AppTheme.normalTextStyle(context, 13, color: AppTheme.grey),
                        ),
                      if (isPopular) ...[
                        SizedBox(width: deviceWidthSize(context, 8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: deviceWidthSize(context, 8),
                            vertical: deviceHeightSize(context, 2),
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.blue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "EN POPÜLER",
                            style: AppTheme.boldTextStyle(context, 10, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  storeProduct.priceString,
                  style: AppTheme.blackTextStyle(context, 18, color: AppTheme.pink),
                ),
                if (storeProduct.subscriptionPeriod != null)
                  Text(
                    _getMonthlyPrice(storeProduct),
                    style: AppTheme.normalTextStyle(context, 12, color: AppTheme.grey),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getSubscriptionPeriodText(String period) {
    if (period.contains('P1M')) return 'Aylık yenilenir';
    if (period.contains('P3M')) return '3 ayda bir yenilenir';
    if (period.contains('P6M')) return '6 ayda bir yenilenir';
    if (period.contains('P1Y')) return 'Yıllık yenilenir';
    return '';
  }

  String _getMonthlyPrice(rc.StoreProduct product) {
    final period = product.subscriptionPeriod ?? '';
    if (period.contains('P1Y')) {
      return 'Ayda ~${(product.price / 12).toStringAsFixed(2)} ${product.currencyCode}';
    }
    if (period.contains('P6M')) {
      return 'Ayda ~${(product.price / 6).toStringAsFixed(2)} ${product.currencyCode}';
    }
    if (period.contains('P3M')) {
      return 'Ayda ~${(product.price / 3).toStringAsFixed(2)} ${product.currencyCode}';
    }
    return '';
  }

  Widget _buildTrialBadge(List<rc.Package> packages) {
    if (packages.isEmpty) return const SizedBox();

    final hasTrialOffer = packages.any((p) => p.storeProduct.introductoryPrice != null);

    if (!hasTrialOffer) return const SizedBox();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: deviceWidthSize(context, 16),
        vertical: deviceHeightSize(context, 10),
      ),
      decoration: BoxDecoration(
        color: AppTheme.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.blue.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, color: AppTheme.blue, size: 20),
          SizedBox(width: deviceWidthSize(context, 8)),
          Text(
            "3 gün ücretsiz dene, sonra ödemeye başla",
            style: AppTheme.semiBoldTextStyle(context, 14, color: AppTheme.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(PurchaseProvider provider) {
    final hasPackages = provider.packages.isNotEmpty;
    final isBusy = provider.buyState == BuyState.busy;

    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        onPressed: (hasPackages && !isBusy) ? _purchaseSelectedPlan : null,
        color: AppTheme.pink,
        disabledColor: AppTheme.grey.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: deviceHeightSize(context, 16)),
        elevation: 2,
        child: Text(
          "Denemeyi Başlat",
          style: AppTheme.boldTextStyle(context, 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: deviceWidthSize(context, 20)),
      child: Text(
        "Abonelik dönemi sonunda otomatik olarak yenilenir. İstediğiniz zaman ayarlardan iptal edebilirsiniz. Deneme süresinde iptal ederseniz ücretlendirilmezsiniz.",
        textAlign: TextAlign.center,
        style: AppTheme.normalTextStyle(context, 12, color: AppTheme.grey),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.pink),
            SizedBox(height: 16),
            Text(
              "İşleminiz gerçekleştiriliyor...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});
}
