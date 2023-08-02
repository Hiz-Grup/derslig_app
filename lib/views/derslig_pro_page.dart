import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as purchases;

class DersligProPage extends StatefulWidget {
  const DersligProPage({Key? key}) : super(key: key);

  @override
  State<DersligProPage> createState() => _DersligProPageState();
}

class _DersligProPageState extends State<DersligProPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: deviceTopPadding(context),
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
                4,
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
                          "1 Aylık Derslig Pro Üyeliği",
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
                              "289 ₺",
                              style: AppTheme.blackTextStyle(context, 32,
                                  color: AppTheme.blue),
                            ),
                            Text(
                              " / ",
                              style: AppTheme.boldTextStyle(context, 20,
                                  color: AppTheme.grey),
                            ),
                            Text(
                              "ay",
                              style: AppTheme.boldTextStyle(context, 20,
                                  color: AppTheme.blue),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: deviceHeightSize(context, 10),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            try {
                              final offerings =
                                  await purchases.Purchases.getOfferings();
                              final offering = offerings.current;
                              if (offering != null) {
                                final package =
                                    offering.availablePackages.first;
                                final purchase =
                                    await purchases.Purchases.purchasePackage(
                                        package);
                                print(purchase);
                              }
                            } catch (e) {
                              print(e);
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
                            style: AppTheme.boldTextStyle(context, 16,
                                color: AppTheme.white),
                          ),
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
